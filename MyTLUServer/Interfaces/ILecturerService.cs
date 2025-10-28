//// Application/Interfaces/ILecturerService.cs
//using MyTLUServer.Application.DTOs;
//using System.Collections.Generic;
//using System.Security.Claims;
//using System.Threading.Tasks;

//namespace MyTLUServer.Application.Interfaces
//{
//    // --- Interface cho nghiệp vụ Buổi học ---
//    public interface ISessionService
//    {
//        /// <summary>
//        /// Lấy chi tiết buổi học
//        /// </summary>
//        Task<ClassSessionDetailDto> GetSessionDetailAsync(int sessionId);

//        /// <summary>
//        /// (Giảng viên) Mở điểm danh
//        /// </summary>
//        Task<StartAttendanceResponseDto> StartAttendanceAsync(int sessionId, string lecturerUsername);

//        /// <summary>
//        /// (Giảng viên) Đóng điểm danh
//        /// </summary>
//        Task<bool> EndAttendanceAsync(int sessionId, string lecturerUsername);
//    }
//}