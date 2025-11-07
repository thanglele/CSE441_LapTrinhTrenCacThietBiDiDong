// API/Controllers/StudentAffairsController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models;
using System.Threading.Tasks;

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/students")] // Đổi Route gốc về /students
    [Authorize(Roles = "admin_staff,dept_head,dean_office")] // admin_staff = StudentAffairs
    public class StudentAffairsController : ControllerBase
    {
        private readonly IStudentAffairsService _studentAffairsService;

        public StudentAffairsController(IStudentAffairsService studentAffairsService)
        {
            _studentAffairsService = studentAffairsService;
        }

        /// <summary>
        /// (MỚI) (P.QLSV) Tạo sinh viên mới (Nghiệp vụ Nhập học)
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "admin_staff")]
        [ProducesResponseType(typeof(Student), 201)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> CreateStudent([FromBody] CreateStudentDto dto)
        {
            if (string.IsNullOrEmpty(dto.StudentCode) || string.IsNullOrEmpty(dto.FullName) || string.IsNullOrEmpty(dto.Email))
            {
                return BadRequest(new ErrorResponseDto { Message = "StudentCode, FullName, và Email là bắt buộc." });
            }

            try
            {
                var newStudent = await _studentAffairsService.CreateStudentAsync(dto);
                // Trả về 201 Created và link đến API GetStudentProfile
                return CreatedAtAction(nameof(GetStudentProfile), new { studentCode = newStudent.StudentCode }, newStudent);
            }
            catch (InvalidOperationException ex) // Bắt lỗi (ví dụ: Trùng mã SV/Email)
            {
                return BadRequest(new ErrorResponseDto { Message = ex.Message });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ErrorResponseDto { Message = $"Lỗi máy chủ nội bộ: {ex.Message}" });
            }
        }


        /// <summary>
        /// (P.QLSV) Lấy thông tin hồ sơ chi tiết của sinh viên
        /// </summary>
        [HttpGet("{studentCode}/profile")]
        [Authorize(Roles = "admin_staff,dept_head,dean_office")]
        [ProducesResponseType(typeof(StudentFullProfileDto), 200)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetStudentProfile(string studentCode)
        {
            var profile = await _studentAffairsService.GetStudentFullProfileAsync(studentCode);
            if (profile == null) return NotFound(new ErrorResponseDto { Message = "Không tìm thấy sinh viên." });
            return Ok(profile);
        }

        /// <summary>
        /// (P.QLSV) Tải lên/cập nhật ảnh hồ sơ GỐC (Tạo Vector Gốc)
        /// </summary>
        [HttpPut("{studentCode}/profile-photo")]
        [Authorize(Roles = "admin_staff")]
        [ProducesResponseType(typeof(ProfilePhotoUploadResponseDto), 201)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> UploadProfilePhoto(string studentCode, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng chọn file ảnh." });
            }

            try
            {
                var result = await _studentAffairsService.UpdateProfilePhotoAsync(studentCode, file);
                return CreatedAtAction(nameof(UploadProfilePhoto), result);
            }
            catch (Exception ex)
            {
                return NotFound(new ErrorResponseDto { Message = ex.Message }); // 404 nếu không tìm thấy SV
            }
        }
    }
}