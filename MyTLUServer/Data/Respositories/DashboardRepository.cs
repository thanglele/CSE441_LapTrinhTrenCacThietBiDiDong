// File: MyTLUServer/Data/Repositories/DashboardRepository.cs
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Interfaces; // (Hoặc MyTLUServer.Application.Interfaces)
using MyTLUServer.Domain.Models; // (Hoặc MyTLUServer.Models)
using MyTLUServer.Infrastructure.Data; // (Hoặc MyTLUServer.Data)
using MyTLUServer.Application.DTOs; // (Import DTO)
using System.Linq;

namespace MyTLUServer.Infrastructure.Data.Repositories // (Namespace theo cấu trúc của bạn)
{
    public class DashboardRepository : IDashboardRepository
    {
        private readonly AppDbContext _context; // (Giả định DbContext của bạn)

        public DashboardRepository(AppDbContext context)
        {
            _context = context;
        }

        // 1. GetClassCountAsync (Giữ nguyên)
        public async Task<int> GetClassCountAsync(string lecturerCode)
        {
            return await _context.Classes
                .CountAsync(c => c.LecturerCode == lecturerCode);
        }

        // 2. GetStudentCountAsync (Sửa lỗi 'Enrollment' does not contain 'Class')
        public async Task<int> GetStudentCountAsync(string lecturerCode)
        {
            var query = from e in _context.Enrollments
                        join c in _context.Classes 
                            on e.ClassCode equals c.ClassCode
                        where c.LecturerCode == lecturerCode
                        select e.StudentCode;
            
            return await query.Distinct().CountAsync();
        }

        // 3. GetTodaySessionsAsync (Sửa lỗi 'DateOnly' và 'TimeOnly')
        public async Task<IEnumerable<ScheduleSessionDto>> GetTodaySessionsAsync(string lecturerCode, DateTime today)
        {
            var todayAsDateOnly = DateOnly.FromDateTime(today);
            
            return await (from cs in _context.ClassSessions
                          join c in _context.Classes on cs.ClassCode equals c.ClassCode
                          where c.LecturerCode == lecturerCode &&
                                cs.SessionDate == todayAsDateOnly
                          select new ScheduleSessionDto 
                          {
                              ClassSessionId = cs.Id,
                              ClassName = c.ClassName,
                              SessionTitle = cs.Title,
                              // Sửa lỗi (Nguồn: image_17425b.png): Dùng new DateTime()
                              StartTime = (cs.SessionDate.HasValue && cs.StartTime.HasValue) 
                                          ? new DateTime(cs.SessionDate.Value, cs.StartTime.Value) 
                                          : DateTime.MinValue,
                              EndTime = (cs.SessionDate.HasValue && cs.EndTime.HasValue)
                                          ? new DateTime(cs.SessionDate.Value, cs.EndTime.Value)
                                          : DateTime.MinValue,
                              Location = cs.SessionLocation,
                              AttendanceStatus = cs.SessionStatus
                          }).ToListAsync();
        }

        // 4. GetTeachingClassesAsync (Sửa: Map sang DTO)
        public async Task<IEnumerable<TeachingClassDto>> GetTeachingClassesAsync(string lecturerCode)
        {
            return await _context.Classes
                .Where(c => c.LecturerCode == lecturerCode)
                .Select(c => new TeachingClassDto 
                {
                    ClassCode = c.ClassCode,
                    ClassName = c.ClassName,
                    Tag = $"{c.MaxStudents} SV"
                }).ToListAsync();
        }

        // 5. GetRecentAttendanceAsync (Sửa lỗi 'DateOnly?' to 'DateTime')
        public async Task<IEnumerable<RecentAttendanceDto>> GetRecentAttendanceAsync(string lecturerCode, int limit = 5)
        {
            return await (from ar in _context.AttendanceRecords
                          join cs in _context.ClassSessions on ar.ClassSessionId equals cs.Id
                          join c in _context.Classes on cs.ClassCode equals c.ClassCode
                          join s in _context.Subjects on c.SubjectCode equals s.SubjectCode
                          where c.LecturerCode == lecturerCode
                          orderby ar.CheckInTime descending
                          select new RecentAttendanceDto
                          {
                              Subject = s.SubjectName,
                              ClassCode = c.ClassCode,
                              SessionTitle = cs.Title,

                              // === SỬA LỖI (Nguồn: image_17463a.png) ===
                              // Chuyển đổi 'DateOnly?' sang 'DateTime'
                              SessionDate = cs.SessionDate.HasValue
                                            ? cs.SessionDate.Value.ToDateTime(TimeOnly.MinValue)
                                            : DateTime.MinValue,
                              // =========================

                              CheckInTime = ar.CheckInTime != null ? ar.CheckInTime.Value.ToString("HH:mm") : null,
                              PresentCount = 0, // (Tạm thời, cần logic đếm)
                              AttendanceRate = "0%" // (Tạm thời, cần logic đếm)
                          }).Take(limit).ToListAsync();
        }
        public async Task<IEnumerable<LecturerSubjectDto>> GetSubjectsAsync(string lecturerCode)
        {
            // Lấy các môn học (subjects) mà GV này dạy (Nguồn: 618)
            var subjects = from c in _context.Classes
                           join s in _context.Subjects on c.SubjectCode equals s.SubjectCode
                           where c.LecturerCode == lecturerCode
                           select new LecturerSubjectDto
                           {
                               SubjectCode = s.SubjectCode,
                               SubjectName = s.SubjectName,
                               Credits = s.Credits,
                               Description = s.Description
                           };
            
            // Dùng Distinct() để đảm bảo mỗi môn học chỉ xuất hiện 1 lần
            return await subjects.Distinct().ToListAsync();
        }
    }
}