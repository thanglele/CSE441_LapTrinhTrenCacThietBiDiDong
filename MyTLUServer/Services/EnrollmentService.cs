// Application/Services/EnrollmentService.cs
using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Infrastructure.Data;
using MyTLUServer.Domain.Models;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;

namespace MyTLUServer.Application.Services
{
    public class EnrollmentService : IEnrollmentService
    {
        private readonly AppDbContext _context;
        private readonly IFaceRecognitionService _faceService;

        private const double AUTO_VERIFY_THRESHOLD = 0.95;

        public EnrollmentService(AppDbContext context, IFaceRecognitionService faceService)
        {
            _context = context;
            _faceService = faceService;
        }

        /// <summary>
        /// (Sinh viên) Tải 3D Scan/Selfie lên để Tinh chỉnh Vector Gốc
        /// </summary>
        public async Task<FaceUploadResponseDto> UploadFaceDataAsync(FaceUploadRequestDto request, string studentUsername)
        {
            // 1. Lấy Vector Gốc (sơ khai 2D)
            var baseVector = await _context.FaceData
                .AsNoTracking()
                .Where(fd => fd.StudentCode == studentUsername
                             && fd.IsActive == true
                             && fd.UploadStatus == "verified")
                .OrderByDescending(fd => fd.UploadedAt)
                .FirstOrDefaultAsync();

            if (baseVector == null || string.IsNullOrEmpty(baseVector.FaceEmbedding))
            {
                throw new Exception("Hồ sơ sinh trắc học gốc chưa được tạo. Vui lòng liên hệ P.QLSV.");
            }

            // Dữ liệu 3D mới từ client (đóng gói trong Base64)
            string data3DBase64 = request.LiveSelfieBase64;

            // 2. So sánh dữ liệu 3D mới với Vector Gốc (2D)
            // (Chúng ta cần AI xác minh xem dữ liệu 3D này có khớp với vector 2D không)
            bool isHighMatch = await _faceService.VerifyFaceAsync(baseVector.FaceEmbedding, data3DBase64);

            if (isHighMatch) // Tạm dùng logic true/false
            {
                // KỊCH BẢN A: TỰ ĐỘNG TINH CHỈNH (Khớp cao)

                // 2a. GỌI AI: Tinh chỉnh vector 2D bằng dữ liệu 3D
                var refinedEmbedding = await _faceService.RefineEmbeddingAsync(baseVector.FaceEmbedding, data3DBase64);

                // 2b. Vô hiệu hóa vector 2D (cũ)
                var oldActive = await _context.FaceData.FindAsync(baseVector.Id);
                if (oldActive != null) oldActive.IsActive = false;

                // 2c. Lưu Vector Chuẩn (mới)
                var newFaceData = new FaceDatum
                {
                    StudentCode = studentUsername,
                    FaceEmbedding = refinedEmbedding, // Đây là vector đã được tinh chỉnh
                    IsActive = true,
                    UploadStatus = "verified", // Đã duyệt
                    UploadedAt = DateTime.UtcNow
                };
                _context.FaceData.Add(newFaceData);
                await _context.SaveChangesAsync();

                return new FaceUploadResponseDto
                {
                    Message = "Sinh trắc học đã được tinh chỉnh và cập nhật thành công.",
                    FaceDataId = newFaceData.Id,
                    UploadStatus = "verified"
                };
            }
            else
            {
                // KỊCH BẢN B: ĐẨY LÊN P.QLSV (Khớp thấp, dữ liệu 3D có vẻ lạ)

                // 2a. GỌI AI: Tạo 1 vector riêng từ dữ liệu 3D
                var newEmbedding_3D = await _faceService.GenerateEmbeddingAsync(data3DBase64);

                // 2b. Lưu vector 3D này ở trạng thái "chờ duyệt"
                var pendingFaceData = new FaceDatum
                {
                    StudentCode = studentUsername,
                    FaceEmbedding = newEmbedding_3D, // Vector 3D mới hoàn toàn
                    IsActive = false,
                    UploadStatus = "uploaded", // Chờ duyệt
                    UploadedAt = DateTime.UtcNow
                };
                _context.FaceData.Add(pendingFaceData);
                await _context.SaveChangesAsync();

                return new FaceUploadResponseDto
                {
                    Message = "Dữ liệu 3D không khớp với hồ sơ. Yêu cầu đã được gửi tới P.QLSV.",
                    FaceDataId = pendingFaceData.Id,
                    UploadStatus = "uploaded"
                };
            }
        }

        public async Task<IEnumerable<FaceReviewDto>> GetReviewListAsync(string classCode, string lecturerUsername)
        {
            var isLecturerOfClass = await _context.Classes
                .AnyAsync(c => c.ClassCode == classCode && c.LecturerCode == lecturerUsername);

            if (!isLecturerOfClass)
            {
                return new List<FaceReviewDto>();
            }

            var studentCodesInClass = _context.Enrollments
                .Where(e => e.ClassCode == classCode)
                .Select(e => e.StudentCode);

            var reviewList = await _context.FaceData
                .Where(fd => fd.UploadStatus == "uploaded" && studentCodesInClass.Contains(fd.StudentCode))
                .Include(fd => fd.StudentCodeNavigation)
                .Select(fd => new FaceReviewDto
                {
                    FaceDataId = fd.Id,
                    StudentCode = fd.StudentCode,
                    FullName = fd.StudentCodeNavigation.FullName,
                    UploadedImageUrl = "...", // TODO
                    ProfileImageUrl = "...", // TODO
                    UploadedAt = (DateTime)fd.UploadedAt
                })
                .ToListAsync();

            return reviewList;
        }

        public async Task<bool> VerifyFaceDataAsync(VerifyFaceRequestDto request, string lecturerUsername)
        {
            return await MasterVerifyFaceDataAsync(new MasterVerifyRequestDto
            {
                FaceDataId = request.FaceDataId,
                IsApproved = request.IsApproved
            }, lecturerUsername);
        }

        public async Task<IEnumerable<FaceReviewDto>> GetAllPendingReviewAsync()
        {
            var reviewList = await _context.FaceData
                .Where(fd => fd.UploadStatus == "uploaded")
                .Include(fd => fd.StudentCodeNavigation)
                .Select(fd => new FaceReviewDto
                {
                    FaceDataId = fd.Id,
                    StudentCode = fd.StudentCode,
                    FullName = fd.StudentCodeNavigation.FullName,
                    UploadedImageUrl = "...", // TODO
                    ProfileImageUrl = "...", // TODO
                    UploadedAt = (DateTime)fd.UploadedAt
                })
                .ToListAsync();

            return reviewList;
        }

        public async Task<bool> MasterVerifyFaceDataAsync(MasterVerifyRequestDto request, string adminUsername)
        {
            var faceData = await _context.FaceData
                .FirstOrDefaultAsync(fd => fd.Id == request.FaceDataId && fd.UploadStatus == "uploaded");

            if (faceData == null)
            {
                return false;
            }

            if (request.IsApproved)
            {
                var oldActive = await _context.FaceData
                    .Where(fd => fd.StudentCode == faceData.StudentCode && fd.IsActive == true)
                    .ToListAsync();
                oldActive.ForEach(fd => fd.IsActive = false);

                faceData.UploadStatus = "verified";
                faceData.IsActive = true;
            }
            else
            {
                faceData.UploadStatus = "rejected";
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}