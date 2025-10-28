// API/Controllers/ReportingController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
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
    }
}