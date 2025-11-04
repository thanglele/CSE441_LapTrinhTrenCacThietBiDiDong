// Application/Interfaces/IEnrollmentService.cs
using MyTLUServer.Application.DTOs;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IEnrollmentService
    {
        /// <summary>
        /// (Sinh viên) Tải ảnh selfie lên để đăng ký
        /// </summary>
        Task<FaceUploadResponseDto> UploadFaceDataAsync(FaceUploadRequestDto request, string studentUsername);

        /// <summary>
        /// (Giảng viên) Lấy danh sách SV chờ duyệt của lớp học
        /// </summary>
        Task<IEnumerable<FaceReviewDto>> GetReviewListAsync(string classCode, string lecturerUsername);

        /// <summary>
        /// (Giảng viên) Duyệt hoặc từ chối sinh trắc học
        /// </summary>
        Task<bool> VerifyFaceDataAsync(VerifyFaceRequestDto request, string lecturerUsername);

        /// <summary>
        /// (P.QLSV) Lấy TẤT CẢ SV đang chờ duyệt
        /// </summary>
        Task<IEnumerable<FaceReviewDto>> GetAllPendingReviewAsync();

        /// <summary>
        /// (P.QLSV) Duyệt/Từ chối với quyền cao nhất
        /// </summary>
        Task<bool> MasterVerifyFaceDataAsync(MasterVerifyRequestDto request, string adminUsername);
    }
}