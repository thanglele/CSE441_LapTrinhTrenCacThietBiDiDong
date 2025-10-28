// Application/Interfaces/IAttendanceService.cs
using MyTLUServer.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IAttendanceService
    {
        /// <summary>
        /// (Sinh viên) Thực hiện điểm danh bằng khuôn mặt
        /// </summary>
        Task<CheckInResponseDto> CheckInAsync(CheckInRequestDto request, string studentUsername, string clientIpAddress);

        /// <summary>
        /// (Sinh viên) Lấy lịch sử điểm danh của một lớp học
        /// </summary>
        Task<IEnumerable<AttendanceHistoryDto>> GetAttendanceHistoryAsync(string classCode, string studentUsername);

        /// <summary>
        /// (Giảng viên) Lấy báo cáo chi tiết buổi học
        /// </summary>
        Task<SessionReportDto?> GetSessionReportAsync(int sessionId);

        /// <summary>
        /// (Giảng viên) Cập nhật điểm danh thủ công
        /// </summary>
        Task<bool> ManualUpdateAttendanceAsync(ManualUpdateRequestDto request, string lecturerUsername);
    }
}