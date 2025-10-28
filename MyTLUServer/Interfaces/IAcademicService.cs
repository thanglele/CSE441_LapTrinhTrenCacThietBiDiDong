// Application/Interfaces/IAcademicService.cs
using MyTLUServer.Application.DTOs;
using MyTLUServer.Domain.Models;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IAcademicService
    {
        /// <summary>
        /// (PĐT) Tạo lớp học phần mới
        /// </summary>
        Task<Class> CreateClassAsync(Class classData);

        /// <summary>
        /// (PĐT) Cập nhật lớp học phần
        /// </summary>
        Task<bool> UpdateClassAsync(string classCode, Class classData);

        /// <summary>
        /// (PĐT) Thêm/Xóa sinh viên khỏi lớp
        /// </summary>
        Task<bool> UpdateClassEnrollmentAsync(string classCode, UpdateEnrollmentRequestDto request);

        /// <summary>
        /// (PĐT) Tự động tạo các buổi học cho học kỳ
        /// </summary>
        Task<GenerateSessionsResponseDto> GenerateSessionsForClassAsync(string classCode);
    }
}