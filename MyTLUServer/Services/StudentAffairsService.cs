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

        public async Task<StudentFullProfileDto?> GetStudentFullProfileAsync(string studentCode)
        {
            var student = await _context.Students
                .AsNoTracking()
                // SỬA LỖI CS1061: StudentDetails -> StudentDetail
                .Include(s => s.StudentDetail)
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

                // SỬA LỖI CS1061: StudentDetails -> StudentDetail
                Ethnicity = student.StudentDetail?.Ethnicity,
                Religion = student.StudentDetail?.Religion,
                ContactAddress = student.StudentDetail?.ContactAddress,

                PlaceOfBirth = student.StudentIdentification?.PlaceOfBirth,
                NationalId = student.StudentIdentification?.NationalId,
                IdIssueDate = student.StudentIdentification?.IdIssueDate,
                IdIssuePlace = student.StudentIdentification?.IdIssuePlace
            };
        }

        public async Task<ProfilePhotoUploadResponseDto> UpdateProfilePhotoAsync(string studentCode, IFormFile imageFile)
        {
            var student = await _context.Students.FindAsync(studentCode);
            if (student == null)
            {
                throw new Exception("Không tìm thấy sinh viên.");
            }

            var imageUrl = await _storageService.SaveFileAsync(imageFile, "profiles", studentCode);

            // (Vẫn giữ comment: Bạn cần thêm cột 'profile_image_url' vào bảng Students)
            // student.ProfileImageUrl = imageUrl; 
            // _context.Students.Update(student);

            string embedding;
            using (var memoryStream = new MemoryStream())
            {
                await imageFile.CopyToAsync(memoryStream);
                var imageBase64 = Convert.ToBase64String(memoryStream.ToArray());
                embedding = await _faceService.GenerateEmbeddingAsync(imageBase64);
            }

            var oldFaceData = await _context.FaceData
                .Where(fd => fd.StudentCode == studentCode && fd.IsActive == true)
                .ToListAsync();
            oldFaceData.ForEach(fd => fd.IsActive = false);

            // SỬA LỖI CS0246: FaceData -> FaceDatum
            var newFaceData = new FaceDatum
            {
                StudentCode = studentCode,
                ImagePath = imageUrl,
                FaceEmbedding = embedding,
                IsActive = true,
                UploadStatus = "verified",
                UploadedAt = DateTime.UtcNow
                // SỬA LỖI CS1061: Xóa trường 'Notes'
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