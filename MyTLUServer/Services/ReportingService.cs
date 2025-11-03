using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Application.DTOs; // Thêm DTOs
using MyTLUServer.Infrastructure.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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

            // Lấy TẤT CẢ buổi học của các lớp này
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
                if (totalSessions == 0) continue;

                int attendedSessions = attendance
                    .Count(a => a.StudentCode == studentCode &&
                                classSessionIds.Contains(a.ClassSessionId.Value) &&
                                (a.AttendanceStatus == "present" || a.AttendanceStatus == "late" || a.AttendanceStatus == "excused"));

                double rate = (double)attendedSessions / totalSessions * 100;
                string status = (rate < minRate) ? "Ineligible" : "Eligible";

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

        // --- PHẦN MỚI ĐƯỢC THÊM ---

        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp cấp Bộ môn
        /// </summary>
        public async Task<DepartmentSummaryDto?> GetDepartmentSummaryAsync(string deptCode, string semester)
        {
            // TODO: Triển khai logic thật
            // Tạm thời trả về dữ liệu giả lập
            var department = await _context.Departments.FindAsync(deptCode);
            if (department == null) return null;

            var mockSummary = new DepartmentSummaryDto
            {
                DepartmentName = department.DeptName,
                TotalClasses = 30,
                OverallAttendanceRate = "85.2%",
                Classes = new List<ClassAttendanceSummaryDto>
                {
                    new ClassAttendanceSummaryDto { ClassCode = "IT123", ClassName = "Lập trình Web", AttendanceRate = "90%" },
                    new ClassAttendanceSummaryDto { ClassCode = "IT456", ClassName = "Cơ sở dữ liệu", AttendanceRate = "80%" }
                }
            };

            return await Task.FromResult(mockSummary);
        }

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cấp Khoa
        /// </summary>
        public async Task<FacultySummaryDto?> GetFacultySummaryAsync(string facultyCode, string semester)
        {
            // TODO: Triển khai logic thật
            // Tạm thời trả về dữ liệu giả lập
            var faculty = await _context.Faculties.FindAsync(facultyCode);
            if (faculty == null) return null;

            var mockSummary = new FacultySummaryDto
            {
                FacultyName = faculty.FacultyName,
                TotalClasses = 150,
                OverallAttendanceRate = "88.0%",
                Departments = new List<DepartmentSummaryDto>
                {
                    await GetDepartmentSummaryAsync("IT", semester), // Tái sử dụng hàm trên (nếu deptCode là "IT")
                    // ... Thêm các bộ môn khác
                }
            };

            return await Task.FromResult(mockSummary);
        }
        // --- KẾT THÚC PHẦN MỚI ---
    }
}