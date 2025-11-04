// Application/Services/AttendanceService.cs
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Exceptions;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models; // Giả sử model ở đây
using MyTLUServer.Infrastructure.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic; // Cần cho List, IEnumerable
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    public class AttendanceService : IAttendanceService
    {
        private readonly AppDbContext _context;
        private readonly IGeoIpService _geoIpService;
        private readonly IFaceRecognitionService _faceService;

        // --- THAY ĐỔI BIẾN ---
        private readonly double _minLat;
        private readonly double _maxLat;
        private readonly double _minLon;
        private readonly double _maxLon;

        public AttendanceService(
            AppDbContext context,
            IGeoIpService geoIpService,
            IFaceRecognitionService faceService,
            IConfiguration configuration)
        {
            _context = context;
            _geoIpService = geoIpService;
            _faceService = faceService;

            var locConfig = configuration.GetSection("Location");
            _minLat = double.Parse(locConfig["MinLatitude"] ?? "0", CultureInfo.InvariantCulture);
            _maxLat = double.Parse(locConfig["MaxLatitude"] ?? "0", CultureInfo.InvariantCulture);
            _minLon = double.Parse(locConfig["MinLongitude"] ?? "0", CultureInfo.InvariantCulture);
            _maxLon = double.Parse(locConfig["MaxLongitude"] ?? "0", CultureInfo.InvariantCulture);

            // Kiểm tra config hợp lệ
            if (_minLat == 0 || _maxLat == 0)
            {
                throw new Exception("BoundingBox location coordinates are missing or invalid in appsettings.json");
            }
        }

        public async Task<CheckInResponseDto> CheckInAsync(CheckInRequestDto request, string studentUsername, string clientIpAddress)
        {
            // --- 1. KIỂM TRA VỊ TRÍ (ĐÃ CẬP NHẬT) ---
            var userLogin = await _context.Logins
                .AsNoTracking()
                .FirstOrDefaultAsync(l => l.Username == studentUsername);

            if (userLogin == null)
            {
                throw new BiometricNotVerifiedException("Tài khoản không tồn tại.");
            }

            // 1.1 Kiểm tra tọa độ GPS client gửi lên (DÙNG LOGIC MỚI)
            if (!GeoHelper.IsWithinBoundingBox(request.ClientGpsCoordinates, _minLat, _maxLat, _minLon, _maxLon))
            {
                throw new SessionInvalidException("Tọa độ điểm danh (GPS) của bạn ở quá xa khu vực trường.");
            }

            // 1.2 Kiểm tra tọa độ lúc đăng nhập (DÙNG LOGIC MỚI)
            if (!GeoHelper.IsWithinBoundingBox(userLogin.LoginPosition, _minLat, _maxLat, _minLon, _maxLon))
            {
                throw new SessionInvalidException("Tọa độ lần đăng nhập gần nhất của bạn ở quá xa khu vực trường.");
            }

            // 1.3 Kiểm tra tọa độ từ IP (TẠM THỜI BỎ QUA THEO YÊU CẦU)
            /*
            var ipCoordinates = await _geoIpService.GetCoordinatesFromIpAsync(clientIpAddress);
            if (!GeoHelper.IsWithinBoundingBox(ipCoordinates, _minLat, _maxLat, _minLon, _maxLon))
            {
                throw new SessionInvalidException("Địa chỉ IP của bạn không nằm trong khu vực hợp lệ.");
            }
            */

            // --- 2. KIỂM TRA SINH TRẮC HỌC ---
            var faceData = await _context.FaceData
                .AsNoTracking()
                .Where(fd => fd.StudentCode == studentUsername && fd.UploadStatus == "verified" && fd.IsActive == true)
                .OrderByDescending(fd => fd.UploadedAt)
                .FirstOrDefaultAsync();

            if (faceData == null || string.IsNullOrEmpty(faceData.FaceEmbedding))
            {
                throw new BiometricNotVerifiedException("Sinh trắc học của bạn chưa được giáo viên xác thực.");
            }

            // --- 3. KIỂM TRA BUỔI HỌC VÀ QR TOKEN ---
            var session = await _context.ClassSessions
                .FirstOrDefaultAsync(s => s.Id == request.ClassSessionId);

            if (session == null || session.SessionStatus != "in_progress")
            {
                throw new SessionInvalidException("Buổi học đã kết thúc hoặc không tồn tại.");
            }

            if (string.IsNullOrEmpty(session.QrCodeData))
                throw new SessionInvalidException("Mã QR không hợp lệ (session data is null).");

            var qrData = JsonConvert.DeserializeObject<dynamic>(session.QrCodeData);
            string? sessionToken = qrData?.qrToken;

            if (sessionToken != request.QrToken)
            {
                throw new SessionInvalidException("Mã QR không hợp lệ.");
            }

            // --- 4. KIỂM TRA KHUÔN MẶT ---
            bool isFaceMatch = await _faceService.VerifyFaceAsync(faceData.FaceEmbedding, request.LiveSelfieBase64);
            if (!isFaceMatch)
            {
                throw new FaceMismatchException("Khuôn mặt không khớp. Vui lòng thử lại.");
            }

            // --- 5. GHI NHẬN ĐIỂM DANH ---
            var attendanceRecord = await _context.AttendanceRecords
                .FirstOrDefaultAsync(ar => ar.ClassSessionId == request.ClassSessionId && ar.StudentCode == studentUsername);

            if (attendanceRecord == null)
            {
                attendanceRecord = new AttendanceRecord
                {
                    ClassSessionId = request.ClassSessionId,
                    StudentCode = studentUsername
                };
                _context.AttendanceRecords.Add(attendanceRecord);
            }

            attendanceRecord.AttendanceStatus = "present";
            attendanceRecord.CheckInTime = DateTime.UtcNow;
            attendanceRecord.Method = "face_id";
            attendanceRecord.Notes = $"Vị trí GPS: {request.ClientGpsCoordinates}";

            await _context.SaveChangesAsync();

            return new CheckInResponseDto
            {
                Message = "Điểm danh thành công!",
                AttendanceStatus = "present",
                CheckInTime = (DateTime)attendanceRecord.CheckInTime
            };
        }

        /// <summary>
        /// (Sinh viên) Lấy lịch sử điểm danh
        /// </summary>
        public async Task<IEnumerable<AttendanceHistoryDto>> GetAttendanceHistoryAsync(string classCode, string studentUsername)
        {
            return await _context.ClassSessions
                .Where(s => s.ClassCode == classCode && s.SessionDate != null)
                .OrderBy(s => s.SessionDate)
                .Select(s => new AttendanceHistoryDto
                {
                    SessionTitle = s.Title ?? string.Empty,
                    // SỬA LỖI CS0030: Chuyển DateOnly? sang DateOnly
                    SessionDate = s.SessionDate.Value,
                    Status = _context.AttendanceRecords
                                .Where(ar => ar.ClassSessionId == s.Id && ar.StudentCode == studentUsername)
                                .Select(ar => ar.AttendanceStatus)
                                .FirstOrDefault() ?? "absent",
                    Method = _context.AttendanceRecords
                                .Where(ar => ar.ClassSessionId == s.Id && ar.StudentCode == studentUsername)
                                .Select(ar => ar.Method)
                                .FirstOrDefault()
                })
                .ToListAsync();
        }

        /// <summary>
        /// (Giảng viên) Lấy báo cáo buổi học
        /// </summary>
        public async Task<SessionReportDto?> GetSessionReportAsync(int sessionId)
        {
            var session = await _context.ClassSessions
                .AsNoTracking()
                .Include(s => s.ClassCodeNavigation)
                .FirstOrDefaultAsync(s => s.Id == sessionId);

            if (session == null) return null; // Giờ đã khớp với kiểu trả về

            var enrolledStudents = await _context.Enrollments
                .AsNoTracking()
                .Where(e => e.ClassCode == session.ClassCode)
                .Include(e => e.StudentCodeNavigation)
                .Select(e => e.StudentCodeNavigation)
                .ToListAsync();

            var attendanceRecords = await _context.AttendanceRecords
                .AsNoTracking()
                .Where(a => a.ClassSessionId == sessionId && a.StudentCode != null)
                .ToDictionaryAsync(a => a.StudentCode!, a => a);

            var reportList = new List<SessionReportStudentDto>();
            int presentCount = 0;

            foreach (var student in enrolledStudents)
            {
                if (student == null) continue;

                if (attendanceRecords.TryGetValue(student.StudentCode, out var record))
                {
                    reportList.Add(new SessionReportStudentDto
                    {
                        StudentCode = student.StudentCode,
                        FullName = student.FullName,
                        Status = record.AttendanceStatus ?? "unknown",
                        CheckInTime = record.CheckInTime
                    });
                    if (record.AttendanceStatus == "present" || record.AttendanceStatus == "late")
                        presentCount++;
                }
                else
                {
                    reportList.Add(new SessionReportStudentDto
                    {
                        StudentCode = student.StudentCode,
                        FullName = student.FullName,
                        Status = "absent",
                        CheckInTime = null
                    });
                }
            }

            return new SessionReportDto
            {
                SessionTitle = session.Title ?? string.Empty,
                TotalStudents = enrolledStudents.Count,
                Present = presentCount,
                Absent = enrolledStudents.Count - presentCount,
                Students = reportList
            };
        }

        /// <summary>
        /// (Giảng viên) Cập nhật điểm danh thủ công
        /// </summary>
        public async Task<bool> ManualUpdateAttendanceAsync(ManualUpdateRequestDto request, string lecturerUsername)
        {
            var record = await _context.AttendanceRecords
                .FirstOrDefaultAsync(a => a.ClassSessionId == request.ClassSessionId && a.StudentCode == request.StudentCode);

            if (record == null)
            {
                record = new AttendanceRecord
                {
                    ClassSessionId = request.ClassSessionId,
                    StudentCode = request.StudentCode
                };
                _context.AttendanceRecords.Add(record);
            }

            record.AttendanceStatus = request.NewStatus;
            record.Notes = request.Notes;
            record.Method = "manual";

            if (request.NewStatus == "present" && record.CheckInTime == null)
            {
                var session = await _context.ClassSessions.FindAsync(request.ClassSessionId);
                if (session != null && session.SessionDate.HasValue && session.StartTime.HasValue)
                {
                    // SỬA LỖI CS1929: Kết hợp DateOnly và TimeOnly
                    record.CheckInTime = new DateTime(session.SessionDate.Value, session.StartTime.Value);
                }
            }
            if (request.NewStatus == "absent")
            {
                record.CheckInTime = null;
            }

            await _context.SaveChangesAsync();
            return true;
        }
    }
}