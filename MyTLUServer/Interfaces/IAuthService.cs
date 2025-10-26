// Interfaces/IAuthService.cs
// Cập nhật để thêm các phương thức reset mật khẩu

using MyTLUServer.Application.DTOs;
using System.Security.Claims;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IAuthService
    {
        /// <summary>
        /// Xử lý đăng nhập.
        /// Sẽ ném ra PasswordNotSetException nếu mật khẩu là null.
        /// </summary>
        Task<LoginResponseDto> LoginAsync(LoginRequestDto loginRequest);

        Task<object> GetUserProfileAsync(ClaimsPrincipal userClaims);

        /// <summary>
        /// Yêu cầu gửi OTP để reset mật khẩu.
        /// </summary>
        Task<bool> RequestPasswordResetAsync(OtpRequestDto otpRequest);

        /// <summary>
        /// Xác thực OTP.
        /// Trả về ResetToken nếu OTP hợp lệ.
        /// Trả về null nếu OTP không hợp lệ.
        /// </summary>
        Task<string> VerifyOtpAsync(VerifyOtpRequestDto verifyRequest);

        /// <summary>
        /// Đặt mật khẩu mới bằng ResetToken.
        /// </summary>
        Task<bool> ResetPasswordAsync(ResetPasswordRequestDto resetRequest);

        /// <summary>
        /// Thay đổi mật khẩu khi người dùng đã đăng nhập.
        /// </summary>
        Task<bool> ChangePasswordAsync(string username, ChangePasswordRequestDto changeRequest);
    }
}
