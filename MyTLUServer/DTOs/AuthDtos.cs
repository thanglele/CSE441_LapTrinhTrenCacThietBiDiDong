// DTOs/AuthDtos.cs
// Cập nhật DTOs, CHỈ chấp nhận Username

namespace MyTLUServer.Application.DTOs
{
    public class LoginRequestDto
    {
        public string Username { get; set; }
        public string Password { get; set; }
    }

    // DTO cho phản hồi đăng nhập thành công
    public class LoginResponseDto
    {
        public string Token { get; set; }
        public string UserRole { get; set; }
    }

    // DTO cho thông tin cơ bản của Sinh viên (GET /me)
    public class StudentProfileDto
    {
        public string StudentCode { get; set; }
        public string FullName { get; set; }
        public string AdminClass { get; set; }
        public string MajorName { get; set; }
        public string FaceDataStatus { get; set; }
    }

    // DTO cho thông tin cơ bản của Giảng viên (GET /me)
    public class LecturerProfileDto
    {
        public string LecturerCode { get; set; }
        public string FullName { get; set; }
        public string DepartmentName { get; set; }
        public string Degree { get; set; }
    }
    
    // --- DTOs MỚI CHO RESET MẬT KHẨU ---

    // DTO cho yêu cầu gửi OTP
    public class OtpRequestDto
    {
        // Chỉ chấp nhận Username
        public string Username { get; set; }
    }

    // DTO cho yêu cầu đặt lại mật khẩu
    public class ResetPasswordRequestDto
    {
        // Chỉ chấp nhận Username
        public string Username { get; set; }
        public string Otp { get; set; }
        public string NewPassword { get; set; }
    }

    // DTO chung cho lỗi
    public class ErrorResponseDto
    {
        public string Message { get; set; }
    }
    
    // DTO lỗi đặc biệt khi mật khẩu là null
    public class PasswordNotSetErrorDto
    {
        public string Code { get; set; } = "PASSWORD_NOT_SET";
        public string Message { get; set; } = "Tài khoản chưa thiết lập mật khẩu. Vui lòng sử dụng chức năng 'Quên mật khẩu' để tạo mật khẩu mới.";
    }
}

