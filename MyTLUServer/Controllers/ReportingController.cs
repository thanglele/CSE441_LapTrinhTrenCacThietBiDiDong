using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs; // Thêm DTOs
using MyTLUServer.Application.Interfaces;
using System.Collections.Generic;
using System.Threading.Tasks;

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

        /// <summary>
        /// (Phòng Khảo thí) Xuất dữ liệu điểm danh (danh sách SV cấm thi)
        /// </summary>
        [HttpGet("testing/eligibility-export")]
        [Authorize(Roles = "testing_office")]
        [ProducesResponseType(typeof(FileContentResult), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> GetEligibilityExport(
            [FromQuery(Name = "class_code")] List<string> classCodes,
            [FromQuery(Name = "min_rate")] int minRate = 70)
        {
            if (classCodes == null || classCodes.Count == 0)
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp ít nhất một class_code." });
            }

            var file = await _reportingService.ExportEligibilityAsync(classCodes, minRate);
            return file; // Trả về file Excel/CSV
        }

        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp điểm danh cho toàn bộ môn
        /// </summary>
        [HttpGet("department/{deptCode}/attendance-summary")]
        [Authorize(Roles = "dept_head")]
        [ProducesResponseType(typeof(DepartmentSummaryDto), 200)]
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
        [ProducesResponseType(typeof(FacultySummaryDto), 200)]
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
    }
}
