using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models;
using MyTLUServer.Infrastructure.Data;
using System;
using System.Linq;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    public class AcademicService : IAcademicService
    {
        private readonly AppDbContext _context;

        public AcademicService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// (PĐT) Tạo lớp học phần mới
        /// </summary>
        public async Task<Class> CreateClassAsync(Class classData)
        {
            if (await _context.Classes.AnyAsync(c => c.ClassCode == classData.ClassCode))
            {
                throw new InvalidOperationException("Lớp học với mã này đã tồn tại.");
            }
            _context.Classes.Add(classData);
            await _context.SaveChangesAsync();
            return classData;
        }

        /// <summary>
        /// (PĐT) Cập nhật lớp học phần
        /// </summary>
        public async Task<bool> UpdateClassAsync(string classCode, Class classData)
        {
            var existingClass = await _context.Classes.FindAsync(classCode);
            if (existingClass == null)
            {
                return false; // Không tìm thấy
            }

            // Ánh xạ các trường
            existingClass.ClassName = classData.ClassName;
            existingClass.SubjectCode = classData.SubjectCode;
            existingClass.LecturerCode = classData.LecturerCode;
            existingClass.AcademicYear = classData.AcademicYear;
            existingClass.Semester = classData.Semester;
            existingClass.MaxStudents = classData.MaxStudents;
            existingClass.ClassStartDate = classData.ClassStartDate;
            existingClass.ClassEndDate = classData.ClassEndDate;
            existingClass.ScheduleSummary = classData.ScheduleSummary;
            existingClass.DefaultLocation = classData.DefaultLocation;
            existingClass.ClassType = classData.ClassType;
            existingClass.ClassStatus = classData.ClassStatus;

            _context.Classes.Update(existingClass);
            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// (PĐT) Thêm/Xóa sinh viên khỏi lớp
        /// </summary>
        public async Task<bool> UpdateClassEnrollmentAsync(string classCode, UpdateEnrollmentRequestDto request)
        {
            var classExists = await _context.Classes.AnyAsync(c => c.ClassCode == classCode);
            var studentExists = await _context.Students.AnyAsync(s => s.StudentCode == request.StudentCode);

            if (!classExists || !studentExists)
            {
                return false; // Lớp hoặc SV không tồn tại
            }

            if (request.Action.ToLower() == "add")
            {
                var exists = await _context.Enrollments
                    .AnyAsync(e => e.ClassCode == classCode && e.StudentCode == request.StudentCode);
                if (!exists)
                {
                    _context.Enrollments.Add(new Enrollment
                    {
                        ClassCode = classCode,
                        StudentCode = request.StudentCode,
                        EnrollmentStatus = "enrolled"
                    });
                }
            }
            else if (request.Action.ToLower() == "remove")
            {
                var enrollment = await _context.Enrollments
                    .FirstOrDefaultAsync(e => e.ClassCode == classCode && e.StudentCode == request.StudentCode);
                if (enrollment != null)
                {
                    _context.Enrollments.Remove(enrollment);
                }
            }

            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// (PĐT) Tự động tạo các buổi học cho học kỳ
        /// </summary>
        public async Task<GenerateSessionsResponseDto> GenerateSessionsForClassAsync(string classCode)
        {
            var classInfo = await _context.Classes.FindAsync(classCode);
            if (classInfo == null || !classInfo.ClassStartDate.HasValue)
            {
                return new GenerateSessionsResponseDto { Message = "Lớp học không tồn tại hoặc chưa có ngày bắt đầu." };
            }

            // Giả định 1 học kỳ có 15 buổi, mỗi tuần 1 buổi
            int totalSessions = 15;
            var newSessions = new List<ClassSession>();
            var startDate = classInfo.ClassStartDate.Value.ToDateTime(new TimeOnly(0, 0)); // Chuyển DateOnly sang DateTime

            // Giả định giờ học (cần logic phức tạp hơn để đọc ScheduleSummary)
            var startTime = new TimeOnly(7, 0, 0); // 7:00 AM
            var endTime = new TimeOnly(9, 30, 0); // 9:30 AM

            for (int i = 0; i < totalSessions; i++)
            {
                var sessionDate = startDate.AddDays(i * 7); // Mỗi tuần 1 buổi
                newSessions.Add(new ClassSession
                {
                    ClassCode = classCode,
                    Title = $"Buổi học #{i + 1}",
                    SessionDate = DateOnly.FromDateTime(sessionDate),
                    StartTime = startTime,
                    EndTime = endTime,
                    SessionLocation = classInfo.DefaultLocation,
                    SessionStatus = "scheduled"
                });
            }

            await _context.ClassSessions.AddRangeAsync(newSessions);
            await _context.SaveChangesAsync();

            return new GenerateSessionsResponseDto
            {
                Message = $"Đã tạo thành công {totalSessions} buổi học cho lớp {classCode}.",
                SessionsCreated = totalSessions
            };
        }
    }
}