// API/Controllers/AcademicController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models; // Cần dùng model 'Class'
using System.Threading.Tasks;

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/academics")]
    [Authorize(Roles = "faculty_office,dept_head")] // faculty_office = AcademicAffairs
    public class AcademicController : ControllerBase
    {
        private readonly IAcademicService _academicService;

        public AcademicController(IAcademicService academicService)
        {
            _academicService = academicService;
        }

        /// <summary>
        /// (PĐT) Tạo một lớp học phần mới
        /// </summary>
        [HttpPost("classes")]
        [Authorize(Roles = "faculty_office")]
        [ProducesResponseType(typeof(Class), 201)]
        public async Task<IActionResult> CreateClass([FromBody] Class classData)
        {
            var newClass = await _academicService.CreateClassAsync(classData);
            return CreatedAtAction(nameof(CreateClass), new { classCode = newClass.ClassCode }, newClass);
        }

        /// <summary>
        /// (PĐT / Trưởng BM) Cập nhật thông tin lớp học phần
        /// </summary>
        [HttpPut("classes/{classCode}")]
        [Authorize(Roles = "faculty_office,dept_head")]
        [ProducesResponseType(typeof(Class), 200)]
        public async Task<IActionResult> UpdateClass(string classCode, [FromBody] Class classData)
        {
            var success = await _academicService.UpdateClassAsync(classCode, classData);
            if (!success) return NotFound();
            return Ok(classData);
        }

        /// <summary>
        /// (PĐT) Thêm/xóa sinh viên khỏi một lớp học phần
        /// </summary>
        [HttpPost("classes/{classCode}/enrollments")]
        [Authorize(Roles = "faculty_office")]
        [ProducesResponseType(typeof(object), 200)]
        public async Task<IActionResult> UpdateEnrollment(string classCode, [FromBody] UpdateEnrollmentRequestDto request)
        {
            var success = await _academicService.UpdateClassEnrollmentAsync(classCode, request);
            if (!success) return NotFound();
            return Ok(new { message = "Cập nhật danh sách lớp thành công." });
        }

        /// <summary>
        /// (PĐT) Tự động tạo các buổi học (class_sessions)
        /// </summary>
        [HttpPost("classes/{classCode}/generate-sessions")]
        [Authorize(Roles = "faculty_office")]
        [ProducesResponseType(typeof(GenerateSessionsResponseDto), 201)]
        public async Task<IActionResult> GenerateSessions(string classCode)
        {
            var result = await _academicService.GenerateSessionsForClassAsync(classCode);
            if (result.SessionsCreated == 0)
            {
                return BadRequest(new ErrorResponseDto { Message = result.Message });
            }
            return CreatedAtAction(nameof(GenerateSessions), result);
        }
    }
}