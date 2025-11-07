// File: MyTLUServer/Data/Repositories/ReportingRepository.cs
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Interfaces;
using MyTLUServer.Domain.Models; 
using MyTLUServer.Infrastructure.Data; 
using MyTLUServer.Application.DTOs;
using System.Linq;
using System.Security.Claims;
using System; // (Thêm using cho DateTime)
using System.Collections.Generic; // (Thêm using cho IEnumerable)

namespace MyTLUServer.Data.Repositories 
{
    public class ReportingRepository : IReportingRepository
    {
        private readonly AppDbContext _context; 

        public ReportingRepository(AppDbContext context)
        {
            _context = context;
        }

        // (Hàm cũ (Nguồn: 44) - bạn có thể dán code LINQ (Nguồn: 0) của mình vào đây)
        public Task<PaginatedSessionHistoryDto> GetSessionHistoryAsync(ClaimsPrincipal user, SessionHistoryFilterDto filter)
        {
            throw new NotImplementedException(); 
        }

        // ==========================================================
        // === HÀM 1: THỐNG KÊ MÔN HỌC (ĐÃ SỬA LỖI CS1003 (Nguồn: 0)) ===
        // ==========================================================
        public async Task<IEnumerable<SubjectAttendanceStatsDto>> GetSubjectStatsAsync(string lecturerCode)
        {
            var records = from ar in _context.AttendanceRecords
                          join cs in _context.ClassSessions on ar.ClassSessionId equals cs.Id
                          join c in _context.Classes on cs.ClassCode equals c.ClassCode
                          join s in _context.Subjects on c.SubjectCode equals s.SubjectCode
                          where c.LecturerCode == lecturerCode && cs.SessionStatus == "completed"
                          select new { Subject = s, ar.AttendanceStatus };

            var stats = await records
                .GroupBy(r => r.Subject)
                .Select(g => new SubjectAttendanceStatsDto
                {
                    SubjectCode = g.Key.SubjectCode,
                    SubjectName = g.Key.SubjectName,
                    TotalRecords = g.Count(),
                    PresentCount = g.Count(r => r.AttendanceStatus == "present"), 
                    LateCount = g.Count(r => r.AttendanceStatus == "late"), 
                    // === SỬA LỖI CS1003 (Nguồn: 0): Xóa dấu '_' ở dòng dưới ===
                    AbsentCount = g.Count(r => r.AttendanceStatus == "absent"), 
                    AttendanceRate = (g.Count() == 0) ? 0 :
                        (double)(g.Count(r => r.AttendanceStatus == "present" || r.AttendanceStatus == "late") * 100) / g.Count()
                }).ToListAsync();

            return stats;
        }

        // ==========================================================
        // === HÀM 2: THỐNG KÊ LỚP HỌC ===
        // ==========================================================
        public async Task<IEnumerable<ClassAttendanceStatsDto>> GetClassStatsAsync(string lecturerCode)
        {
            var records = from ar in _context.AttendanceRecords
                          join cs in _context.ClassSessions on ar.ClassSessionId equals cs.Id
                          join c in _context.Classes on cs.ClassCode equals c.ClassCode
                          where c.LecturerCode == lecturerCode && cs.SessionStatus == "completed" 
                          select new { Class = c, ar.AttendanceStatus };

            var stats = await records
                .GroupBy(r => r.Class)
                .Select(g => new ClassAttendanceStatsDto
                {
                    ClassCode = g.Key.ClassCode,
                    ClassName = g.Key.ClassName,
                    TotalRecords = g.Count(),
                    PresentCount = g.Count(r => r.AttendanceStatus == "present"), 
                    LateCount = g.Count(r => r.AttendanceStatus == "late"), 
                    AbsentCount = g.Count(r => r.AttendanceStatus == "absent"), 
                    AttendanceRate = (g.Count() == 0) ? 0 : 
                        (double)(g.Count(r => r.AttendanceStatus == "present" || r.AttendanceStatus == "late") * 100) / g.Count()
                }).ToListAsync();
                
            return stats;
        }

        // ==========================================================
        // === HÀM 3: THỐNG KÊ SINH VIÊN ===
        // ==========================================================
        public async Task<IEnumerable<StudentAttendanceStatsDto>> GetStudentStatsInClassAsync(string classCode)
        {
            var studentsInClass = await (from e in _context.Enrollments
                                         join s in _context.Students on e.StudentCode equals s.StudentCode
                                         where e.ClassCode == classCode
                                         select s).ToListAsync();
            
            var allRecordsInClass = await (from ar in _context.AttendanceRecords
                                           join cs in _context.ClassSessions on ar.ClassSessionId equals cs.Id
                                           where cs.ClassCode == classCode && cs.SessionStatus == "completed"
                                           select ar).ToListAsync();

            var stats = studentsInClass
                .Select(s => {
                    var studentRecords = allRecordsInClass.Where(ar => ar.StudentCode == s.StudentCode).ToList();
                    var total = studentRecords.Count;
                    var present = studentRecords.Count(ar => ar.AttendanceStatus == "present");
                    var late = studentRecords.Count(ar => ar.AttendanceStatus == "late");
                    
                    return new StudentAttendanceStatsDto
                    {
                        StudentCode = s.StudentCode,
                        FullName = s.FullName,
                        TotalRecords = total,
                        PresentCount = present,
                        LateCount = late,
                        AbsentCount = studentRecords.Count(ar => ar.AttendanceStatus == "absent"),
                        AttendanceRate = (total == 0) ? 0 : (double)((present + late) * 100) / total
                    };
                }).ToList();
                
            return stats;
        }
    }
}