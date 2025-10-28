// API/Controllers/StudentAffairsController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using System.Threading.Tasks;

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1")] // Route gốc
    
    [Authorize(Roles = "admin_staff,dept_head,dean_office")] // admin_staff = StudentAffairs [cite: 10]
    public class StudentAffairsController : ControllerBase
    {
        private readonly IStudentAffairsService _studentAffairsService;

        public StudentAffairsController(IStudentAffairsService studentAffairsService)
        {
            _studentAffairsService = studentAffairsService;
        }

        /// <summary>
        /// (P.QLSV) Lấy thông tin hồ sơ chi tiết của sinh viên [cite: 101]
                    /// </summary>
        [HttpGet("students/{studentCode}/profile")]
        
        [Authorize(Roles = "admin_staff,dept_head,dean_office")] // [cite: 102]
        [ProducesResponseType(typeof(StudentFullProfileDto), 200)]
        public async Task<IActionResult> GetStudentProfile(string studentCode)
        {
            var profile = await _studentAffairsService.GetStudentFullProfileAsync(studentCode);
            if (profile == null) return NotFound();
            return Ok(profile);
        }

        /// <summary>
        /// (P.QLSV) Tải lên/cập nhật ảnh hồ sơ GỐC [cite: 105]
                    /// </summary>
        [HttpPost("students/{studentCode}/profile-photo")]
        
        [Authorize(Roles = "admin_staff")] // [cite: 106]
        [ProducesResponseType(typeof(ProfilePhotoUploadResponseDto), 200)]
        public async Task<IActionResult> UploadProfilePhoto(string studentCode, IFormFile file)
        {
            if (file == null || file.Length == 0)
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng chọn file ảnh." });
            }

            // TODO: Thêm logic kiểm tra file (size, type)

            var result = await _studentAffairsService.UpdateProfilePhotoAsync(studentCode, file);
            return Ok(result);
        }
    }
}