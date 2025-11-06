// File: MyTLUServer/Interfaces/IDashboardRepository.cs
using MyTLUServer.Domain.Models; // (Giả sử Entity của bạn nằm trong Models)

namespace MyTLUServer.Interfaces // <--- Namespace đã khớp
{
    public interface IDashboardRepository
    {
        Task<int> GetClassCountAsync(string lecturerCode);
        Task<int> GetStudentCountAsync(string lecturerCode);
        Task<IEnumerable<ClassSession>> GetTodaySessionsAsync(string lecturerCode, DateTime today);
        Task<IEnumerable<Class>> GetTeachingClassesAsync(string lecturerCode);
        Task<IEnumerable<AttendanceRecord>> GetRecentAttendanceAsync(string lecturerCode, int limit = 5);
    }
}