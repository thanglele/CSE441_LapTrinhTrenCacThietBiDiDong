using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Exceptions;
using MyTLUServer.Application.Interfaces;
using System.Security.Claims;

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
        /// Xác thực OTP và lấy ResetToken
        /// </summary>
        [HttpPost("verify-otp")]
        [AllowAnonymous]
        [ProducesResponseType(typeof(VerifyOtpResponseDto), 200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> VerifyOtp([FromBody] VerifyOtpRequestDto verifyRequest)
        {
            if (string.IsNullOrEmpty(verifyRequest.Username) || string.IsNullOrEmpty(verifyRequest.Otp))
            {
                return BadRequest(new ErrorResponseDto { Message = "Username và OTP là bắt buộc." });
            }

            var resetToken = await _authService.VerifyOtpAsync(verifyRequest);

            if (resetToken == null)
            {
                return BadRequest(new ErrorResponseDto { Message = "OTP không hợp lệ hoặc đã hết hạn." });
            }

            return Ok(new VerifyOtpResponseDto { ResetToken = resetToken });
        }

        /// <summary>
        /// Đặt lại mật khẩu bằng ResetToken
        /// </summary>
        [HttpPost("reset-password")]
        [AllowAnonymous]
        [ProducesResponseType(200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequestDto resetRequest)
        {
            if (string.IsNullOrEmpty(resetRequest.Username) ||
                string.IsNullOrEmpty(resetRequest.ResetToken) ||
                string.IsNullOrEmpty(resetRequest.NewPassword))
            {
                return BadRequest(new ErrorResponseDto { Message = "Username, ResetToken và Mật khẩu mới là bắt buộc." });
            }

            var success = await _authService.ResetPasswordAsync(resetRequest);
            if (!success)
            {
                return BadRequest(new ErrorResponseDto { Message = "Mã reset không hợp lệ hoặc đã hết hạn." });
            }
            return Ok(new { Message = "Mật khẩu đã được cập nhật thành công." });
        }

        /// <summary>
        /// Đổi mật khẩu (khi đã đăng nhập)
        /// </summary>
        [HttpPost("change-password")]
        [Authorize]
        [ProducesResponseType(200)]
        [ProducesResponseType(typeof(ErrorResponseDto), 400)]
        [ProducesResponseType(401)]
        public async Task<IActionResult> ChangePassword([FromBody] ChangePasswordRequestDto changeRequest)
        {
            // Lấy username từ JWT Token
            var username = HttpContext.User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (string.IsNullOrEmpty(username))
            {
                return Unauthorized(); // Lỗi token
            }

            var success = await _authService.ChangePasswordAsync(username, changeRequest);

            if (!success)
            {
                return BadRequest(new ErrorResponseDto { Message = "Mật khẩu hiện tại không chính xác." });
            }

            return Ok(new { Message = "Đổi mật khẩu thành công." });
        }
    }
}


