using MyTLUServer.Application.DTOs;

namespace MyTLUServer.Interfaces 
{
    public interface ILecturerDashboardService
    {
        Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode);
    }
}