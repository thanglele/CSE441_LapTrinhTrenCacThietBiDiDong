// File: MyTLUServer/Controllers/LecturerController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs; 
using MyTLUServer.Application.Interfaces; // <-- Sửa 1: Đảm bảo đúng namespace Interface
using MyTLUServer.Interfaces;
using MyTLUServerInterfaces;
using System.Security.Claims;
// (Xóa 'using MyTLUServer.Services;' và 'using MyTLUServerInterfaces;' vì chúng sai namespace)

namespace MyTLUServer.Controllers 
{
    [ApiController]
    [Route("api/v1/lecturer")]
    [Authorize(Roles = "lecturer")] 
    public class LecturerController : ControllerBase
    {
        private readonly ILecturerDashboardService _dashboardService;
        private readonly ILecturerService _lecturerService; // <-- Sửa 2: Thêm Service còn thiếu

        // Sửa 3: Tiêm (Inject) cả 2 Service
        public LecturerController(
            ILecturerDashboardService dashboardService, 
            ILecturerService lecturerService)
        {
            _dashboardService = dashboardService;
            _lecturerService = lecturerService; // <-- Thêm dòng này
        }

        /// <summary>
        /// Lấy dữ liệu tổng hợp cho trang Dashboard của Giảng viên.
        /// </summary>
        [HttpGet("dashboard")] 
        [ProducesResponseType(typeof(LecturerDashboardDto), 200)]
        [ProducesResponseType(401)] 
        [ProducesResponseType(403)] 
        public async Task<IActionResult> GetDashboard()
        {
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode))
            {
                return Unauthorized();
            }
            var dashboardData = await _dashboardService.GetDashboardDataAsync(lecturerCode);
            return Ok(dashboardData);
        }

        /// <summary>
        /// (Giảng viên) Lấy danh sách môn học GV đang dạy (image_222364.png)
        /// </summary>
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

        /// <summary>
        /// (Giảng viên) Lấy danh sách lớp học phần GV đang dạy (image_222385.png)
        /// </summary>
        [HttpGet("my-classes")]
        [ProducesResponseType(typeof(IEnumerable<LecturerClassDto>), 200)]
        [ProducesResponseType(401)]
        [ProducesResponseType(403)]
        public async Task<IActionResult> GetMyClasses()
        {
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode)) return Unauthorized();

            var classes = await _dashboardService.GetClassesAsync(lecturerCode);
            return Ok(classes);
        }

        /// <summary>
        /// (Giảng viên) Lấy danh sách SV trong 1 lớp cụ thể (image_2223e5.png)
        /// </summary>
        [HttpGet("classes/{classCode}/students")]
        [ProducesResponseType(typeof(IEnumerable<LecturerStudentDto>), 200)]
        public async Task<IActionResult> GetStudentsInClass(string classCode)
        {
            // (TODO: Thêm kiểm tra bảo mật)
            
            // Sửa 4: Gọi hàm qua biến _lecturerService (non-static)
            var students = await _lecturerService.GetStudentsInClassAsync(classCode);
            return Ok(students);
        }

        /// <summary>
        /// (Giảng viên) Gửi yêu cầu thêm SV vào lớp với trạng thái "pending" (image_222420.png)
        /// </summary>
        [HttpPost("classes/{classCode}/request-enrollment")]
        [ProducesResponseType(typeof(LecturerStudentDto), 201)] 
        [ProducesResponseType(403)] 
        [ProducesResponseType(404)] 
        [ProducesResponseType(409)] 
        public async Task<IActionResult> RequestStudentEnrollment(string classCode, [FromBody] LecturerEnrollmentRequestDto request)
        {
            var lecturerCode = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(lecturerCode)) return Unauthorized();

            try
            {
                // Sửa 5: Gọi hàm qua biến _lecturerService (non-static)
                var studentDto = await _lecturerService.RequestStudentEnrollmentAsync(classCode, request.StudentCode, lecturerCode);

                // Trả về 201 Created (Kèm theo thông tin SV vừa được yêu cầu)
                return CreatedAtAction(nameof(GetStudentsInClass), new { classCode = classCode }, studentDto);
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
            catch (InvalidOperationException ex)
            {
                return Conflict(new { message = ex.Message }); // 409 Conflict
            }
            catch (UnauthorizedAccessException ex)
            {
                return StatusCode(403, new { message = ex.Message });
            }
        }
    }
}