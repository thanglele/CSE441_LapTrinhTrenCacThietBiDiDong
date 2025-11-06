namespace MyTLUServer.Application.DTOs
{
    public class FaceUploadRequestDto
    {
        public string LiveSelfieBase64 { get; set; } = string.Empty;
    }

    public class FaceUploadResponseDto
    {
        public string Message { get; set; } = string.Empty;
        public int FaceDataId { get; set; }
        public string UploadStatus { get; set; } = string.Empty;
    }

    public class MyScheduleDto
    {
        public int ClassSessionId { get; set; }
        public string ClassName { get; set; } = string.Empty;
        public string SessionTitle { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string Location { get; set; } = string.Empty;
        public string AttendanceStatus { get; set; } = string.Empty;
    }

    public class CheckInRequestDto
    {
        public int ClassSessionId { get; set; }
        public string QrToken { get; set; } = string.Empty;
        public string LiveSelfieBase64 { get; set; } = string.Empty;
        public string? ClientGpsCoordinates { get; set; }
    }

    public class CheckInResponseDto
    {
        public string Message { get; set; } = string.Empty;
        public string AttendanceStatus { get; set; } = string.Empty;
        public DateTime CheckInTime { get; set; }
    }

    public class AttendanceHistoryDto
    {
        public string SessionTitle { get; set; } = string.Empty;
        // SỬA TỪ DateTime -> DateOnly
        public DateOnly SessionDate { get; set; }
        public string Status { get; set; } = string.Empty;
        public string? Method { get; set; }
    }

    /// <summary>
    /// (MỚI) DTO để tạo sinh viên mới (Nghiệp vụ Nhập học)
    /// Dùng cho POST /api/v1/students
    /// </summary>
    public class CreateStudentDto
    {
        // === Bảng Login ===
        public string Email { get; set; } = string.Empty; // Bắt buộc

        // === Bảng Students ===
        public string StudentCode { get; set; } = string.Empty; // Sẽ là Username trong bảng Login
        public string FullName { get; set; } = string.Empty; // Bắt buộc
        public string? PhoneNumber { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; } // "male", "female", "other"
        public string? AdminClass { get; set; }
        public string? MajorName { get; set; }
        public string? IntakeYear { get; set; }
        public string? AdmissionDecision { get; set; }
        public string? AcademicStatus { get; set; } = "studying";
        public string? AcademicStatus1 { get; set; }

        // === Bảng StudentDetails (Tùy chọn) ===
        public string? Ethnicity { get; set; }
        public string? Religion { get; set; }
        public string? ContactAddress { get; set; }
        public string? FatherFullName { get; set; }
        public string? FatherPhoneNumber { get; set; }
        public string? MotherFullName { get; set; }
        public string? MotherPhoneNumber { get; set; }

        // === Bảng StudentIdentification (Tùy chọn) ===
        public string? PlaceOfBirth { get; set; }
        public string? NationalId { get; set; }
        public DateOnly? IdIssueDate { get; set; }
        public string? IdIssuePlace { get; set; }
    }
}