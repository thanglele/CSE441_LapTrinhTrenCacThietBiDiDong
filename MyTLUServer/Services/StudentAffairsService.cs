// Application/Services/StudentAffairsService.cs
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Infrastructure.Data;
using MyTLUServer.Domain.Models;
using System.Threading.Tasks;
using System.IO;

namespace MyTLUServer.Application.Services
{
    public class StudentAffairsService : IStudentAffairsService
    {
        private readonly AppDbContext _context;
        private readonly IFileStorageService _storageService;
        private readonly IFaceRecognitionService _faceService;

        public StudentAffairsService(
            AppDbContext context,
            IFileStorageService storageService,
            IFaceRecognitionService faceService)
        {
            _context = context;
            _storageService = storageService;
            _faceService = faceService;
        }

        /// <summary>
        /// (MỚI) (P.QLSV) Tạo sinh viên mới (Nhập học)
        /// </summary>
        public async Task<Student> CreateStudentAsync(CreateStudentDto dto)
        {
            // 1. Kiểm tra (Validation)
            if (await _context.Logins.AnyAsync(l => l.Username == dto.StudentCode || l.Email == dto.Email))
            {
                throw new InvalidOperationException("Mã Sinh viên (Username) hoặc Email đã tồn tại.");
            }

            // 2. Dùng Transaction để đảm bảo tạo đồng bộ 4 bảng
            await using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                // 3. Tạo tài khoản Login (bảng Login)
                var newLogin = new Login
                {
                    Username = dto.StudentCode,
                    Email = dto.Email,
                    UserRole = "student",
                    PasswordHash = null, // SV sẽ tự đặt mật khẩu lần đầu qua flow "Quên mật khẩu"
                    AccountStatus = "active",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Logins.Add(newLogin);

                // 4. Tạo hồ sơ Sinh viên (bảng Students)
                var newStudent = new Student
                {
                    StudentCode = dto.StudentCode,
                    FullName = dto.FullName,
                    PhoneNumber = dto.PhoneNumber,
                    DateOfBirth = dto.DateOfBirth,
                    Gender = dto.Gender,
                    AdminClass = dto.AdminClass,
                    MajorName = dto.MajorName,
                    IntakeYear = dto.IntakeYear,
                    AdmissionDecision = dto.AdmissionDecision,
                    AcademicStatus = dto.AcademicStatus,
                    AcademicStatus1 = dto.AcademicStatus1
                };
                _context.Students.Add(newStudent);

                // 5. (Tùy chọn) Tạo hồ sơ chi tiết (bảng StudentDetails)
                var newStudentDetail = new StudentDetail
                {
                    StudentCode = dto.StudentCode,
                    Ethnicity = dto.Ethnicity,
                    Religion = dto.Religion,
                    ContactAddress = dto.ContactAddress,
                    FatherFullName = dto.FatherFullName,
                    FatherPhoneNumber = dto.FatherPhoneNumber,
                    MotherFullName = dto.MotherFullName,
                    MotherPhoneNumber = dto.MotherPhoneNumber
                };
                _context.StudentDetails.Add(newStudentDetail);

                // 6. (Tùy chọn) Tạo hồ sơ định danh (bảng StudentIdentification)
                var newStudentId = new StudentIdentification
                {
                    StudentCode = dto.StudentCode,
                    PlaceOfBirth = dto.PlaceOfBirth,
                    NationalId = dto.NationalId,
                    IdIssueDate = dto.IdIssueDate,
                    IdIssuePlace = dto.IdIssuePlace
                };
                _context.StudentIdentifications.Add(newStudentId);

                // 7. Lưu và Commit
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return newStudent;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                // Ghi log (ex)
                throw new Exception("Đã xảy ra lỗi trong quá trình tạo sinh viên.", ex);
            }
        }


        /// <summary>
        /// (P.QLSV) Lấy hồ sơ chi tiết của sinh viên
        /// </summary>
        public async Task<StudentFullProfileDto?> GetStudentFullProfileAsync(string studentCode)
        {
            var student = await _context.Students
                .AsNoTracking()
                .Include(s => s.StudentDetail) // Sửa: Tên navigation property là số ít
                .Include(s => s.StudentIdentification)
                .Where(s => s.StudentCode == studentCode)
                .FirstOrDefaultAsync();

            if (student == null) return null;

            return new StudentFullProfileDto
            {
                StudentCode = student.StudentCode,
                FullName = student.FullName,
                PhoneNumber = student.PhoneNumber,
                DateOfBirth = student.DateOfBirth,
                Gender = student.Gender,
                AdminClass = student.AdminClass,
                MajorName = student.MajorName,
                AcademicStatus = student.AcademicStatus,

                // Sửa: Dùng tên số ít
                Ethnicity = student.StudentDetail?.Ethnicity,
                Religion = student.StudentDetail?.Religion,
                ContactAddress = student.StudentDetail?.ContactAddress,

                PlaceOfBirth = student.StudentIdentification?.PlaceOfBirth,
                NationalId = student.StudentIdentification?.NationalId,
                IdIssueDate = student.StudentIdentification?.IdIssueDate,
                IdIssuePlace = student.StudentIdentification?.IdIssuePlace
            };
        }

        /// <summary>
        /// Tạo Vector Gốc (sơ khai)
        /// </summary>
        public async Task<ProfilePhotoUploadResponseDto> UpdateProfilePhotoAsync(string studentCode, IFormFile imageFile)
        {
            var student = await _context.Students.FindAsync(studentCode);
            if (student == null)
            {
                throw new Exception("Không tìm thấy sinh viên.");
            }

            // 1. Lưu ảnh vào thư mục (ví dụ: wwwroot/images/profiles/123456.jpg)
            var imageUrl = await _storageService.SaveFileAsync(imageFile, "profiles", studentCode);

            // 2. Cập nhật URL ảnh vào bảng Students (Cần thêm cột 'profile_image_url')
            // student.ProfileImageUrl = imageUrl; 
            // _context.Students.Update(student);

            // 3. Tạo Vector Gốc (Embedding)
            string embedding;
            using (var memoryStream = new MemoryStream())
            {
                await imageFile.CopyToAsync(memoryStream);
                var imageBase64 = Convert.ToBase64String(memoryStream.ToArray());
                embedding = await _faceService.GenerateEmbeddingAsync(imageBase64);
            }

            // 4. Vô hiệu hóa tất cả vector cũ
            var oldFaceData = await _context.FaceData
                .Where(fd => fd.StudentCode == studentCode && fd.IsActive == true)
                .ToListAsync();
            oldFaceData.ForEach(fd => fd.IsActive = false);

            // 5. Tạo bản ghi FaceData GỐC mới
            var newFaceData = new FaceDatum // Sửa: Dùng FaceDatum
            {
                StudentCode = studentCode,
                ImagePath = imageUrl, // Lưu URL ảnh gốc
                FaceEmbedding = embedding,
                IsActive = true,
                UploadStatus = "verified", // Trạng thái "đã duyệt" vì do P.QLSV upload
                UploadedAt = DateTime.UtcNow
                // (Trường Notes đã bị xóa khỏi CSDL)
            };
            _context.FaceData.Add(newFaceData);

            await _context.SaveChangesAsync();

            return new ProfilePhotoUploadResponseDto
            {
                ImageUrl = imageUrl
            };
        }
    }
}