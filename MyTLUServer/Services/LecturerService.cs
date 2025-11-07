// File: MyTLUServer/Services/LecturerService.cs
using MyTLUServer.Interfaces;
using MyTLUServer.Application.DTOs;
using System.Threading.Tasks;
using MyTLUServerInterfaces;

namespace MyTLUServer.Services 
{
    public class LecturerService : ILecturerService
    {
        private readonly ILecturerRepository _repository;

        public LecturerService(ILecturerRepository repository)
        {
            _repository = repository;
        }

        // 1. (API 1) GetStudentsInClassAsync
        public async Task<IEnumerable<LecturerStudentDto>> GetStudentsInClassAsync(string classCode)
        {
            // (Sau này bạn có thể thêm logic nghiệp vụ, filter... ở đây)
            return await _repository.GetStudentsInClassAsync(classCode);
        }

        // 2. (API 2) RequestStudentEnrollmentAsync
        public async Task<LecturerStudentDto> RequestStudentEnrollmentAsync(string classCode, string studentCode, string lecturerCode)
        {
            // 1. Kiểm tra bảo mật: Giảng viên này có sở hữu lớp học không?
            var ownsClass = await _repository.CheckLecturerOwnsClassAsync(classCode, lecturerCode);
            if (!ownsClass)
            {
                // (Lỗi 403 Forbidden)
                throw new UnauthorizedAccessException("Bạn không có quyền thêm sinh viên vào lớp học này.");
            }

            // 2. Gọi Repository để tạo bản ghi "pending"
            var enrollmentRecord = await _repository.RequestStudentEnrollmentAsync(classCode, studentCode);

            // 3. Lấy thông tin DTO đầy đủ của sinh viên vừa thêm để trả về
            var studentDto = await _repository.GetStudentDetailsAsync(enrollmentRecord.StudentCode);
            if (studentDto == null)
            {
                throw new KeyNotFoundException("Không thể truy xuất thông tin sinh viên vừa thêm.");
            }
            return studentDto;
        }
    }
}