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
}