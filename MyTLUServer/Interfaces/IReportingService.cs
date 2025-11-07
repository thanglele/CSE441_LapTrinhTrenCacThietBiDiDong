// File: MyTLUServer/Interfaces/IReportingService.cs
using MyTLUServer.Application.DTOs; // (Import DTO (Nguồn: 0))
using System.Security.Claims;
using Microsoft.AspNetCore.Mvc; 
using System;
using System.Collections.Generic;

namespace MyTLUServer.Application.Interfaces // (Namespace từ file (Nguồn: 0))
{
    public interface IReportingService
    {
        // === CÁC HÀM CŨ TỪ FILE ReportingService.cs (Nguồn: 0) ===
        Task<FileContentResult> ExportEligibilityAsync(List<string> classCodes, int minRate);
        Task<DeptAttendanceSummaryDto> GetDepartmentSummaryAsync(string deptCode, string semester);
        Task<FacultyAttendanceSummaryDto> GetFacultySummaryAsync(string facultyCode, string semester);
        Task<PaginatedSessionHistoryDto> GetSessionHistoryAsync(ClaimsPrincipal user, DateOnly? startDate, DateOnly? endDate, string? lecturerCode, string? classCode, string? deptCode, int page, int pageSize);

        // === CÁC HÀM THỐNG KÊ MỚI (NGUỒN: 35) ===
        Task<IEnumerable<SubjectAttendanceStatsDto>> GetSubjectStatsAsync(string lecturerCode);
        Task<IEnumerable<ClassAttendanceStatsDto>> GetClassStatsAsync(string lecturerCode);
        Task<IEnumerable<StudentAttendanceStatsDto>> GetStudentStatsInClassAsync(string classCode, string lecturerCode);
    }
}