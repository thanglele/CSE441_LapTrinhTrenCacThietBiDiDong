// File: MyTLUServer/Interfaces/IDashboardRepository.cs
using MyTLUServer.Domain.Models;
using MyTLUServer.Application.DTOs; // <-- THÊM USING DTO

namespace MyTLUServer.Interfaces 
{
    public interface IDashboardRepository
    {
        Task<int> GetClassCountAsync(string lecturerCode);
        Task<int> GetStudentCountAsync(string lecturerCode);
        
        // === SỬA KIỂU TRẢ VỀ ===
        Task<IEnumerable<ScheduleSessionDto>> GetTodaySessionsAsync(string lecturerCode, DateTime today);
        Task<IEnumerable<TeachingClassDto>> GetTeachingClassesAsync(string lecturerCode);
        Task<IEnumerable<RecentAttendanceDto>> GetRecentAttendanceAsync(string lecturerCode, int limit = 5);
        Task<IEnumerable<LecturerSubjectDto>> GetSubjectsAsync(string lecturerCode);
    }
}