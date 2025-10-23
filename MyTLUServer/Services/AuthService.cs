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

namespace MyTLUServer.Application.Services
{
    /// <summary>
    /// Triển khai các dịch vụ liên quan đến xác thực và quản lý tài khoản.
    /// </summary>
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

        /// <summary>
        /// Xử lý đăng nhập
        /// </summary>
        public async Task<LoginResponseDto> LoginAsync(LoginRequestDto loginRequest)
        {
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == loginRequest.Username);

            if (user == null || user.AccountStatus != "active")
            {
                // Không tìm thấy hoặc tài khoản bị khóa
                return null;
            }

            // Kịch bản 1: Mật khẩu chưa được thiết lập (lần đăng nhập đầu tiên)
            if (string.IsNullOrEmpty(user.PasswordHash))
            {
                // Ném ra exception đặc biệt để Controller bắt và trả về mã lỗi 428
                throw new PasswordNotSetException();
            }

            // Kịch bản 2: Xác thực mật khẩu
            bool isValid = false;
            try
            {
                isValid = BCrypt.Net.BCrypt.Verify(loginRequest.Password, user.PasswordHash);
            }
            catch (Exception ex)
            {
                // Ghi log lỗi (ví dụ: hash không hợp lệ, salt có vấn đề)
                Console.WriteLine($"Password verification error for user {user.Username}: {ex.Message}");
                isValid = false;
            }

            if (!isValid)
            {
                return null; // Sai mật khẩu
            }

            // Tạo token nếu mật khẩu hợp lệ
            var token = GenerateJwtToken(user);
            return new LoginResponseDto
            {
                Token = token,
                UserRole = user.UserRole
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
                // Không tìm thấy user, hoặc user không có email, hoặc tài khoản bị khóa
                // Luôn trả về true để tránh lộ thông tin (security practice)
                // Kẻ tấn công không biết được username/email nào là hợp lệ
                return true;
            }

            // Tạo OTP ngẫu nhiên 6 chữ số
            var otp = new Random().Next(100000, 999999).ToString();

            // Lưu OTP vào cache, key là username
            var cacheEntryOptions = new MemoryCacheEntryOptions()
                .SetAbsoluteExpiration(TimeSpan.FromMinutes(5)); // Hết hạn sau 5 phút
            _cache.Set(otpRequest.Username, otp, cacheEntryOptions);

            // Gửi email
            // !!! THAY ĐỔI Ở ĐÂY !!!
            // Xóa 2 dòng cũ:
            // var subject = "MyTLU - Mã OTP Đặt Lại Mật Khẩu";
            // var body = $"Mã OTP của bạn là: {otp}. Mã này sẽ hết hạn sau 5 phút.";

            // Gọi phương thức mới (đã bao gồm template HTML)
            await _emailService.SendOtpEmailAsync(user.Email, otp);
            // !!! KẾT THÚC THAY ĐỔI !!!

            return true;
        }

        /// <summary>
        /// Xác thực OTP và đặt lại mật khẩu mới
        /// </summary>
        public async Task<bool> ResetPasswordAsync(ResetPasswordRequestDto resetRequest)
        {
            // 1. Kiểm tra OTP
            if (!_cache.TryGetValue(resetRequest.Username, out string cachedOtp))
            {
                // OTP hết hạn hoặc không tồn tại (do nhập sai username)
                return false;
            }

            if (cachedOtp != resetRequest.Otp)
            {
                return false; // Sai OTP
            }

            // 2. Tìm User
            var user = await _context.Logins
                .FirstOrDefaultAsync(u => u.Username == resetRequest.Username);

            if (user == null)
            {
                // Lỗi (hiếm khi xảy ra nếu OTP tồn tại, trừ khi user bị xóa)
                return false;
            }

            // 3. Hash mật khẩu mới
            // Sử dụng BCrypt để hash mật khẩu
            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(resetRequest.NewPassword);

            // 4. Lưu vào DB
            _context.Logins.Update(user);
            await _context.SaveChangesAsync();

            // 5. Xóa OTP khỏi cache (vì đã được sử dụng)
            _cache.Remove(resetRequest.Username);

            return true;
        }

        #endregion

        #region Nghiệp vụ Lấy Hồ sơ

        /// <summary>
        /// Lấy thông tin hồ sơ của người dùng (Student hoặc Lecturer)
        /// </summary>
        public async Task<object> GetUserProfileAsync(ClaimsPrincipal userClaims)
        {
            var username = userClaims.FindFirstValue(ClaimTypes.NameIdentifier);
            var role = userClaims.FindFirstValue(ClaimTypes.Role);

            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(role))
            {
                return null; // Token không hợp lệ
            }

            // Phân luồng dựa trên vai trò
            if (role == "student")
            {
                var studentProfile = await _context.Students
                    .Where(s => s.StudentCode == username)
                    .Select(s => new StudentProfileDto
                    {
                        StudentCode = s.StudentCode,
                        FullName = s.FullName,
                        AdminClass = s.AdminClass,
                        MajorName = s.MajorName,
                        // Thực hiện sub-query để lấy trạng thái face_data mới nhất
                        FaceDataStatus = _context.FaceData
                            .Where(fd => fd.StudentCode == username)
                            .OrderByDescending(fd => fd.UploadedAt) // Lấy bản ghi mới nhất
                            .Select(fd => fd.UploadStatus)
                            .FirstOrDefault() ?? "none" // "none" nếu chưa có bản ghi nào
                    })
                    .FirstOrDefaultAsync();

                return studentProfile;
            }

            if (role == "lecturer")
            {
                var lecturerProfile = await _context.Lecturers
                    .Include(l => l.DeptCodeNavigation) // Join với bảng Department
                    .Where(l => l.LecturerCode == username)
                    .Select(l => new LecturerProfileDto
                    {
                        LecturerCode = l.LecturerCode,
                        FullName = l.FullName,
                        DepartmentName = l.DeptCodeNavigation != null ? l.DeptCodeNavigation.DeptName : "N/A",
                        Degree = l.Degree
                    })
                    .FirstOrDefaultAsync();

                return lecturerProfile;
            }

            // (Có thể mở rộng cho các role khác như 'admin_staff'...)

            return null; // Không phải role student hay lecturer
        }

        #endregion

        #region Hàm Phụ trợ (Helper)

        /// <summary>
        /// Tạo JWT Token
        /// </summary>
        private string GenerateJwtToken(Login user)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(_configuration["Jwt:Key"]);

            var claims = new[]
            {
                new Claim(JwtRegisteredClaimNames.Sub, user.Username),
                new Claim(ClaimTypes.NameIdentifier, user.Username), // Thêm NameIdentifier để dễ truy xuất
                new Claim(JwtRegisteredClaimNames.Email, user.Email ?? string.Empty),
                new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
                new Claim(ClaimTypes.Role, user.UserRole) // Thêm vai trò
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddDays(7), // Token hết hạn sau 7 ngày
                Issuer = _configuration["Jwt:Issuer"],
                Audience = _configuration["Jwt:Audience"],
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }

        #endregion
    }
}