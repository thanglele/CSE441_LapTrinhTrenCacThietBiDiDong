// API/Controllers/SessionController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Application.Exceptions;
using System.Security.Claims;
using System.Threading.Tasks;

[ApiController]
[Route("api/v1/sessions")]
[Authorize]
public class SessionController : ControllerBase
{
    private readonly ISessionService _sessionService;

    public SessionController(ISessionService sessionService)
    {
        _sessionService = sessionService;
    }

    /// <summary>
    /// (Sinh viên) Lấy lịch học của sinh viên trong hôm nay
    /// </summary>
    [HttpGet("my-schedule")]
    [Authorize(Roles = "student")] // Chỉ Sinh viên
    [ProducesResponseType(typeof(IEnumerable<MyScheduleDto>), 200)]
    public async Task<IActionResult> GetMySchedule()
    {
        var studentUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        var schedule = await _sessionService.GetMyScheduleAsync(studentUsername);
        return Ok(schedule);
    }

    // --- CÁC ENDPOINT CHUNG VÀ CỦA GIẢNG VIÊN (đã code) ---

    /// <summary>
    /// Lấy thông tin chi tiết một buổi học
    /// </summary>
    [HttpGet("{sessionId}")]
    [Authorize(Roles = "student,lecturer,dept_head,dean_office")]
    public async Task<IActionResult> GetSessionDetail(int sessionId)
    {
        var detail = await _sessionService.GetSessionDetailAsync(sessionId);
        if (detail == null) return NotFound();
        return Ok(detail);
    }

    /// <summary>
    /// (Giảng viên) Mở điểm danh...
    /// </summary>
    [HttpPost("{sessionId}/start-attendance")]
    [Authorize(Roles = "lecturer")]
    public async Task<IActionResult> StartAttendance(int sessionId)
    {
        var lecturerUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        try
        {
            var result = await _sessionService.StartAttendanceAsync(sessionId, lecturerUsername);
            return Ok(result);
        }
        catch (UnauthorizedAccessException ex)
        {
            return StatusCode(403, new ErrorResponseDto { Message = ex.Message });
        }
    }

    /// <summary>
    /// (Giảng viên) Đóng điểm danh...
    /// </summary>
    [HttpPost("{sessionId}/end-attendance")]
    [Authorize(Roles = "lecturer")]
    public async Task<IActionResult> EndAttendance(int sessionId)
    {
        var lecturerUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        var success = await _sessionService.EndAttendanceAsync(sessionId, lecturerUsername);
        if (!success)
        {
            return StatusCode(403, new ErrorResponseDto { Message = "Bạn không có quyền đóng buổi học này." });
        }
        return Ok(new { message = "Buổi học đã kết thúc." });
    }
}