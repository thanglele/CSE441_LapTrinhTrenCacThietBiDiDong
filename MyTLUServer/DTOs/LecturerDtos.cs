namespace MyTLUServer.Application.DTOs
{
    public class FaceReviewDto
    {
        public int FaceDataId { get; set; }
        public string StudentCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string UploadedImageUrl { get; set; } = string.Empty;
        public string ProfileImageUrl { get; set; } = string.Empty;
        public DateTime UploadedAt { get; set; }
    }

    public class VerifyFaceRequestDto
    {
        public int FaceDataId { get; set; }
        public bool IsApproved { get; set; }
    }

    public class StartAttendanceResponseDto
    {
        public int ClassSessionId { get; set; }
        public string QrData { get; set; } = string.Empty;
        public string SessionStatus { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
    }

    public class ClassSessionDetailDto
    {
        public int Id { get; set; }
        public string ClassName { get; set; } = string.Empty;
        public string Title { get; set; } = string.Empty;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string Location { get; set; } = string.Empty;
        public string SessionStatus { get; set; } = string.Empty;
        public string LecturerName { get; set; } = string.Empty;
    }

    public class SessionReportDto
    {
        public string SessionTitle { get; set; } = string.Empty;
        public int TotalStudents { get; set; }
        public int Present { get; set; }
        public int Absent { get; set; }
        public List<SessionReportStudentDto> Students { get; set; } = new();
    }

    public class SessionReportStudentDto
    {
        public string StudentCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime? CheckInTime { get; set; }
    }

    public class ManualUpdateRequestDto
    {
        public int ClassSessionId { get; set; }
        public string StudentCode { get; set; } = string.Empty;
        public string NewStatus { get; set; } = string.Empty;
        public string Notes { get; set; } = string.Empty;
    }
}