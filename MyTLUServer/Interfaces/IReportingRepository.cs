// File: MyTLUServer/Interfaces/IReportingRepository.cs
using MyTLUServer.Application.DTOs; 
using System.Security.Claims; 

namespace MyTLUServer.Interfaces 
{
    public interface IReportingRepository
    {
        /// <summary>
        /// Lấy lịch sử buổi học (phân trang) (Nguồn: 1151)
        /// </summary>
        Task<PaginatedSessionHistoryDto> GetSessionHistoryAsync(ClaimsPrincipal user, SessionHistoryFilterDto filter);
        // === THÊM HÀM THỐNG KÊ MÔN HỌC ===
        Task<IEnumerable<SubjectAttendanceStatsDto>> GetSubjectStatsAsync(string lecturerCode);
        Task<IEnumerable<ClassAttendanceStatsDto>> GetClassStatsAsync(string lecturerCode);
        Task<IEnumerable<StudentAttendanceStatsDto>> GetStudentStatsInClassAsync(string classCode);
    }
}