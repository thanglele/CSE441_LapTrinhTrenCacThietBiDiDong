// File: MyTLUServer/Interfaces/ILecturerDashboardService.cs
using MyTLUServer.Application.DTOs; // (Import DTO)

namespace MyTLUServer.Interfaces 
{
    public interface ILecturerDashboardService
    {
        Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode);
    }
}