// Application/Interfaces/IStudentAffairsService.cs
using Microsoft.AspNetCore.Http;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Domain.Models;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IStudentAffairsService
    {
        /// <summary>
        /// (MỚI) (P.QLSV) Tạo sinh viên mới (Nhập học)
        /// </summary>
        Task<Student> CreateStudentAsync(CreateStudentDto dto);

        /// <summary>
        /// (P.QLSV) Lấy hồ sơ chi tiết của sinh viên
        /// </summary>
        Task<StudentFullProfileDto?> GetStudentFullProfileAsync(string studentCode);

        /// <summary>
        /// (P.QLSV) Tải lên/Cập nhật ảnh hồ sơ GỐC (Tạo Vector Gốc)
        /// </summary>
        Task<ProfilePhotoUploadResponseDto> UpdateProfilePhotoAsync(string studentCode, IFormFile imageFile);
    }
}