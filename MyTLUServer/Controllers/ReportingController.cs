// API/Controllers/ReportingController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs; // Cần DTOs
using MyTLUServer.Application.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;
using System; // Cần DateOnly

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/reports")]
    [Authorize] // Bảo vệ chung
    public class ReportingController : ControllerBase
    {
        private readonly IReportingService _reportingService;

        public ReportingController(IReportingService reportingService)
        {
            _reportingService = reportingService;
        }

        // --- (Các API Báo cáo khác của DeptHead, DeanOffice ở đây) ---
        // GET /department/{deptCode}/attendance-summary
        // GET /faculty/{facultyCode}/attendance-summary

        /// <summary>
        /// (Phòng Khảo thí) Xuất dữ liệu điểm danh (danh sách SV cấm thi)
        /// </summary>
        [HttpGet("testing/eligibility-export")]
        [Authorize(Roles = "testing_office")]
        [ProducesResponseType(typeof(FileContentResult), 200)]
        public async Task<IActionResult> GetEligibilityExport(
            [FromQuery(Name = "class_code")] List<string> classCodes,
            [FromQuery(Name = "min_rate")] int minRate = 70)
        {
            if (classCodes == null || classCodes.Count == 0)
            {
                return BadRequest(new { message = "Vui lòng cung cấp ít nhất một class_code." });
            }

            var file = await _reportingService.ExportEligibilityAsync(classCodes, minRate);
            return file; // Trả về file Excel/CSV
        }

        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp điểm danh cho toàn bộ môn
        /// </summary>
        [HttpGet("department/{deptCode}/attendance-summary")]
        [Authorize(Roles = "dept_head")]
        [ProducesResponseType(typeof(DeptAttendanceSummaryDto), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> GetDepartmentSummary(string deptCode, [FromQuery] string semester)
        {
            if (string.IsNullOrEmpty(semester))
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp 'semester'." });
            }

            var result = await _reportingService.GetDepartmentSummaryAsync(deptCode, semester);
            if (result == null) return NotFound();
            return Ok(result);
        }

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cho toàn khoa
        /// </summary>
        [HttpGet("faculty/{facultyCode}/attendance-summary")]
        [Authorize(Roles = "dean_office")]
        [ProducesResponseType(typeof(FacultyAttendanceSummaryDto), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> GetFacultySummary(string facultyCode, [FromQuery] string semester)
        {
            if (string.IsNullOrEmpty(semester))
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp 'semester'." });
            }

            var result = await _reportingService.GetFacultySummaryAsync(facultyCode, semester);
            if (result == null) return NotFound();
            return Ok(result);
        }

        /// <summary>
        /// (GV/Quản lý/SV) Lấy lịch sử các ca điểm danh (buổi học)
        /// </summary>
        [HttpGet("session-history")]
        // ĐÃ CẬP NHẬT: Thêm "student" vào Roles
        [Authorize(Roles = "student,lecturer,dept_head,dean_office,admin_staff,testing_office")]
        [ProducesResponseType(typeof(PaginatedSessionHistoryDto), 200)]
        public async Task<IActionResult> GetSessionHistory(
            [FromQuery] string? startDate, // "yyyy-MM-dd"
            [FromQuery] string? endDate,   // "yyyy-MM-dd"
            [FromQuery] string? lecturerCode,
            [FromQuery] string? classCode,
            [FromQuery] string? deptCode,
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            // Parse dates
            DateOnly? start = null;
            DateOnly? end = null;
            if (DateOnly.TryParse(startDate, out var sDate))
                start = sDate;
            if (DateOnly.TryParse(endDate, out var eDate))
                end = eDate;

            // Lấy thông tin user (để lọc quyền)
            var userClaims = HttpContext.User;

            var result = await _reportingService.GetSessionHistoryAsync(
                userClaims, start, end, lecturerCode, classCode, deptCode, page, pageSize
            );

            return Ok(result);
        }
    }
}