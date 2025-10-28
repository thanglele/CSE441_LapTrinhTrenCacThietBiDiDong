// API/Controllers/DeanController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models; // Cần Model 'Lecturer'
using System.Threading.Tasks;

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/dean")]
    [Authorize(Roles = "dean_office")] // Chỉ VP Khoa/Trưởng Khoa
    public class DeanController : ControllerBase
    {
        private readonly IDeanService _deanService;

        public DeanController(IDeanService deanService)
        {
            _deanService = deanService;
        }

        /// <summary>
        /// Lấy danh sách tất cả Giảng viên (có thể lọc theo Bộ môn)
        /// </summary>
        [HttpGet("lecturers")]
        [ProducesResponseType(typeof(IEnumerable<LecturerListItemDto>), 200)]
        public async Task<IActionResult> GetAllLecturers([FromQuery] string? departmentCode = null)
        {
            var lecturers = await _deanService.GetAllLecturersAsync(departmentCode);
            return Ok(lecturers);
        }

        /// <summary>
        /// Lấy thông tin chi tiết của một Giảng viên
        /// </summary>
        [HttpGet("lecturers/{lecturerCode}")]
        [ProducesResponseType(typeof(Lecturer), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetLecturerDetails(string lecturerCode)
        {
            var lecturer = await _deanService.GetLecturerByCodeAsync(lecturerCode);
            if (lecturer == null) return NotFound();
            return Ok(lecturer);
        }

        /// <summary>
        /// Tạo mới một Giảng viên (bao gồm tài khoản Login)
        /// </summary>
        [HttpPost("lecturers")]
        [ProducesResponseType(typeof(Lecturer), 201)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)] // Ví dụ: Trùng mã GV, Email
        public async Task<IActionResult> CreateLecturer([FromBody] CreateLecturerDto dto)
        {
            try
            {
                var newLecturer = await _deanService.CreateLecturerAsync(dto);
                // Trả về thông tin GV vừa tạo và link đến API chi tiết
                return CreatedAtAction(nameof(GetLecturerDetails), new { lecturerCode = newLecturer.LecturerCode }, newLecturer);
            }
            catch (Exception ex) // Bắt lỗi (ví dụ: DbUpdateException do trùng khóa)
            {
                return BadRequest(new ErrorResponseDto { Message = ex.Message });
            }
        }

        /// <summary>
        /// Cập nhật thông tin của một Giảng viên
        /// </summary>
        [HttpPut("lecturers/{lecturerCode}")]
        [ProducesResponseType(204)] // No Content
        [ProducesResponseType(404)]
        public async Task<IActionResult> UpdateLecturer(string lecturerCode, [FromBody] UpdateLecturerDto dto)
        {
            var success = await _deanService.UpdateLecturerAsync(lecturerCode, dto);
            if (!success) return NotFound();
            return NoContent(); // Cập nhật thành công, không cần trả về body
        }

        /// <summary>
        /// Cập nhật trạng thái tài khoản (active/inactive) của Giảng viên
        /// </summary>
        [HttpPatch("lecturers/{lecturerCode}/status")]
        [ProducesResponseType(204)] // No Content
        [ProducesResponseType(404)]
        public async Task<IActionResult> UpdateLecturerStatus(string lecturerCode, [FromBody] UpdateLecturerStatusDto dto)
        {
            // Thêm validation cho status
            if (dto.AccountStatus != "active" && dto.AccountStatus != "inactive")
            {
                return BadRequest(new ErrorResponseDto { Message = "Trạng thái không hợp lệ. Chỉ chấp nhận 'active' hoặc 'inactive'." });
            }

            var success = await _deanService.UpdateLecturerStatusAsync(lecturerCode, dto);
            if (!success) return NotFound();
            return NoContent();
        }
    }
}