using System.Collections.Generic;

namespace MyTLUServer.Application.DTOs
{
    /// <summary>
    /// Dùng cho GET /reports/department/{deptCode}/attendance-summary
    /// </summary>
    public class DepartmentSummaryDto
    {
        public string DepartmentName { get; set; } = string.Empty;
        public int TotalClasses { get; set; }
        public string OverallAttendanceRate { get; set; } = string.Empty;
        public List<ClassAttendanceSummaryDto> Classes { get; set; } = new();
    }

    public class ClassAttendanceSummaryDto
    {
        public string ClassCode { get; set; } = string.Empty;
        public string ClassName { get; set; } = string.Empty;
        public string AttendanceRate { get; set; } = string.Empty;
    }

    /// <summary>
    /// Dùng cho GET /reports/faculty/{facultyCode}/attendance-summary
    /// </summary>
    public class FacultySummaryDto
    {
        public string FacultyName { get; set; } = string.Empty;
        public int TotalClasses { get; set; }
        public string OverallAttendanceRate { get; set; } = string.Empty;
        public List<DepartmentSummaryDto> Departments { get; set; } = new();
    }
}