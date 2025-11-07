// File: MyTLUServer/Data/Repositories/LecturerRepository.cs
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Interfaces;
using MyTLUServer.Domain.Models;
using MyTLUServer.Data; // (Namespace chứa DbContext)
using MyTLUServer.Application.DTOs;

using System.Linq;
using MyTLUServer.Infrastructure.Data;

namespace MyTLUServer.Data.Repositories 
{
    public class LecturerRepository : ILecturerRepository
    {
        private readonly AppDbContext _context; // (Giả định DbContext của bạn)

        public LecturerRepository(AppDbContext context)
        {
            _context = context;
        }

        // 1. (API 1) Lấy danh sách SV
        public async Task<IEnumerable<LecturerStudentDto>> GetStudentsInClassAsync(string classCode)
        {
            var students = from e in _context.Enrollments
                           join s in _context.Students on e.StudentCode equals s.StudentCode
                           join l in _context.Logins on s.StudentCode equals l.Username
                           join fd in _context.FaceData on s.StudentCode equals fd.StudentCode into faceDataGroup
                           from fd in faceDataGroup.DefaultIfEmpty()
                           where e.ClassCode == classCode
                           select new LecturerStudentDto
                           {
                               StudentCode = s.StudentCode,
                               FullName = s.FullName,
                               Email = l.Email, // Lấy Email từ bảng Login (Nguồn: 618)
                               PhoneNumber = s.PhoneNumber,
                               MajorName = s.MajorName,
                               AdminClass = s.AdminClass,
                               FaceDataStatus = (fd == null) ? "none" : fd.UploadStatus, // (Nguồn: 618)
                               EnrollmentStatus = e.EnrollmentStatus // (pending, enrolled) (Nguồn: 618)
                           };

            return await students.ToListAsync();
        }

        // 2. (API 2) Hàm bảo mật
        public async Task<bool> CheckLecturerOwnsClassAsync(string classCode, string lecturerCode)
        {
            return await _context.Classes
                .AnyAsync(c => c.ClassCode == classCode && c.LecturerCode == lecturerCode);
        }

        // 3. (API 2) Hàm tạo yêu cầu "pending"
        public async Task<Enrollment> RequestStudentEnrollmentAsync(string classCode, string studentCode)
        {
            var studentExists = await _context.Students.AnyAsync(s => s.StudentCode == studentCode);
            var classExists = await _context.Classes.AnyAsync(c => c.ClassCode == classCode);
            if (!studentExists || !classExists)
            {
                throw new KeyNotFoundException("Không tìm thấy sinh viên hoặc lớp học.");
            }

            var existingEnrollment = await _context.Enrollments
                .FirstOrDefaultAsync(e => e.ClassCode == classCode && e.StudentCode == studentCode);

            if (existingEnrollment != null)
            {
                if (existingEnrollment.EnrollmentStatus == "withdrawn")
                {
                    existingEnrollment.EnrollmentStatus = "pending"; // (Trạng thái chờ duyệt)
                    await _context.SaveChangesAsync();
                    return existingEnrollment;
                }
                throw new InvalidOperationException("Sinh viên đã có trong lớp hoặc đang chờ duyệt.");
            }

            var newEnrollment = new Enrollment
            {
                StudentCode = studentCode,
                ClassCode = classCode,
                EnrollmentStatus = "pending" // "chờ duyệt" (Nguồn: 618)
            };
            
            _context.Enrollments.Add(newEnrollment);
            await _context.SaveChangesAsync();
            return newEnrollment;
        }

        // 4. (API 2) Hàm lấy chi tiết SV (để trả về sau khi POST)
        public async Task<LecturerStudentDto> GetStudentDetailsAsync(string studentCode)
        {
            var studentDto = await (from s in _context.Students
                                    join l in _context.Logins on s.StudentCode equals l.Username
                                    join fd in _context.FaceData on s.StudentCode equals fd.StudentCode into faceDataGroup
                                    from fd in faceDataGroup.DefaultIfEmpty()
                                    where s.StudentCode == studentCode
                                    select new LecturerStudentDto
                                    {
                                        StudentCode = s.StudentCode,
                                        FullName = s.FullName,
                                        Email = l.Email,
                                        PhoneNumber = s.PhoneNumber,
                                        MajorName = s.MajorName,
                                        AdminClass = s.AdminClass,
                                        FaceDataStatus = (fd == null) ? "none" : fd.UploadStatus,
                                        EnrollmentStatus = "pending" // (Vì vừa được request)
                                    }).FirstOrDefaultAsync();
            return studentDto;
        }
    }
}