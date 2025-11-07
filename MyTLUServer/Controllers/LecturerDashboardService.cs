// File: MyTLUServer/Services/LecturerDashboardService.cs
using MyTLUServer.Interfaces;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Domain.Models; // (Cần để biết Model CSDL)
using System.Threading.Tasks;
using System.Linq;

namespace MyTLUServer.Application.Services // (Namespace Service của bạn)
{
    public class LecturerDashboardService : ILecturerDashboardService
    {
        private readonly IDashboardRepository _repository;

        // 1. Tiêm (Inject) Lớp Data (Repository)
        public LecturerDashboardService(IDashboardRepository repository)
        {
            _repository = repository;
        }

        public async Task<List<ScheduleSessionDto>> GetMyScheduleByDate(string lecturerCode, DateTime today)
        {
            // 2. GỌI REPOSITORY (Chạy tuần tự)

            // Lấy Lịch học hôm nay
            var todaySessions = await _repository.GetTodaySessionsAsync(lecturerCode, today);


            //// 3. ÁNH XẠ (MAP) DỮ LIỆU
            List<ScheduleSessionDto> dashboardDto = new List<ScheduleSessionDto>();
            foreach (var session in todaySessions)
            {
                dashboardDto.Add(new ScheduleSessionDto()
                {
                    ClassSessionId = session.ClassSessionId,
                    ClassName = session.ClassName,
                    SessionTitle = session.SessionTitle,
                    StartTime = session.StartTime,
                    EndTime = session.EndTime,
                    Location = session.Location,
                    AttendanceStatus = session.AttendanceStatus
                });
            }

            return dashboardDto;
        }

        // ==========================================================
        // === HÀM NÀY ĐÃ ĐƯỢC SỬA (BỎ TASK.WHENALL) ===
        // ==========================================================
        public async Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode)
        {
            // 2. GỌI REPOSITORY (Chạy tuần tự)

            // Lấy Lịch học hôm nay
            var todaySessions = await _repository.GetTodaySessionsAsync(lecturerCode, DateTime.Today);

            // Lấy Lớp đang dạy
            var teachingClasses = await _repository.GetTeachingClassesAsync(lecturerCode);

            // Lấy Điểm danh gần đây
            var recentAttendance = await _repository.GetRecentAttendanceAsync(lecturerCode, 5);

            // Lấy Số lớp
            var totalClasses = await _repository.GetClassCountAsync(lecturerCode);

            // Lấy Số SV
            var totalStudents = await _repository.GetStudentCountAsync(lecturerCode);


            // 3. ÁNH XẠ (MAP) DỮ LIỆU
            var dashboardDto = new LecturerDashboardDto
            {
                Stats = new LecturerStatsDto
                {
                    TotalClasses = totalClasses,
                    TotalStudents = totalStudents,
                    TodaySessionsCount = todaySessions.Count() // Đếm từ list đã lấy
                },
                TodaySessions = todaySessions,
                TeachingClasses = teachingClasses,
                RecentAttendance = recentAttendance
            };

            return dashboardDto;
        }
        public async Task<IEnumerable<LecturerSubjectDto>> GetSubjectsAsync(string lecturerCode)
        {
            // (Sau này bạn có thể thêm logic nghiệp vụ, filter... ở đây)
            return await _repository.GetSubjectsAsync(lecturerCode);
        }
        public async Task<IEnumerable<LecturerClassDto>> GetClassesAsync(string lecturerCode)
        {
            // (Sau này bạn có thể thêm logic nghiệp vụ, filter... ở đây)
            return await _repository.GetClassesAsync(lecturerCode);
        }
        

    }
}