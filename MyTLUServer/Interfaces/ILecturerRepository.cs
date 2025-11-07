// File: MyTLUServer/Interfaces/ILecturerRepository.cs
using MyTLUServer.Domain.Models; // (Giả định Entity CSDL của bạn nằm trong Models)
using MyTLUServer.Application.DTOs; // (Import DTO)

namespace MyTLUServer.Interfaces 
{
    public interface ILecturerRepository
    {
        // (API 1) Lấy danh sách SV trong lớp
        Task<IEnumerable<LecturerStudentDto>> GetStudentsInClassAsync(string classCode);
        
        // (API 2) Kiểm tra GV có sở hữu lớp không
        Task<bool> CheckLecturerOwnsClassAsync(string classCode, string lecturerCode);
        
        // (API 2) Tạo yêu cầu "pending"
        Task<Enrollment> RequestStudentEnrollmentAsync(string classCode, string studentCode);
        
        // (API 2) Lấy chi tiết SV vừa thêm
        Task<LecturerStudentDto> GetStudentDetailsAsync(string studentCode);
    }
}