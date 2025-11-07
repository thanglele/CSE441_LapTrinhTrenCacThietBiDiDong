using MyTLUServer.Application.DTOs;

namespace MyTLUServer.Interfaces 
{
   public interface ILecturerDashboardService
   {
        Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode);
        Task<IEnumerable<LecturerSubjectDto>> GetSubjectsAsync(string lecturerCode);
   }
}