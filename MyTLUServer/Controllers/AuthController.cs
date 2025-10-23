// Controllers/AuthController.cs
// Xóa validation cho Email

using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Application.Exceptions; // Thêm
using System; // Thêm

namespace MyTLUServer.API.Controllers
{
    [ApiController]
    [Route("api/v1/auth")]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>
        /// Endpoint đăng nhập
        /// </summary>
        [HttpPost("login")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(LoginResponseDto), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 401)]
        [ProducesResponseType(typeof(PasswordNotSetErrorDto), 428)] // 428 = Precondition Required
        public async Task<IActionResult> Login([FromBody] LoginRequestDto loginRequest)
        {
            try
            {
                var result = await _authService.LoginAsync(loginRequest);
                if (result == null)
                {
                    return Unauthorized(new ErrorResponseDto { Message = "Sai tên đăng nhập hoặc mật khẩu." });
                }
                return Ok(result);
            }
            catch (PasswordNotSetException)
            {
                // Bắt exception và trả về mã lỗi 428
                return StatusCode(428, new PasswordNotSetErrorDto());
            }
            catch (Exception ex)
            {
                return StatusCode(500, new ErrorResponseDto { Message = ex.Message });
            }
        }

        /// <summary>
        /// Endpoint lấy thông tin cá nhân (profile)
        /// </summary>
        [HttpGet("me")]
        [Authorize]
        [ProducesResponseType(typeof(StudentProfileDto), 200)]
        [ProducesResponseType(typeof(LecturerProfileDto), 200)]
        [ProducesResponseType(401)]
        [ProducesResponseType(404)]
        public async Task<IActionResult> GetMyProfile()
        {
            var userClaims = HttpContext.User;
            var profile = await _authService.GetUserProfileAsync(userClaims);
            if (profile == null)
            {
                return NotFound(new ErrorResponseDto { Message = "Không tìm thấy hồ sơ người dùng." });
            }
            return Ok(profile);
        }

        /// <summary>
        /// Yêu cầu gửi OTP để reset mật khẩu (hoặc tạo mới)
        /// </summary>
        [HttpPost("request-reset")]
        [AllowAnonymous]
        [ProducesResponseType(200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> RequestPasswordReset([FromBody] OtpRequestDto otpRequest)
        {
            // Validation: Username là bắt buộc
            if (string.IsNullOrEmpty(otpRequest.Username))
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp Tên đăng nhập." });
            }

            // Luôn trả về 200 để tránh việc dò tìm
            await _authService.RequestPasswordResetAsync(otpRequest);
            return Ok(new { Message = "Nếu tài khoản tồn tại và có email, mã OTP đã được gửi." });
        }

        /// <summary>
        /// Đặt lại mật khẩu bằng OTP
        /// </summary>
        [HttpPost("reset-password")]
        [AllowAnonymous]
        [ProducesResponseType(200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto resetRequest)
        {
            // Validation: Username là bắt buộc
            if (string.IsNullOrEmpty(resetRequest.Username))
            {
                return BadRequest(new ErrorResponseDto { Message = "Vui lòng cung cấp Tên đăng nhập." });
            }

            var success = await _authService.ResetPasswordAsync(resetRequest);
            if (!success)
            {
                return BadRequest(new ErrorResponseDto { Message = "OTP không hợp lệ hoặc đã hết hạn." });
            }
            return Ok(new { Message = "Mật khẩu đã được cập nhật thành công." });
        }
    }
}


