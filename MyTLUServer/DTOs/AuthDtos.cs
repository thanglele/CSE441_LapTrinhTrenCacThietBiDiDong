namespace MyTLUServer.Application.DTOs
{
    public class LoginRequestDto
    {
        public string Username { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public string? LoginPosition { get; set; }
    }

    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public string UserRole { get; set; } = string.Empty;
        public string FaceDataStatus { get; set; } = "none"; // "none", "pending", "verified"
    }

    public class StudentProfileDto
    {
        public string StudentCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string AdminClass { get; set; } = string.Empty;
        public string MajorName { get; set; } = string.Empty;
        public string FaceDataStatus { get; set; } = string.Empty;
    }

    public class LecturerProfileDto
    {
        public string LecturerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string DepartmentName { get; set; } = string.Empty;
        public string Degree { get; set; } = string.Empty;
    }

    public class OtpRequestDto
    {
        public string Username { get; set; } = string.Empty;
    }

    public class ErrorResponseDto
    {
        public string Message { get; set; } = string.Empty;
    }

    public class PasswordNotSetErrorDto
    {
        public string Code { get; set; } = "PASSWORD_NOT_SET";
        public string Message { get; set; } = "Tài khoản chưa thiết lập mật khẩu. Vui lòng sử dụng chức năng 'Quên mật khẩu' để tạo mật khẩu mới.";
    }

    public class ChangePasswordRequestDto
    {
        public string CurrentPassword { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }

    public class VerifyOtpRequestDto
    {
        public string Username { get; set; } = string.Empty;
        public string Otp { get; set; } = string.Empty;
    }

    public class VerifyOtpResponseDto
    {
        public string ResetToken { get; set; } = string.Empty;
    }

    public class ResetPasswordRequestDto
    {
        public string Username { get; set; } = string.Empty;
        public string ResetToken { get; set; } = string.Empty;
        public string NewPassword { get; set; } = string.Empty;
    }
}