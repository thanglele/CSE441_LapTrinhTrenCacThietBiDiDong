// Application/Interfaces/ISessionService.cs
using MyTLUServer.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface ISessionService
    {
        /// <summary>
        /// (Sinh viên) Lấy lịch học trong hôm nay
        /// </summary>
        Task<IEnumerable<MyScheduleDto>> GetMyScheduleAsync(string studentUsername);

        /// <summary>
        /// (Sinh viên) Lấy lịch học theo ngày
        /// </summary>
        Task<IEnumerable<MyScheduleDto>> GetMyScheduleByDateAsync(string studentCode, DateTime selectedDate);

        /// <summary>
        /// Lấy chi tiết buổi học
        /// </summary>
        Task<ClassSessionDetailDto?> GetSessionDetailAsync(int sessionId);

        /// <summary>
        /// (Giảng viên) Mở điểm danh
        /// </summary>
        Task<StartAttendanceResponseDto> StartAttendanceAsync(int sessionId, string lecturerUsername);

        /// <summary>
        /// (Giảng viên) Đóng điểm danh
        /// </summary>
        Task<bool> EndAttendanceAsync(int sessionId, string lecturerUsername);
    }
}