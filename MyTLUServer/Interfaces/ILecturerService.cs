// File: MyTLUServer/Interfaces/ILecturerService.cs
using MyTLUServer.Application.DTOs; // (Import DTO)

namespace MyTLUServerInterfaces 
{
    public interface ILecturerService
    {
        // (API 1)
        Task<IEnumerable<LecturerStudentDto>> GetStudentsInClassAsync(string classCode);
        
        // (API 2)
        Task<LecturerStudentDto> RequestStudentEnrollmentAsync(string classCode, string studentCode, string lecturerCode);
    }
}