// File: MyTLUServer/Interfaces/IDashboardRepository.cs
using MyTLUServer.Domain.Models; // (Giả sử Entity của bạn nằm trong Models)
using MyTLUServer.Application.DTOs;

namespace MyTLUServer.Interfaces // <--- Namespace đã khớp
{
    public interface IDashboardRepository
    {
        Task<int> GetClassCountAsync(string lecturerCode);
        Task<int> GetStudentCountAsync(string lecturerCode);
        Task<IEnumerable<ScheduleSessionDto>> GetTodaySessionsAsync(string lecturerCode, DateTime today);
        Task<IEnumerable<TeachingClassDto>> GetTeachingClassesAsync(string lecturerCode);
        Task<IEnumerable<RecentAttendanceDto>> GetRecentAttendanceAsync(string lecturerCode, int limit = 5);
    }
}