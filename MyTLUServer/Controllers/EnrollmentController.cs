// API/Controllers/EnrollmentController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Application.Exceptions;
using System.Security.Claims;
using System.Threading.Tasks;
using System.Collections.Generic; // Thêm using này

[ApiController]
[Route("api/v1/enrollment")]
[Authorize]
public class EnrollmentController : ControllerBase
{
    private readonly IEnrollmentService _enrollmentService;

    public EnrollmentController(IEnrollmentService enrollmentService)
    {
        _enrollmentService = enrollmentService;
    }

    // --- API CỦA SINH VIÊN ---

    /// <summary>
    /// (Sinh viên) Tải ảnh selfie (đã qua liveness check) lên để đăng ký
    /// </summary>
    [HttpPost("upload")]
    [Authorize(Roles = "student")]
    [ProducesResponseType(typeof(FaceUploadResponseDto), 201)]
    [ProducesResponseType(typeof(ErrorResponseDto), 400)]
    public async Task<IActionResult> UploadFace([FromBody] FaceUploadRequestDto request)
    {
        var studentUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(studentUsername)) return Unauthorized();

        try
        {
            var result = await _enrollmentService.UploadFaceDataAsync(request, studentUsername);
            return CreatedAtAction(nameof(UploadFace), result); // 201 Created
        }
        catch (Exception ex)
        {
            return BadRequest(new ErrorResponseDto { Message = ex.Message });
        }
    }

    // --- API CỦA GIẢNG VIÊN ---

    /// <summary>
    /// (Giảng viên) Lấy danh sách SV chờ duyệt...
    /// </summary>
    [HttpGet("review-list")]
    [Authorize(Roles = "lecturer")]
    [ProducesResponseType(typeof(IEnumerable<FaceReviewDto>), 200)]
    public async Task<IActionResult> GetReviewList([FromQuery] string class_code)
    {
        if (string.IsNullOrEmpty(class_code))
        {
            return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp class_code." });
        }
        var lecturerUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(lecturerUsername)) return Unauthorized();

        var list = await _enrollmentService.GetReviewListAsync(class_code, lecturerUsername);
        return Ok(list);
    }

    /// <summary>
    /// (Giảng viên / Trưởng Bộ môn) Duyệt hoặc từ chối...
    /// </summary>
    [HttpPost("verify")]
    [Authorize(Roles = "lecturer,dept_head")]
    [ProducesResponseType(typeof(object), 200)]
    public async Task<IActionResult> VerifyFace([FromBody] VerifyFaceRequestDto request)
    {
        var lecturerUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(lecturerUsername)) return Unauthorized();

        var success = await _enrollmentService.VerifyFaceDataAsync(request, lecturerUsername);
        if (!success) return Forbid();
        return Ok(new { message = "Cập nhật thành công.", newStatus = request.IsApproved ? "verified" : "rejected" });
    }

    // --- API CỦA P.QLSV (MASTER) ---

    /// <summary>
    /// (P.QLSV) Lấy TẤT CẢ các yêu cầu sinh trắc học đang chờ duyệt
    /// </summary>
    [HttpGet("all-pending")]
    [Authorize(Roles = "admin_staff")]
    [ProducesResponseType(typeof(IEnumerable<FaceReviewDto>), 200)]
    public async Task<IActionResult> GetAllPendingReview()
    {
        var list = await _enrollmentService.GetAllPendingReviewAsync();
        return Ok(list);
    }

    /// <summary>
    /// (P.QLSV / Trưởng BM) Thực hiện "duyệt" hoặc "từ chối" với quyền cao nhất
    /// </summary>
    [HttpPost("master-verify")]
    [Authorize(Roles = "admin_staff,dept_head")]
    [ProducesResponseType(typeof(object), 200)]
    public async Task<IActionResult> MasterVerify([FromBody] MasterVerifyRequestDto request)
    {
        var adminUsername = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(adminUsername)) return Unauthorized();

        var success = await _enrollmentService.MasterVerifyFaceDataAsync(request, adminUsername);
        if (!success)
        {
            return NotFound(new ErrorResponseDto { Message = "Không tìm thấy dữ liệu khuôn mặt." });
        }

        return Ok(new
        {
            message = "Xác thực (master) thành công.",
            newStatus = request.IsApproved ? "verified" : "rejected"
        });
    }
}