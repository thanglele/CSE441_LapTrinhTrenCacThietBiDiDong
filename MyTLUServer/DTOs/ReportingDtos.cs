using System.Collections.Generic;

namespace MyTLUServer.Application.DTOs
{
    // === DTOs cho Báo cáo (Reporting) ===

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


    // === DTOs cho Lịch sử Buổi học (Session History) ===

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
}