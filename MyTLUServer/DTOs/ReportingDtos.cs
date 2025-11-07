// File: MyTLUServer/DTOs/ReportingDtos.cs
using System.Collections.Generic;
using System; // (Thêm using cho DateTime)

namespace MyTLUServer.Application.DTOs
{
    // === DTOs cho Báo cáo (Reporting) (Nguồn: 0) ===

    /// <summary>
    /// Dùng cho GET /reports/department/{deptCode}/attendance-summary
    /// </summary>
    public class DeptAttendanceSummaryDto
    {
        public string DepartmentName { get; set; } = string.Empty;
        public int TotalClasses { get; set; }
        public string OverallAttendanceRate { get; set; } = string.Empty;
        public List<ClassAttendanceRateDto> Classes { get; set; } = new();
    }

    /// <summary>
    /// Dùng cho GET /reports/faculty/{facultyCode}/attendance-summary
    /// </summary>
    public class FacultyAttendanceSummaryDto
    {
        public string FacultyName { get; set; } = string.Empty;
        public int TotalClasses { get; set; }
        public string OverallAttendanceRate { get; set; } = string.Empty;
        public List<DeptAttendanceSummaryDto> Departments { get; set; } = new();
    }

    /// <summary>
    /// DTO con, tóm tắt tỉ lệ điểm danh của một lớp
    /// </summary>
    public class ClassAttendanceRateDto
    {
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string AttendanceRate { get; set; } = string.Empty;
    }

    // === DTOs cho Lịch sử Buổi học (Session History) (Nguồn: 0) ===

    /// <summary>
    /// DTO cho một item trong danh sách lịch sử buổi học
    /// </summary>
    public class SessionHistoryItemDto
    {
        public int ClassSessionId { get; set; }
        public string SessionTitle { get; set; } = string.Empty;
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string? LecturerName { get; set; }
        public System.DateTime SessionStart { get; set; } // Gộp Date + StartTime
        public string SessionStatus { get; set; } = string.Empty; // completed, cancelled, scheduled
        public int TotalEnrolled { get; set; } // Tổng số SV
        public int TotalPresent { get; set; } // Số SV đã điểm danh
    }

    /// <summary>
    /// DTO cho phản hồi (có phân trang)
    /// </summary>
    public class PaginatedSessionHistoryDto
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalCount { get; set; }
        public int TotalPages { get; set; }
        public List<SessionHistoryItemDto> Sessions { get; set; } = new();
    }

    /// <summary>
    /// DTO (Query Params) cho các bộ lọc của API /session-history (Nguồn: 0)
    /// </summary>
    public class SessionHistoryFilterDto
    {
        public DateTime? StartDate { get; set; }
        public DateTime? EndDate { get; set; } 
        public string? ClassCode { get; set; } 
        public string? LecturerCode { get; set; }
        public string? DeptCode { get; set; }
        public int Page { get; set; } = 1; 
        public int PageSize { get; set; } = 20;
    }

    // === DTOs cho Thống kê Giảng viên (Nguồn: 45) ===

    /// <summary>
    /// DTO (Chung) cho các loại Thống kê Tỷ lệ
    /// </summary>
    public class AttendanceRateStatsDto
    {
        public int TotalRecords { get; set; } // Tổng số lượt điểm danh
        public int PresentCount { get; set; } // Đúng giờ
        public int LateCount { get; set; } // Muộn
        public int AbsentCount { get; set; } // Vắng
        public double AttendanceRate { get; set; } // Tỷ lệ chung (%)
    }

    /// <summary>
    /// DTO cho Thống kê theo Môn học (API /stats/subjects)
    /// </summary>
    public class SubjectAttendanceStatsDto : AttendanceRateStatsDto
    {
        public string SubjectCode { get; set; } = null!;
        public string SubjectName { get; set; } = null!;
    }
    /// <summary>
    /// DTO cho Thống kê theo Lớp học (API /stats/classes)
    /// </summary>
    public class ClassAttendanceStatsDto : AttendanceRateStatsDto
    {
        public string ClassCode { get; set; } = null!;
        public string ClassName { get; set; } = null!;
    }
    /// <summary>
    /// DTO cho Thống kê Sinh viên trong 1 Lớp (API /stats/class/{classCode}/students)
    /// </summary>
    public class StudentAttendanceStatsDto : AttendanceRateStatsDto
    {
        public string StudentCode { get; set; } = null!;
        public string FullName { get; set; } = null!;
    }
}