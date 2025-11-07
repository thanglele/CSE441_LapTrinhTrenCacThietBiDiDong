// File: MyTLUServer/Controllers/LecturerController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs; // (Import DTO)
using MyTLUServer.Interfaces;     // (Import Service Interface)
using System.Security.Claims;

namespace MyTLUServer.Controllers 
{
    [ApiController]
    [Route("api/v1/lecturer")]
    [Authorize(Roles = "lecturer")] // (Dựa theo API v3.0 (Source 209))
    public class LecturerController : ControllerBase
    {
        private readonly ILecturerDashboardService _dashboardService;

        // Tiêm (Inject) Service Interface
        public LecturerController(ILecturerDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        /// <summary>
        /// Lấy dữ liệu tổng hợp cho trang Dashboard của Giảng viên.
        /// </summary>
        [HttpGet("dashboard")] // -> GET /api/v1/lecturer/dashboard
        [ProducesResponseType(typeof(LecturerDashboardDto), 200)]
        [ProducesResponseType(401)] // Lỗi Token
        [ProducesResponseType(403)] // Lỗi Role
        public async Task<IActionResult> GetDashboard()
        {
            // Lấy mã Giảng viên (username) từ JWT Token đã xác thực
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode))
            {
                return Unauthorized();
            }

            // Gọi Service để thực hiện nghiệp vụ
            var dashboardData = await _dashboardService.GetDashboardDataAsync(lecturerCode);

            // Trả về dữ liệu DTO
            return Ok(dashboardData);
        }
        [HttpGet("my-subjects")]
        [ProducesResponseType(typeof(IEnumerable<LecturerSubjectDto>), 200)]
        [ProducesResponseType(401)]
        [ProducesResponseType(403)]
        public async Task<IActionResult> GetMySubjects()
        {
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode)) return Unauthorized();

            var subjects = await _dashboardService.GetSubjectsAsync(lecturerCode);
            return Ok(subjects);
        }

        [HttpGet("my-classes")]
        [ProducesResponseType(typeof(IEnumerable<LecturerClassDto>), 200)]
        [ProducesResponseType(401)]
        [ProducesResponseType(403)]
        public async Task<IActionResult> GetMyClasses()
        {
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode)) return Unauthorized();

            // (Sau này bạn có thể truyền filter/search params từ Query vào đây)
            var classes = await _dashboardService.GetClassesAsync(lecturerCode);
            return Ok(classes);
        }
        
        
    }
}