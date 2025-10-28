// Application/Interfaces/IDeanService.cs
using MyTLUServer.Application.DTOs;
using MyTLUServer.Domain.Models; // Cần dùng Model 'Lecturer'
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IDeanService
    {
        /// <summary>
        /// (VP Khoa) Lấy danh sách Giảng viên
        /// </summary>
        Task<IEnumerable<LecturerListItemDto>> GetAllLecturersAsync(string? departmentCode = null); // Thêm filter theo Bộ môn (tùy chọn)

        /// <summary>
        /// (VP Khoa) Lấy chi tiết một Giảng viên
        /// </summary>
        Task<Lecturer?> GetLecturerByCodeAsync(string lecturerCode);

        /// <summary>
        /// (VP Khoa) Tạo mới Giảng viên (bao gồm cả tài khoản Login)
        /// </summary>
        Task<Lecturer> CreateLecturerAsync(CreateLecturerDto dto);

        /// <summary>
        /// (VP Khoa) Cập nhật thông tin Giảng viên
        /// </summary>
        Task<bool> UpdateLecturerAsync(string lecturerCode, UpdateLecturerDto dto);

        /// <summary>
        /// (VP Khoa) Cập nhật trạng thái tài khoản Giảng viên
        /// </summary>
        Task<bool> UpdateLecturerStatusAsync(string lecturerCode, UpdateLecturerStatusDto dto);
    }
}