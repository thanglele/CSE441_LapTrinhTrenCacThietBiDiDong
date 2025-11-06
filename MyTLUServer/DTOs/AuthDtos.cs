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

    /// <summary>
    /// Dữ liệu từ bảng StudentDetails
    /// </summary>
    public class StudentDetailDto
    {
        public string? Ethnicity { get; set; }
        public string? Religion { get; set; }
        public string? ContactAddress { get; set; }
        public string? FatherFullName { get; set; }
        public string? FatherPhoneNumber { get; set; }
        public string? MotherFullName { get; set; }
        public string? MotherPhoneNumber { get; set; }
    }

    /// <summary>
    /// Dữ liệu từ bảng StudentIdentification
    /// </summary>
    public class StudentIdentificationDto
    {
        public string? PlaceOfBirth { get; set; }
        public string? NationalId { get; set; }
        public DateOnly? IdIssueDate { get; set; }
        public string? IdIssuePlace { get; set; }
    }

    /// <summary>
    /// Dữ liệu từ bảng FaceData (trừ FaceEmbedding)
    /// </summary>
    public class FaceDataDto
    {
        public int Id { get; set; }
        public string? ImagePath { get; set; }
        public bool? IsActive { get; set; }
        public string? UploadStatus { get; set; }
        public DateTime? UploadedAt { get; set; }
    }

    /// <summary>
    /// Dữ liệu từ bảng Enrollments (kèm tên lớp)
    /// </summary>
    public class EnrolledClassDto
    {
        public string ClassCode { get; set; } = string.Empty;
        public string? ClassName { get; set; }
        public string? EnrollmentStatus { get; set; }
    }

    // --- DTOs Profile Chính (Đã cập nhật) ---

    /// <summary>
    /// DTO cho thông tin đầy đủ của Sinh viên (GET /me)
    /// </summary>
    public class StudentProfileDto
    {
        // Từ bảng Login
        public string Email { get; set; } = string.Empty;
        public string AccountStatus { get; set; } = string.Empty;
        public DateTime? CreatedAt { get; set; }

        // Từ bảng Students
        public string StudentCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? AdminClass { get; set; }
        public string? MajorName { get; set; }
        public string? IntakeYear { get; set; }
        public string? AdmissionDecision { get; set; }
        public string? AcademicStatus { get; set; }
        public string? AcademicStatus1 { get; set; }

        // Dữ liệu liên quan (lồng nhau)
        public StudentDetailDto? Details { get; set; }
        public StudentIdentificationDto? Identification { get; set; }
        public List<FaceDataDto> FaceDataHistory { get; set; } = new();
        public List<EnrolledClassDto> Enrollments { get; set; } = new();
    }

    /// <summary>
    /// DTO cho thông tin đầy đủ của Giảng viên (GET /me)
    /// </summary>
    public class LecturerProfileDto
    {
        // Từ bảng Login
        public string Email { get; set; } = string.Empty;
        public string AccountStatus { get; set; } = string.Empty;
        public DateTime? CreatedAt { get; set; }

        // Từ bảng Lecturers
        public string LecturerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public string? AvatarUrl { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? Degree { get; set; }
        public string? AcademicRank { get; set; }
        public string? OfficeLocation { get; set; }

        // Dữ liệu liên quan (lồng nhau)
        public string? DepartmentName { get; set; }
        public string? FacultyName { get; set; }
        public List<string> TaughtClassCodes { get; set; } = new();
    }
}