using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Infrastructure.Data;
using MyTLUServer.Domain.Models;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System;
using Newtonsoft.Json;

namespace MyTLUServer.Application.Services
{
    public class SessionService : ISessionService
    {
        private readonly AppDbContext _context;

        public SessionService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// (Sinh viên) Lấy lịch học trong hôm nay
        /// </summary>
        public async Task<IEnumerable<MyScheduleDto>> GetMyScheduleAsync(string studentUsername)
        {
            var today = DateOnly.FromDateTime(DateTime.Today);

            // Lấy các lớp mà SV đã đăng ký
            var enrolledClassCodes = _context.Enrollments
                .Where(e => e.StudentCode == studentUsername)
                .Select(e => e.ClassCode);

            // Lấy các buổi học hôm nay của các lớp đó
            var schedule = await _context.ClassSessions
                .Where(s => enrolledClassCodes.Contains(s.ClassCode) && s.SessionDate == today)
                .Include(s => s.ClassCodeNavigation) // Join Classes
                .Select(s => new MyScheduleDto
                {
                    ClassSessionId = s.Id,
                    ClassName = s.ClassCodeNavigation.ClassName ?? s.Title ?? "N/A",
                    SessionTitle = s.Title ?? "Buổi học",
                    // Kết hợp DateOnly và TimeOnly
                    StartTime = s.SessionDate.Value.ToDateTime(s.StartTime.Value),
                    EndTime = s.SessionDate.Value.ToDateTime(s.EndTime.Value),
                    Location = s.SessionLocation ?? "N/A",
                    // Sub-query lấy trạng thái điểm danh
                    AttendanceStatus = _context.AttendanceRecords
                                        .Where(ar => ar.ClassSessionId == s.Id && ar.StudentCode == studentUsername)
                                        .Select(ar => ar.AttendanceStatus)
                                        .FirstOrDefault() ?? "pending"
                })
                .ToListAsync();

            return schedule;
        }
        
        /// /// <summary>
        /// (Sinh viên) Lấy lịch học theo ngày
        /// </summary>
        public async Task<IEnumerable<MyScheduleDto>> GetMyScheduleByDateAsync(string studentCode, DateTime selectedDate)
        {
            var dateToFind = DateOnly.FromDateTime(selectedDate);

            // 1. Lấy mã lớp SV đăng ký
            var myClassCodes = await _context.Enrollments
                .Where(e => e.StudentCode == studentCode && e.EnrollmentStatus == "enrolled")
                .Select(e => e.ClassCode)
                .Distinct() 
                .ToListAsync();

            // 2. Lấy session theo ngày
            var sessions = await _context.ClassSessions
                .Where(s => myClassCodes.Contains(s.ClassCode) && 
                            s.SessionDate.HasValue && // KIỂM TRA NULL
                            s.SessionDate.Value == dateToFind) // Lọc theo ngày
                .Include(s => s.ClassCodeNavigation) // Join Classes
                .OrderBy(s => s.StartTime) 
                .ToListAsync();

            // 3. Chuyển sang DTO (JSON) - AN TOÀN HƠN
            return sessions.Select(s => new MyScheduleDto
            {
                ClassSessionId = s.Id,
                
                // KIỂM TRA NULL (cho ClassName)
                ClassName = s.ClassCodeNavigation != null 
                                ? s.ClassCodeNavigation.ClassName 
                                : (s.Title ?? "N/A"),
                
                SessionTitle = s.Title ?? "Buổi học",
                
                // KIỂM TRA NULL (cho StartTime/EndTime)
                StartTime = (s.SessionDate.HasValue && s.StartTime.HasValue)
                                ? s.SessionDate.Value.ToDateTime(s.StartTime.Value)
                                : DateTime.MinValue, // Gán giá trị mặc định nếu null
                
                EndTime = (s.SessionDate.HasValue && s.EndTime.HasValue)
                                ? s.SessionDate.Value.ToDateTime(s.EndTime.Value)
                                : DateTime.MinValue, // Gán giá trị mặc định nếu null

                Location = s.SessionLocation ?? "N/A",
                
                // Sub-query (giữ nguyên)
                AttendanceStatus = _context.AttendanceRecords
                                    .Where(ar => ar.ClassSessionId == s.Id && ar.StudentCode == studentCode)
                                    .Select(ar => ar.AttendanceStatus)
                                    .FirstOrDefault() ?? "pending"
            });
        }
        


        /// <summary>
        /// Lấy chi tiết buổi học
        /// </summary>
        public async Task<ClassSessionDetailDto?> GetSessionDetailAsync(int sessionId)
        {
            var session = await _context.ClassSessions
                .Include(s => s.ClassCodeNavigation) // Join Classes
                    .ThenInclude(c => c.LecturerCodeNavigation) // Join Lecturers từ Classes
                .Where(s => s.Id == sessionId)
                .Select(s => new ClassSessionDetailDto
                {
                    Id = s.Id,
                    ClassName = s.ClassCodeNavigation.ClassName,
                    Title = s.Title,
                    StartTime = s.SessionDate.Value.ToDateTime(s.StartTime.Value),
                    EndTime = s.SessionDate.Value.ToDateTime(s.EndTime.Value),
                    Location = s.SessionLocation,
                    SessionStatus = s.SessionStatus,
                    LecturerName = s.ClassCodeNavigation.LecturerCodeNavigation.FullName
                })
                .FirstOrDefaultAsync();

            return session;
        }

        /// <summary>
        /// (Giảng viên) Mở điểm danh
        /// </summary>
        public async Task<StartAttendanceResponseDto> StartAttendanceAsync(int sessionId, string lecturerUsername)
        {
            var session = await _context.ClassSessions
                .Include(s => s.ClassCodeNavigation) // Join Classes
                .FirstOrDefaultAsync(s => s.Id == sessionId);

            if (session == null)
            {
                throw new Exception("Không tìm thấy buổi học.");
            }
            if (session.ClassCodeNavigation.LecturerCode != lecturerUsername)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền mở điểm danh cho buổi học này.");
            }

            // Tạo QR Token
            var qrToken = Guid.NewGuid().ToString();
            var qrData = new
            {
                sessionId = session.Id,
                qrToken = qrToken
            };

            // Cập nhật session
            session.QrCodeData = JsonConvert.SerializeObject(qrData);
            session.SessionStatus = "in_progress";

            await _context.SaveChangesAsync();

            return new StartAttendanceResponseDto
            {
                ClassSessionId = session.Id,
                QrData = session.QrCodeData,
                SessionStatus = session.SessionStatus,
                Message = "Đã mở điểm danh."
            };
        }

        /// <summary>
        /// (Giảng viên) Đóng điểm danh
        /// </summary>
        public async Task<bool> EndAttendanceAsync(int sessionId, string lecturerUsername)
        {
            var session = await _context.ClassSessions
                .Include(s => s.ClassCodeNavigation)
                .FirstOrDefaultAsync(s => s.Id == sessionId);

            if (session == null) return false;
            if (session.ClassCodeNavigation.LecturerCode != lecturerUsername) return false; // Không có quyền

            // Đóng buổi học
            session.SessionStatus = "completed";
            session.QrCodeData = null; // Vô hiệu hóa QR

            await _context.SaveChangesAsync();
            return true;
        }
    }
}