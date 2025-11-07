// File: MyTLUServer/Services/ReportingService.cs
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces; // (Import Interface)
using MyTLUServer.Infrastructure.Data; // (Import DbContext)
using MyTLUServer.Domain.Models; // (Import Models CSDL [cite: 618])
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using System;

namespace MyTLUServer.Application.Services
{
    public class ReportingService : IReportingService
    {
        private readonly AppDbContext _context; //

        public ReportingService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// (PKT) Xuất dữ liệu cấm thi
        /// </summary>
        public async Task<FileContentResult> ExportEligibilityAsync(List<string> classCodes, int minRate)
        {
            var resultBuilder = new StringBuilder();
            resultBuilder.AppendLine("StudentCode,FullName,ClassCode,TotalSessions,AttendedSessions,AttendanceRate,Status");

            var students = await _context.Enrollments
                .Where(e => classCodes.Contains(e.ClassCode))
                .Include(e => e.StudentCodeNavigation) 
                .Select(e => new { e.ClassCode, Student = e.StudentCodeNavigation })
                .Distinct()
                .ToListAsync();

            var sessions = await _context.ClassSessions
                .Where(s => classCodes.Contains(s.ClassCode) && s.SessionStatus == "completed")
                .AsNoTracking()
                .ToListAsync();

            var sessionIds = sessions.Select(s => s.Id);
            var attendance = await _context.AttendanceRecords
                .Where(a => sessionIds.Contains(a.ClassSessionId.Value))
                .AsNoTracking()
                .ToListAsync();

            foreach (var item in students)
            {
                if (item.Student == null) continue;
                var studentCode = item.Student.StudentCode;
                var classCode = item.ClassCode;
                var classSessionIds = sessions.Where(s => s.ClassCode == classCode).Select(s => s.Id);
                int totalSessions = classSessionIds.Count();
                if (totalSessions == 0) continue; 

                int attendedSessions = attendance
                    .Count(a => a.StudentCode == studentCode &&
                                classSessionIds.Contains(a.ClassSessionId.Value) &&
                                (a.AttendanceStatus == "present" || a.AttendanceStatus == "late" || a.AttendanceStatus == "excused"));

                double rate = (totalSessions == 0) ? 0 : (double)attendedSessions / totalSessions * 100;
                string status = (rate < minRate) ? "Ineligible" : "Eligible"; 

                if (status == "Ineligible") 
                {
                    resultBuilder.AppendLine($"{studentCode},{item.Student.FullName},{classCode},{totalSessions},{attendedSessions},{rate:F0}%,{status}");
                }
            }
            return new FileContentResult(Encoding.UTF8.GetBytes(resultBuilder.ToString()), "text/csv")
            {
                FileDownloadName = "DanhSachCamThi.csv"
            };
        }

        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp cho Bộ môn
        /// </summary>
        public async Task<DeptAttendanceSummaryDto> GetDepartmentSummaryAsync(string deptCode, string semester)
        {
            var department = await _context.Departments.FindAsync(deptCode);
            if (department == null) return null;

            // (Logic LINQ (Nguồn: 0) của bạn ở đây)
            // ...
            return new DeptAttendanceSummaryDto
            {
                DepartmentName = department.DeptName,
                // ... (Phần còn lại của logic (Nguồn: 0))
            };
        }

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cho Khoa
        /// </summary>
        public async Task<FacultyAttendanceSummaryDto> GetFacultySummaryAsync(string facultyCode, string semester)
        {
            var faculty = await _context.Faculties.FindAsync(facultyCode);
            if (faculty == null) return null;
            
            // ... (Logic LINQ (Nguồn: 0) của bạn ở đây)
            // ...
            return new FacultyAttendanceSummaryDto
            {
                FacultyName = faculty.FacultyName,
                // ... (Phần còn lại của logic (Nguồn: 0))
            };
        }

        /// <summary>
        /// (GV/Quản lý/SV) Lấy lịch sử các buổi học (có phân trang)
        /// (SỬA LỖI: Thay thế 'throw new NotImplementedException()')
        /// </summary>
        public async Task<PaginatedSessionHistoryDto> GetSessionHistoryAsync(ClaimsPrincipal user, DateOnly? startDate, DateOnly? endDate, string? lecturerCode, string? classCode, string? deptCode, int page, int pageSize)
        {
            // 1. Bắt đầu query
            var query = _context.ClassSessions
                .Include(s => s.ClassCodeNavigation)
                    .ThenInclude(c => c.LecturerCodeNavigation) // Class -> Lecturer
                .Include(s => s.ClassCodeNavigation)
                    .ThenInclude(c => c.Enrollments) // Class -> Enrollments (để đếm)
                .Include(s => s.AttendanceRecords) // Session -> AttendanceRecords (để đếm)
                .AsNoTracking();

            // 2. Lọc bảo mật (Security Filter)
            var userRole = user.FindFirstValue(ClaimTypes.Role);
            var username = user.FindFirstValue(ClaimTypes.NameIdentifier);

                if (userRole == "student") // [cite: 1156]
            {
                var enrolledClassCodes = await _context.Enrollments
                    .Where(e => e.StudentCode == username)
                    .Select(e => e.ClassCode)
                    .ToListAsync();
                query = query.Where(s => enrolledClassCodes.Contains(s.ClassCode));
            }
                else if (userRole == "lecturer") // [cite: 1157]
            {
                query = query.Where(s => s.ClassCodeNavigation.LecturerCode == username);
            }
                else if (userRole == "dept_head") // [cite: 1158]
            {
                var userDeptCode = (await _context.Lecturers.FindAsync(username))?.DeptCode;
                if (userDeptCode != null)
                {
                    query = query.Where(s => s.ClassCodeNavigation.LecturerCodeNavigation.DeptCode == userDeptCode);
                }
            }

            // 3. Lọc theo nghiệp vụ (User Filters)
            if (startDate.HasValue)
            {
                query = query.Where(s => s.SessionDate >= startDate.Value);
            }
            if (endDate.HasValue)
            {
               	query = query.Where(s => s.SessionDate <= endDate.Value);
            }
            if (!string.IsNullOrEmpty(lecturerCode))
            {
                query = query.Where(s => s.ClassCodeNavigation.LecturerCode == lecturerCode);
            }
            if (!string.IsNullOrEmpty(classCode))
            {
                query = query.Where(s => s.ClassCode == classCode);
            }
            if (!string.IsNullOrEmpty(deptCode))
            {
                query = query.Where(s => s.ClassCodeNavigation.LecturerCodeNavigation.DeptCode == deptCode);
            }

            // 4. Lấy tổng số (trước khi phân trang)
            int totalCount = await query.CountAsync();

            // 5. Phân trang
            var sessions = await query
                .OrderByDescending(s => s.SessionDate).ThenByDescending(s => s.StartTime)
                .Skip((page - 1) * pageSize)
                .Take(pageSize)
                .Select(s => new SessionHistoryItemDto //
                {
                    ClassSessionId = s.Id,
                    SessionTitle = s.Title ?? "N/A",
                    ClassCode = s.ClassCode,
                    ClassName = s.ClassCodeNavigation.ClassName,
                    LecturerName = s.ClassCodeNavigation.LecturerCodeNavigation.FullName,
                    SessionStart = s.SessionDate.Value.ToDateTime(s.StartTime.Value),
                    SessionStatus = s.SessionStatus,
                    TotalEnrolled = s.ClassCodeNavigation.Enrollments.Count(),
                    TotalPresent = s.AttendanceRecords.Count(a => a.AttendanceStatus == "present" || a.AttendanceStatus == "late")
                })
                .ToListAsync();

            // 6. Trả về kết quả
            return new PaginatedSessionHistoryDto
            {
                Page = page,
                PageSize = pageSize,
                TotalCount = totalCount,
                TotalPages = (int)Math.Ceiling(totalCount / (double)pageSize),
                Sessions = sessions
            };
        }
        
        // ==========================================================
        // === CÁC HÀM THỐNG KÊ (DÙNG _context) ===
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
                    AbsentCount = g.Count(r => r.AttendanceStatus == "absent"),
                    AttendanceRate = (g.Count() == 0) ? 0 : 
                        (double)(g.Count(r => r.AttendanceStatus == "present" || r.AttendanceStatus == "late") * 100) / g.Count()
                }).ToListAsync();
                
            return stats;
        }

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

        public async Task<IEnumerable<StudentAttendanceStatsDto>> GetStudentStatsInClassAsync(string classCode, string lecturerCode)
        {
            var ownsClass = await CheckLecturerOwnsClassAsync(classCode, lecturerCode);
            if (!ownsClass)
            {
                throw new UnauthorizedAccessException("Bạn không có quyền xem thống kê của lớp học này.");
            }

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

        private async Task<bool> CheckLecturerOwnsClassAsync(string classCode, string lecturerCode)
        {
            return await _context.Classes
                .AnyAsync(c => c.ClassCode == classCode && c.LecturerCode == lecturerCode);
        }
    }
}