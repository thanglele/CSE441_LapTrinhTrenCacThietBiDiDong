// API/Controllers/AttendanceController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using System.Security.Claims;
using System.Threading.Tasks;
using MyTLUServer.Application.Exceptions;

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/attendance")]
    [Authorize]
    public class AttendanceController : ControllerBase
    {
        private readonly IAttendanceService _attendanceService;

        public AttendanceController(IAttendanceService attendanceService)
        {
            _attendanceService = attendanceService;
        }

        [HttpPost("check-in")]
        [Authorize(Roles = "student")]
        [ProducesResponseType(typeof(CheckInResponseDto), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        [ProducesResponseType(typeof(ErrorResponseDto), 401)]
        [ProducesResponseType(typeof(ErrorResponseDto), 403)]
        public async Task<IActionResult> CheckIn([FromBody] CheckInRequestDto request)
        {
            if (string.IsNullOrEmpty(request.ClientGpsCoordinates))
            {
                return BadRequest(new ErrorResponseDto { Message = "Không thể lấy tọa độ GPS. Vui lòng bật định vị." });
            }

            var studentUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(studentUsername)) return Unauthorized(); // Thêm kiểm tra null

            var clientIpAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "::1";

            try
            {
                var result = await _attendanceService.CheckInAsync(request, studentUsername, clientIpAddress);
                return Ok(result);
            }
            catch (SessionInvalidException ex) { return BadRequest(new ErrorResponseDto { Message = ex.Message }); }
            catch (FaceMismatchException ex) { return Unauthorized(new ErrorResponseDto { Message = ex.Message }); }
            catch (BiometricNotVerifiedException ex) { return StatusCode(403, new ErrorResponseDto { Message = ex.Message }); }
            catch (Exception ex) { return StatusCode(500, new ErrorResponseDto { Message = ex.Message }); }
        }

        [HttpGet("history/{classCode}")]
        [Authorize(Roles = "student")]
        [ProducesResponseType(typeof(IEnumerable<AttendanceHistoryDto>), 200)]
        public async Task<IActionResult> GetAttendanceHistory(string classCode)
        {
            var studentUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(studentUsername)) return Unauthorized(); // Thêm kiểm tra null

            var history = await _attendanceService.GetAttendanceHistoryAsync(classCode, studentUsername);
            return Ok(history);
        }

        [HttpGet("session-report/{sessionId}")]
        [Authorize(Roles = "lecturer,dept_head,dean_office,testing_office")]
        [ProducesResponseType(typeof(SessionReportDto), 200)]
        public async Task<IActionResult> GetSessionReport(int sessionId)
        {
            var report = await _attendanceService.GetSessionReportAsync(sessionId);
            if (report == null) return NotFound();
            return Ok(report);
        }

        [HttpPut("manual-update")]
        [Authorize(Roles = "lecturer,dept_head")]
        [ProducesResponseType(typeof(object), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 403)]
        public async Task<IActionResult> ManualUpdate([FromBody] ManualUpdateRequestDto request)
        {
            var lecturerUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerUsername)) return Unauthorized(); // Thêm kiểm tra null

            // SỬA TÊN HÀM TỪ ManualUpdateAsync -> ManualUpdateAttendanceAsync
            var success = await _attendanceService.ManualUpdateAttendanceAsync(request, lecturerUsername);

            if (!success)
            {
                return StatusCode(403, new ErrorResponseDto { Message = "Không thể cập nhật hoặc không có quyền." });
            }
            return Ok(new { message = "Cập nhật thành công." });
        }
    }
}