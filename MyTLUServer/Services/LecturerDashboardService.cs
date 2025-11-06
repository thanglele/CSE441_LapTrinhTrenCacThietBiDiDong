//// File: MyTLUServer/Services/LecturerDashboardService.cs
//using MyTLUServer.Application.DTOs;
//using MyTLUServer.Application.Interfaces;
//using System.Threading.Tasks;
//using System.Linq;

//namespace MyTLUServer.Application.Services 
//{
//    public class LecturerDashboardService : ILecturerDashboardService
//    {
//        private readonly IDashboardRepository _repository;

//        // 1. Tiêm (Inject) Lớp Data (Repository)
//        public LecturerDashboardService(IDashboardRepository repository)
//        {
//            _repository = repository;
//        }
        
//        public async Task<LecturerDashboardDto> GetDashboardDataAsync(string lecturerCode)
//        {
//            // 2. GỌI REPOSITORY (Lấy dữ liệu thô)
//            var statsTask = GetStatsAsync(lecturerCode);
//            var sessionsTask = _repository.GetTodaySessionsAsync(lecturerCode, DateTime.Today);
//            var classesTask = _repository.GetTeachingClassesAsync(lecturerCode);
//            var attendanceTask = _repository.GetRecentAttendanceAsync(lecturerCode, 5);

//            await Task.WhenAll(statsTask, sessionsTask, classesTask, attendanceTask);
            
//            var stats = await statsTask;
//            var todaySessions = await sessionsTask;
//            var teachingClasses = await classesTask;
//            var recentAttendance = await attendanceTask;

//            // 3. ÁNH XẠ (MAP) từ Model CSDL -> Model DTO (Nghiệp vụ)
//            var dashboardDto = new LecturerDashboardDto
//            {
//                Stats = stats,
//                TodaySessions = todaySessions.Select(s => new ScheduleSessionDto
//                {
//                    ClassSessionId = s.Id, // (Nguồn: 618)
//                    ClassName = s.Class.ClassName, // (Nguồn: 618)
//                    SessionTitle = s.Title, // (Nguồn: 618)
//                    StartTime = s.StartTime, // (Nguồn: 618)
//                    EndTime = s.EndTime, // (Nguồn: 618)
//                    Location = s.SessionLocation, // (Nguồn: 618)
//                    AttendanceStatus = s.SessionStatus // (Nguồn: 618)
//                }),
//                TeachingClasses = teachingClasses.Select(c => new TeachingClassDto
//                {
//                    ClassCode = c.ClassCode, // (Nguồn: 618)
//                    ClassName = c.ClassName, // (Nguồn: 618)
//                    Tag = $"{c.MaxStudents} SV" // (Nguồn: 618)
//                }),
//                RecentAttendance = recentAttendance.Select(ar => new RecentAttendanceDto
//                {
//                    Subject = ar.ClassSession.Class.Subject.SubjectName, // (Nguồn: 618)
//                    ClassCode = ar.ClassSession.Class.ClassCode, // (Nguồn: 618)
//                    SessionTitle = ar.ClassSession.Title, // (Nguồn: 618)
//                    SessionDate = ar.ClassSession.SessionDate, // (Nguồn: 618)
//                    CheckInTime = ar.CheckInTime?.ToString("HH:mm"), // (Nguồn: 618)
//                    PresentCount = 0, // (Cần nghiệp vụ tính toán thêm)
//                    AttendanceRate = "0%" // (Cần nghiệp vụ tính toán thêm)
//                })
//            };

//            return dashboardDto;
//        }

//        // Hàm helper (Hàm phụ) để gộp 3 truy vấn Stats
//        private async Task<LecturerStatsDto> GetStatsAsync(string lecturerCode)
//        {
//            var classCountTask = _repository.GetClassCountAsync(lecturerCode);
//            var studentCountTask = _repository.GetStudentCountAsync(lecturerCode);
//            var sessionsTask = _repository.GetTodaySessionsAsync(lecturerCode, DateTime.Today);
            
//            await Task.WhenAll(classCountTask, studentCountTask, sessionsTask);

//            return new LecturerStatsDto
//            {
//                TotalClasses = await classCountTask,
//                TotalStudents = await studentCountTask,
//                TodaySessionsCount = (await sessionsTask).Count()
//            };
//        }
//    }
//}