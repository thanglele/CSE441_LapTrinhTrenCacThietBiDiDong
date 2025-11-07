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

    public class LecturerDashboardDto
    {
        public LecturerStatsDto Stats { get; set; } = null!;
        public IEnumerable<ScheduleSessionDto> TodaySessions { get; set; } = new List<ScheduleSessionDto>();
        public IEnumerable<TeachingClassDto> TeachingClasses { get; set; } = new List<TeachingClassDto>();
        public IEnumerable<RecentAttendanceDto> RecentAttendance { get; set; } = new List<RecentAttendanceDto>();
    }

    // 2. DTO cho Stats
    public class LecturerStatsDto
    {
        public int TotalClasses { get; set; }
        public int TotalStudents { get; set; }
        public int TodaySessionsCount { get; set; }
    }

    // 3. DTO cho Lịch học
    public class ScheduleSessionDto
    {
        public int ClassSessionId { get; set; }
        public string ClassName { get; set; } = null!;
        public string SessionTitle { get; set; } = null!;
        public DateTime StartTime { get; set; }
        public DateTime EndTime { get; set; }
        public string Location { get; set; } = null!;
        public string AttendanceStatus { get; set; } = null!;
    }

    // 4. DTO cho Lớp đang dạy
    public class TeachingClassDto
    {
        public string ClassCode { get; set; } = null!;
        public string ClassName { get; set; } = null!;
        public string Tag { get; set; } = null!;
    }

    // 5. DTO cho Điểm danh gần đây
    public class RecentAttendanceDto
    {
        public string Subject { get; set; } = null!;
        public string ClassCode { get; set; } = null!;
        public string SessionTitle { get; set; } = null!;
        public DateTime SessionDate { get; set; }
        public string? CheckInTime { get; set; }
        public int PresentCount { get; set; }
        public string AttendanceRate { get; set; } = null!;
    }
}