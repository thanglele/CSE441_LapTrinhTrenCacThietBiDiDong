using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using BCrypt.Net;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Infrastructure.Data;
using MyTLUServer.Domain.Models;
using System.Linq;
using Microsoft.Extensions.Caching.Memory;
using MyTLUServer.Application.Exceptions;
using System.Collections.Generic; // Cần cho List

namespace MyTLUServer.Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IMemoryCache _cache;
        private readonly IEmailService _emailService;

        public AuthService(
            IConfiguration configuration,
            AppDbContext context,
            IMemoryCache cache,
            IEmailService emailService)
        {
            _configuration = configuration;
            _context = context;
            _cache = cache;
            _emailService = emailService;
        }

        #region Nghiệp vụ Đăng nhập

        public async Task<LoginResponseDto> LoginAsync(LoginRequestDto loginRequest)
        {
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == loginRequest.Username);

            if (user == null || user.AccountStatus != "active")
            {
                return null;
            }

            if (string.IsNullOrEmpty(user.PasswordHash))
            {
                throw new PasswordNotSetException();
            }

            bool isValid = false;
            try
            {
                isValid = await Task.Run(() =>
                    BCrypt.Net.BCrypt.Verify(loginRequest.Password, user.PasswordHash)
                );
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Password verification error for user {user.Username}: {ex.Message}");
                isValid = false;
            }

            if (!isValid)
            {
                return null; // Sai mật khẩu
            }

            bool needsSave = false;
            // (Tùy chọn) Logic Re-hash
            int targetWorkFactor = 12;
            try
            {
                int currentWorkFactor = GetWorkFactorManually(user.PasswordHash); // Thay bằng hàm helper tự viết

                if (currentWorkFactor > targetWorkFactor && currentWorkFactor > 0)
                {
                    user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(loginRequest.Password, targetWorkFactor);
                    needsSave = true;
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to re-hash password for {user.Username}: {ex.Message}");
            }

            // Cập nhật LoginPosition
            if (user.LoginPosition != loginRequest.LoginPosition)
            {
                user.LoginPosition = loginRequest.LoginPosition;
                needsSave = true;
            }

            if (needsSave)
            {
                _context.Logins.Update(user);
                await _context.SaveChangesAsync();
            }

            // --- LẤY TRẠNG THÁI SINH TRẮC HỌC ---
            string faceStatus = "n/a";
            if (user.UserRole == "student")
            {
                var isActive = await _context.FaceData
                    .AnyAsync(fd => fd.StudentCode == user.Username && fd.IsActive == true && fd.UploadStatus == "verified");

                if (isActive)
                {
                    faceStatus = "verified";
                }
                else
                {
                    var isPending = await _context.FaceData
                        .AnyAsync(fd => fd.StudentCode == user.Username && fd.UploadStatus == "uploaded");

                    faceStatus = isPending ? "pending" : "none";
                }
            }

            var token = GenerateJwtToken(user);
            return new LoginResponseDto
            {
                Token = token,
                UserRole = user.UserRole,
                FaceDataStatus = faceStatus
            };
        }
        #endregion

        #region Nghiệp vụ Reset Mật khẩu

        /// <summary>
        /// Yêu cầu gửi OTP để reset mật khẩu
        /// </summary>
        public async Task<bool> RequestPasswordResetAsync(OtpRequestDto otpRequest)
        {
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == otpRequest.Username);

            if (user == null || string.IsNullOrEmpty(user.Email) || user.AccountStatus != "active")
            {
                // Luôn trả về true để tránh lộ thông tin
                return true;
            }

            // Tạo OTP ngẫu nhiên 6 chữ số
            var otp = new Random().Next(100000, 999999).ToString();

            // Lưu OTP vào cache, key là username
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(5)); // Hết hạn sau 5 phút
            _cache.Set(otpRequest.Username, otp, cacheEntryOptions);

            // Gửi email (non-blocking)
            _ = _emailService.SendOtpEmailAsync(user.Email, otp);

            return true;
        }

        /// <summary>
        /// Xác thực OTP và trả về ResetToken
        /// </summary>
        public async Task<string?> VerifyOtpAsync(VerifyOtpRequestDto verifyRequest)
        {
            // 1. Kiểm tra OTP
            if (!_cache.TryGetValue(verifyRequest.Username, out string cachedOtp))
            {
                // OTP hết hạn hoặc không tồn tại
                return null;
            }

            if (cachedOtp != verifyRequest.Otp)
            {
                return null; // Sai OTP
            }

            // 2. OTP hợp lệ. Xóa OTP cũ.
            _cache.Remove(verifyRequest.Username);

            // 3. Tạo ResetToken mới
            var resetToken = Guid.NewGuid().ToString();
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(10)); // Token reset chỉ có hạn 10 phút

            // Key mới để lưu token, ví dụ: "reset_student123"
            _cache.Set($"reset_{verifyRequest.Username}", resetToken, cacheEntryOptions);

            return await Task.FromResult(resetToken); // Trả về token
        }

        /// <summary>
        /// Xác thực ResetToken và đặt lại mật khẩu mới
        /// </summary>
        public async Task<bool> ResetPasswordAsync(ResetPasswordRequestDto resetRequest)
        {
            // 1. Kiểm tra ResetToken
            string cacheKey = $"reset_{resetRequest.Username}";
            if (!_cache.TryGetValue(cacheKey, out string cachedToken))
            {
                // Token hết hạn hoặc không tồn tại
                return false;
            }

            if (cachedToken != resetRequest.ResetToken)
            {
                return false; // Sai ResetToken
            }

            // 2. Tìm User
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == resetRequest.Username);

            if (user == null)
            {
                return false;
            }

            // 3. Hash mật khẩu mới
            int workFactor = 12; // Luôn dùng work factor chuẩn
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(resetRequest.NewPassword, workFactor);

            // 4. Lưu vào DB
            _context.Logins.Update(user);
            await _context.SaveChangesAsync();

            // 5. Xóa ResetToken khỏi cache (vì đã được sử dụng)
            _cache.Remove(cacheKey);

            return true;
        }
        #endregion

        #region Nghiệp vụ Đổi Mật khẩu

        /// <summary>
        /// Thay đổi mật khẩu khi người dùng đã đăng nhập
        /// </summary>
        public async Task<bool> ChangePasswordAsync(string username, ChangePasswordRequestDto changeRequest)
        {
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == username);

            if (user == null || string.IsNullOrEmpty(user.PasswordHash))
            {
                return false; // Lỗi: User không tồn tại hoặc chưa set pass
            }

            // 1. Xác thực mật khẩu CŨ
            bool isCurrentPasswordValid = false;
            try
            {
                isCurrentPasswordValid = await Task.Run(() =>
                    BCrypt.Net.BCrypt.Verify(changeRequest.CurrentPassword, user.PasswordHash)
                );
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[ChangePassword] Password verification error for user {user.Username}: {ex.Message}");
                isCurrentPasswordValid = false;
            }

            if (!isCurrentPasswordValid)
            {
                return false; // Sai mật khẩu hiện tại
            }

            // 2. Hash và cập nhật mật khẩu MỚI
            int workFactor = 12; // Đảm bảo dùng work factor chuẩn
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(changeRequest.NewPassword, workFactor);

            _context.Logins.Update(user);
            await _context.SaveChangesAsync();

            return true;
        }
        #endregion

        #region Nghiệp vụ Lấy Hồ sơ (ĐÃ CẬP NHẬT)

        /// <summary>
        /// Lấy thông tin hồ sơ (chi tiết) của người dùng (Student hoặc Lecturer)
        /// </summary>
        public async Task<object?> GetUserProfileAsync(ClaimsPrincipal userClaims)
        {
            var username = userClaims.FindFirstValue(ClaimTypes.NameIdentifier);
            var role = userClaims.FindFirstValue(ClaimTypes.Role);

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(role))
            {
                return null; // Token không hợp lệ
            }

            // Lấy thông tin Login (chung)
            var loginInfo = await _context.Logins
                .AsNoTracking()
                .Where(l => l.Username == username)
                .Select(l => new { l.Email, l.AccountStatus, l.CreatedAt })
                .FirstOrDefaultAsync();

            if (loginInfo == null) return null; // Không tìm thấy Login (lỗi token?)

            // --- KỊCH BẢN 1: LÀ SINH VIÊN ---
            if (role == "student")
            {
                // Truy vấn toàn bộ dữ liệu liên quan của Sinh viên
                var student = await _context.Students
                    .AsNoTracking() // Quan trọng: Chỉ đọc
                    .Include(s => s.StudentDetail) // Join StudentDetails (tên số ít do EF)
                    .Include(s => s.StudentIdentification) // Join StudentIdentification
                    .Include(s => s.FaceData) // Join FaceData (1-nhiều)
                    .Include(s => s.Enrollments) // Join Bảng N-N
                        .ThenInclude(e => e.ClassCodeNavigation) // Join Bảng Classes từ Enrollments
                    .Where(s => s.StudentCode == username)
                    .FirstOrDefaultAsync();

                if (student == null) return null; // Không có hồ sơ SV

                // Ánh xạ (Map) sang DTO chi tiết
                var fullProfile = new StudentProfileDto
                {
                    // Từ Login
                    Email = loginInfo.Email,
                    AccountStatus = loginInfo.AccountStatus ?? "N/A",
                    CreatedAt = loginInfo.CreatedAt,

                    // Từ Students (Bảng chính)
                    StudentCode = student.StudentCode,
                    FullName = student.FullName,
                    PhoneNumber = student.PhoneNumber,
                    DateOfBirth = student.DateOfBirth,
                    Gender = student.Gender,
                    AdminClass = student.AdminClass,
                    MajorName = student.MajorName,
                    IntakeYear = student.IntakeYear,
                    AdmissionDecision = student.AdmissionDecision,
                    AcademicStatus = student.AcademicStatus,
                    AcademicStatus1 = student.AcademicStatus1,

                    // Từ StudentDetail (Liên kết 1-1)
                    Details = student.StudentDetail == null ? null : new StudentDetailDto
                    {
                        Ethnicity = student.StudentDetail.Ethnicity,
                        Religion = student.StudentDetail.Religion,
                        ContactAddress = student.StudentDetail.ContactAddress,
                        FatherFullName = student.StudentDetail.FatherFullName,
                        FatherPhoneNumber = student.StudentDetail.FatherPhoneNumber,
                        MotherFullName = student.StudentDetail.MotherFullName,
                        MotherPhoneNumber = student.StudentDetail.MotherPhoneNumber
                    },

                    // Từ StudentIdentification (Liên kết 1-1)
                    Identification = student.StudentIdentification == null ? null : new StudentIdentificationDto
                    {
                        PlaceOfBirth = student.StudentIdentification.PlaceOfBirth,
                        NationalId = student.StudentIdentification.NationalId,
                        IdIssueDate = student.StudentIdentification.IdIssueDate,
                        IdIssuePlace = student.StudentIdentification.IdIssuePlace
                    },

                    // Từ FaceData (Liên kết 1-Nhiều)
                    // (Lọc FaceEmbedding để bảo mật)
                    FaceDataHistory = student.FaceData.Select(fd => new FaceDataDto
                    {
                        Id = fd.Id,
                        ImagePath = fd.ImagePath,
                        IsActive = fd.IsActive,
                        UploadStatus = fd.UploadStatus,
                        UploadedAt = fd.UploadedAt
                    }).ToList(),

                    // Từ Enrollments (Liên kết N-N)
                    Enrollments = student.Enrollments.Select(e => new EnrolledClassDto
                    {
                        ClassCode = e.ClassCode,
                        ClassName = e.ClassCodeNavigation?.ClassName, // Lấy tên lớp từ bảng Classes đã Join
                        EnrollmentStatus = e.EnrollmentStatus
                    }).ToList()
                };

                return fullProfile;
            }

            // --- KỊCH BẢN 2: LÀ GIẢNG VIÊN ---
            if (role == "lecturer")
            {
                // Truy vấn toàn bộ dữ liệu liên quan của Giảng viên
                var lecturer = await _context.Lecturers
                    .AsNoTracking()
                    .Include(l => l.DeptCodeNavigation) // Join Departments
                        .ThenInclude(d => d.FacultyCodeNavigation) // Join Faculties từ Departments
                    .Include(l => l.Classes) // Join Classes (các lớp GV dạy)
                    .Where(l => l.LecturerCode == username)
                    .FirstOrDefaultAsync();

                if (lecturer == null) return null; // Không có hồ sơ GV

                // Ánh xạ (Map) sang DTO chi tiết
                var fullProfile = new LecturerProfileDto
                {
                    // Từ Login
                    Email = loginInfo.Email,
                    AccountStatus = loginInfo.AccountStatus ?? "N/A",
                    CreatedAt = loginInfo.CreatedAt,

                    // Từ Lecturers (Bảng chính)
                    LecturerCode = lecturer.LecturerCode,
                    FullName = lecturer.FullName,
                    PhoneNumber = lecturer.PhoneNumber,
                    AvatarUrl = lecturer.AvatarUrl,
                    DateOfBirth = lecturer.DateOfBirth,
                    Gender = lecturer.Gender,
                    Degree = lecturer.Degree,
                    AcademicRank = lecturer.AcademicRank,
                    OfficeLocation = lecturer.OfficeLocation,

                    // Dữ liệu Join
                    DepartmentName = lecturer.DeptCodeNavigation?.DeptName,
                    FacultyName = lecturer.DeptCodeNavigation?.FacultyCodeNavigation?.FacultyName,

                    // Dữ liệu Join (1-Nhiều)
                    TaughtClassCodes = lecturer.Classes.Select(c => c.ClassCode).ToList()
                };

                return fullProfile;
            }

            // (Các role khác như 'admin_staff', 'dean_office'...)
            // Tạm thời trả về thông tin Login cơ bản
            if (role.Contains("admin") || role.Contains("office") || role.Contains("head"))
            {
                return new
                {
                    Username = username,
                    Role = role,
                    Email = loginInfo.Email,
                    AccountStatus = loginInfo.AccountStatus
                };
            }

            return null; // Role không xác định
        }

        #endregion

        #region Hàm Phụ trợ (Helper)

        /// <summary>
        /// Tạo JWT Token
        /// </summary>
        private string GenerateJwtToken(Login user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            // Đảm bảo Key không bị null
            var keyString = _configuration["Jwt:Key"] ?? throw new InvalidOperationException("Jwt:Key is not configured.");
            var key = Encoding.ASCII.GetBytes(keyString);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Username),
                new Claim(ClaimTypes.NameIdentifier, user.Username),
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Role, user.UserRole)
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddDays(7),
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        /// <summary>
        /// HÀM MỚI: Helper tự viết để lấy Work Factor từ hash
        /// (Dùng khi package BCrypt.Net quá cũ, không có GetWorkFactor())
        /// </summary>
        private int GetWorkFactorManually(string hash)
        {
            if (string.IsNullOrEmpty(hash)) return 0;

            try
            {
                // Định dạng hash: $2a$12$R9h/c.lG.4A...
                // Tách chuỗi bằng '$'
                var parts = hash.Split('$');
                if (parts.Length < 3)
                {
                    // Hash không hợp lệ, trả về 0
                    Console.WriteLine($"[GetWorkFactorManually] Invalid hash format.");
                    return 0;
                }
                // Lấy phần tử work factor (ví dụ: "12")
                return int.Parse(parts[2]);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"[GetWorkFactorManually] Error parsing hash: {ex.Message}");
                return 0; // Trả về 0 nếu có lỗi
            }
        }

        #endregion
    }
}