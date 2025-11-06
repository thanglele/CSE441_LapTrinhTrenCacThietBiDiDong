using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Infrastructure.Data;
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
        private readonly AppDbContext _context;

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

            // Lấy danh sách SV của các lớp này
            var students = await _context.Enrollments
                .Where(e => classCodes.Contains(e.ClassCode))
                .Include(e => e.StudentCodeNavigation) // Join Students
                .Select(e => new { e.ClassCode, Student = e.StudentCodeNavigation })
                .Distinct()
                .ToListAsync();

            // Lấy TẤT CẢ buổi học đã hoàn thành của các lớp này
            var sessions = await _context.ClassSessions
                .Where(s => classCodes.Contains(s.ClassCode) && s.SessionStatus == "completed")
                .AsNoTracking()
                .ToListAsync();

            // Lấy TẤT CẢ record điểm danh của các buổi học này
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

                // Lọc session và attendance cho đúng SV và Lớp
                var classSessionIds = sessions.Where(s => s.ClassCode == classCode).Select(s => s.Id);
                int totalSessions = classSessionIds.Count();
                if (totalSessions == 0) continue; // Bỏ qua nếu lớp chưa có buổi học nào hoàn thành

                int attendedSessions = attendance
                    .Count(a => a.StudentCode == studentCode &&
                                classSessionIds.Contains(a.ClassSessionId.Value) &&
                                (a.AttendanceStatus == "present" || a.AttendanceStatus == "late" || a.AttendanceStatus == "excused"));

                double rate = (double)attendedSessions / totalSessions * 100;
                string status = (rate < minRate) ? "Ineligible" : "Eligible"; // Ineligible = Cấm thi

                if (status == "Ineligible") // Chỉ xuất SV cấm thi
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

            // TODO: Cần logic phân tích chuỗi 'semester' (ví dụ: "2024-2025_HK1")
            // Tạm thời lấy tất cả
            var classes = await _context.Classes
                .Where(c => c.SubjectCodeNavigation.DeptCode == deptCode) // Lọc lớp theo Bộ môn của Môn học
                .Include(c => c.Enrollments)
                .Include(c => c.ClassSessions)
                    .ThenInclude(cs => cs.AttendanceRecords)
                .AsNoTracking()
                .ToListAsync();

            var classSummaries = new List<ClassAttendanceRateDto>();
            long totalExpected = 0;
            long totalAttended = 0;

            foreach (var cls in classes)
            {
                var completedSessionIds = cls.ClassSessions.Where(cs => cs.SessionStatus == "completed").Select(cs => cs.Id);
                int totalStudents = cls.Enrollments.Count();
                int totalSessions = completedSessionIds.Count();

                if (totalStudents == 0 || totalSessions == 0) continue;

                long classExpected = totalStudents * totalSessions;
                long classAttended = cls.ClassSessions
                    .SelectMany(cs => cs.AttendanceRecords)
                    .Count(ar => (ar.AttendanceStatus == "present" || ar.AttendanceStatus == "late" || ar.AttendanceStatus == "excused"));

                totalExpected += classExpected;
                totalAttended += classAttended;

                classSummaries.Add(new ClassAttendanceRateDto
                {
                    ClassCode = cls.ClassCode,
                    ClassName = cls.ClassName,
                    AttendanceRate = (classExpected == 0) ? "0%" : $"{(double)classAttended / classExpected * 100:F0}%"
                });
            }

            return new DeptAttendanceSummaryDto
            {
                DepartmentName = department.DeptName,
                TotalClasses = classes.Count(),
                OverallAttendanceRate = (totalExpected == 0) ? "0%" : $"{(double)totalAttended / totalExpected * 100:F0}%",
                Classes = classSummaries
            };
        }

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cho Khoa
        /// </summary>
        public async Task<FacultyAttendanceSummaryDto> GetFacultySummaryAsync(string facultyCode, string semester)
        {
            var faculty = await _context.Faculties.FindAsync(facultyCode);
            if (faculty == null) return null;

            var departments = await _context.Departments
                .Where(d => d.FacultyCode == facultyCode)
                .ToListAsync();

            var deptSummaries = new List<DeptAttendanceSummaryDto>();
            foreach (var dept in departments)
            {
                var deptSummary = await GetDepartmentSummaryAsync(dept.DeptCode, semester);
                if (deptSummary != null)
                {
                    deptSummaries.Add(deptSummary);
                }
            }

            // Tính toán tổng hợp cho Khoa
            int totalClasses = deptSummaries.Sum(d => d.TotalClasses);
            // (Cần logic tính OverallAttendanceRate cấp khoa - Tạm bỏ qua)

            return new FacultyAttendanceSummaryDto
            {
                FacultyName = faculty.FacultyName,
                TotalClasses = totalClasses,
                OverallAttendanceRate = "N/A", // Cần logic tính toán phức tạp hơn
                Departments = deptSummaries
            };
        }

        /// <summary>
        /// (GV/Quản lý/SV) Lấy lịch sử các buổi học (có phân trang)
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

            if (userRole == "student")
            {
                // SINH VIÊN: Chỉ thấy các lớp mình đã đăng ký
                var enrolledClassCodes = await _context.Enrollments
                    .Where(e => e.StudentCode == username)
                    .Select(e => e.ClassCode)
                    .ToListAsync();
                query = query.Where(s => enrolledClassCodes.Contains(s.ClassCode));
            }
            else if (userRole == "lecturer")
            {
                // Giảng viên chỉ thấy lớp của mình
                query = query.Where(s => s.ClassCodeNavigation.LecturerCode == username);
            }
            else if (userRole == "dept_head")
            {
                // Trưởng bộ môn thấy các lớp trong bộ môn của mình
                var userDeptCode = (await _context.Lecturers.FindAsync(username))?.DeptCode;
                if (userDeptCode != null)
                {
                    query = query.Where(s => s.ClassCodeNavigation.LecturerCodeNavigation.DeptCode == userDeptCode);
                }
            }
            // DeanOffice, AdminStaff, TestingOffice... có thể xem tất cả (không lọc)


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
                .Select(s => new SessionHistoryItemDto
                {
                    ClassSessionId = s.Id,
                    SessionTitle = s.Title ?? "N/A",
                    ClassCode = s.ClassCode,
                    ClassName = s.ClassCodeNavigation.ClassName,
                    LecturerName = s.ClassCodeNavigation.LecturerCodeNavigation.FullName,
                    SessionStart = s.SessionDate.Value.ToDateTime(s.StartTime.Value),
                    SessionStatus = s.SessionStatus,
                    // Đếm số SV trong lớp (từ bảng Enrollments)
                    TotalEnrolled = s.ClassCodeNavigation.Enrollments.Count(),
                    // Đếm số SV đã điểm danh (tGhi chú: ừ bảng AttendanceRecords)
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
    }
}