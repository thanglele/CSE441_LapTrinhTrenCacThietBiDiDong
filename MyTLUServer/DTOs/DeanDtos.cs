// Application/DTOs/DeanDtos.cs
using System;
using System.Collections.Generic;

namespace MyTLUServer.Application.DTOs
{
    /// <summary>
    /// DTO hiển thị danh sách Giảng viên (GET /dean/lecturers)
    /// </summary>
    public class LecturerListItemDto
    {
        public string LecturerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string? DepartmentName { get; set; }
        public string? Degree { get; set; }
        public string AccountStatus { get; set; } = string.Empty; // Từ bảng Login
    }

    /// <summary>
    /// DTO chi tiết Giảng viên (GET /dean/lecturers/{code})
    /// (Có thể tái sử dụng Model 'Lecturer' hoặc tạo DTO chi tiết hơn)
    /// </summary>
    // public class LecturerDetailDto { ... } // Tạm thời dùng Model

    /// <summary>
    /// DTO để tạo mới Giảng viên (POST /dean/lecturers)
    /// </summary>
    public class CreateLecturerDto
    {
        // Thông tin cơ bản để tạo Login và Lecturer
        public string LecturerCode { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty; // Bắt buộc để tạo Login
        public string? PhoneNumber { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; } // "male", "female", "other"
        public string? DeptCode { get; set; }
        public string? Degree { get; set; }
        public string? AcademicRank { get; set; }
        public string? OfficeLocation { get; set; }
        // Lưu ý: Không có mật khẩu ở đây. GV sẽ tự đặt qua flow "Quên mật khẩu".
    }

    /// <summary>
    /// DTO để cập nhật thông tin Giảng viên (PUT /dean/lecturers/{code})
    /// </summary>
    public class UpdateLecturerDto
    {
        // Các trường cho phép cập nhật (Ví dụ)
        public string FullName { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateOnly? DateOfBirth { get; set; }
        public string? Gender { get; set; }
        public string? DeptCode { get; set; }
        public string? Degree { get; set; }
        public string? AcademicRank { get; set; }
        public string? OfficeLocation { get; set; }
        // Không cho phép cập nhật Email qua đây (nếu cần thì làm API riêng)
        // Không cho phép cập nhật LecturerCode
    }

    /// <summary>
    /// DTO để cập nhật trạng thái tài khoản (PATCH /dean/lecturers/{code}/status)
    /// </summary>
    public class UpdateLecturerStatusDto
    {
        public string AccountStatus { get; set; } = "active"; // "active" hoặc "inactive"
    }
}