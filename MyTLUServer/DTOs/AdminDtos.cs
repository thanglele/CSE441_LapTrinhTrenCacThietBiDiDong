// Application/DTOs/AdminDtos.cs
using System.Collections.Generic;
using MyTLUServer.Domain.Models; // Giả sử model 'Classes' ở đây

namespace MyTLUServer.Application.DTOs
{
    // --- DTOs cho Academic Affairs (Phòng Đào tạo) ---

    /// <summary>
    /// Dùng cho POST /api/v1/academics/classes
    /// (Sử dụng luôn Model 'Classes' nếu không cần tùy chỉnh)
    /// </summary>
    // public class CreateClassDto { ... } 
    // Ghi chú: Chúng ta có thể tái sử dụng Model 'Classes'

    /// <summary>
    /// Dùng cho POST /api/v1/academics/classes/{classCode}/enrollments
    /// </summary>
    public class UpdateEnrollmentRequestDto
    {
        public string StudentCode { get; set; } = string.Empty;
        public string Action { get; set; } = "add"; // "add" hoặc "remove"
    }

    /// <summary>
    /// Phản hồi khi tạo các buổi học
    /// </summary>
    public class GenerateSessionsResponseDto
    {
        public string Message { get; set; } = string.Empty;
        public int SessionsCreated { get; set; }
    }

    // --- DTOs cho Testing Office (Phòng Khảo thí) ---

    /// <summary>
    /// Dùng cho GET /api/v1/reports/testing/eligibility-export
    /// </summary>
    public class EligibilityExportRequestDto
    {
        // Dùng [FromQuery] nên không cần DTO,
        // nhưng khai báo để dễ hình dung
        public List<string> ClassCode { get; set; } = new();
        public int MinRate { get; set; } = 70; // Tỷ lệ % tối thiểu
    }

    /// <summary>
    /// Dùng cho GET /api/v1/students/{studentCode}/profile
    /// (Kết hợp từ 3 bảng: students, student_details, student_identification)
    /// </summary>
    public class StudentFullProfileDto
    {
        // Từ bảng students
        public string StudentCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? AdminClass { get; set; }
        public string? MajorName { get; set; }
        public string? AcademicStatus { get; set; }

        // Từ bảng student_details
        public string? Ethnicity { get; set; }
        public string? Religion { get; set; }
        public string? ContactAddress { get; set; }

        // Từ bảng student_identification
        public string? PlaceOfBirth { get; set; }
        public string? NationalId { get; set; }
        public DateOnly? IdIssueDate { get; set; }
        public string? IdIssuePlace { get; set; }
    }

    /// <summary>
    /// Phản hồi khi upload ảnh hồ sơ gốc thành công
    /// </summary>
    public class ProfilePhotoUploadResponseDto
    {
        public string Message { get; set; } = "Cập nhật ảnh hồ sơ thành công.";
        public string ImageUrl { get; set; } = string.Empty;
    }

    /// <summary>
    /// Dùng cho POST /api/v1/enrollment/master-verify [cite: 116]
    /// </summary>
    public class MasterVerifyRequestDto
    {
        public int FaceDataId { get; set; }
        public bool IsApproved { get; set; }
        public string? Notes { get; set; } // Thêm trường Notes
    }
}