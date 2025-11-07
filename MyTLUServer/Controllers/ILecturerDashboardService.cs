using MyTLUServer.Application.DTOs;

namespace MyTLUServer.Interfaces 
{
   public interface ILecturerDashboardService
   {
        Task<List<ScheduleSessionDto>> GetMyScheduleByDate(string lecturerCode, DateTime today);
        Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode);
        Task<IEnumerable<LecturerSubjectDto>> GetSubjectsAsync(string lecturerCode);
        Task<IEnumerable<LecturerClassDto>> GetClassesAsync(string lecturerCode);

        
   }
}