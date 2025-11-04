using Microsoft.EntityFrameworkCore;
using MyTLUServer.Application.DTOs;
using MyTLUServer.Application.Interfaces;
using MyTLUServer.Domain.Models;
using MyTLUServer.Infrastructure.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    public class DeanService : IDeanService
    {
        private readonly AppDbContext _context;

        public DeanService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// (VP Khoa) Lấy danh sách Giảng viên
        /// </summary>
        public async Task<IEnumerable<LecturerListItemDto>> GetAllLecturersAsync(string? departmentCode = null)
        {
            var query = _context.Lecturers
                .Include(l => l.DeptCodeNavigation)
                .Include(l => l.LecturerCodeNavigation)
                .AsNoTracking();

            // Lọc theo bộ môn (nếu có)
            if (!string.IsNullOrEmpty(departmentCode))
            {
                query = query.Where(l => l.DeptCode == departmentCode);
            }

            return await query
                .Select(l => new LecturerListItemDto
                {
                    LecturerCode = l.LecturerCode,
                    FullName = l.FullName,
                    DepartmentName = l.DeptCodeNavigation != null ? l.DeptCodeNavigation.DeptName : "N/A",
                    Degree = l.Degree,
                    // 'LecturerCodeNavigation' chính là 'Login' object
                    AccountStatus = l.LecturerCodeNavigation.AccountStatus
                })
                .ToListAsync();
        }

        /// <summary>
        /// (VP Khoa) Lấy chi tiết một Giảng viên
        /// </summary>
        public async Task<Lecturer?> GetLecturerByCodeAsync(string lecturerCode)
        {
            return await _context.Lecturers
                .Include(l => l.DeptCodeNavigation)
                .AsNoTracking()
                .FirstOrDefaultAsync(l => l.LecturerCode == lecturerCode);
        }

        /// <summary>
        /// (VP Khoa) Tạo mới Giảng viên (bao gồm cả tài khoản Login)
        /// </summary>
        public async Task<Lecturer> CreateLecturerAsync(CreateLecturerDto dto)
        {
            // 1. Kiểm tra (Validation)
            if (await _context.Logins.AnyAsync(l => l.Username == dto.LecturerCode || l.Email == dto.Email))
            {
                throw new InvalidOperationException("Mã Giảng viên (Username) hoặc Email đã tồn tại.");
            }
            if (string.IsNullOrEmpty(dto.DeptCode) || !await _context.Departments.AnyAsync(d => d.DeptCode == dto.DeptCode))
            {
                // Gán tạm DeptCode nếu chưa có, hoặc ném lỗi
                throw new InvalidOperationException("Mã Bộ môn không hợp lệ.");
                // Hoặc cho phép null
            }

            // 2. Dùng Transaction để đảm bảo tạo đồng bộ 2 bảng
            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // 3. Tạo tài khoản Login (bảng Login)
                var newLogin = new Login
                {
                    Username = dto.LecturerCode,
                    Email = dto.Email,
                    UserRole = "lecturer",
                    PasswordHash = null,
                    AccountStatus = "active",
                    CreatedAt = DateTime.UtcNow,
                    UpdatedAt = DateTime.UtcNow
                };
                _context.Logins.Add(newLogin);

                // 4. Tạo hồ sơ Giảng viên (bảng Lecturers)
                var newLecturer = new Lecturer
                {
                    LecturerCode = dto.LecturerCode,
                    FullName = dto.FullName,
                    PhoneNumber = dto.PhoneNumber,
                    DateOfBirth = dto.DateOfBirth,
                    Gender = dto.Gender,
                    DeptCode = dto.DeptCode,
                    Degree = dto.Degree,
                    AcademicRank = dto.AcademicRank,
                    OfficeLocation = dto.OfficeLocation
                };
                _context.Lecturers.Add(newLecturer);

                // 5. Lưu và Commit
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                return newLecturer;
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                // Ghi log (ex)
                throw new Exception("Đã xảy ra lỗi trong quá trình tạo giảng viên.", ex);
            }
        }

        /// <summary>
        /// (VP Khoa) Cập nhật thông tin Giảng viên (chỉ bảng Lecturers)
        /// </summary>
        public async Task<bool> UpdateLecturerAsync(string lecturerCode, UpdateLecturerDto dto)
        {
            var lecturer = await _context.Lecturers.FindAsync(lecturerCode);
            if (lecturer == null)
            {
                return false; // Không tìm thấy
            }

            lecturer.FullName = dto.FullName;
            lecturer.PhoneNumber = dto.PhoneNumber;
            lecturer.DateOfBirth = dto.DateOfBirth;
            lecturer.Gender = dto.Gender;
            lecturer.DeptCode = dto.DeptCode;
            lecturer.Degree = dto.Degree;
            lecturer.AcademicRank = dto.AcademicRank;
            lecturer.OfficeLocation = dto.OfficeLocation;

            _context.Lecturers.Update(lecturer);
            await _context.SaveChangesAsync();
            return true;
        }

        /// <summary>
        /// (VP Khoa) Cập nhật trạng thái tài khoản Giảng viên (chỉ bảng Logins)
        /// </summary>
        public async Task<bool> UpdateLecturerStatusAsync(string lecturerCode, UpdateLecturerStatusDto dto)
        {
            // Tìm tài khoản Login của Giảng viên
            var login = await _context.Logins.FindAsync(lecturerCode);

            // Đảm bảo là tài khoản GV (không vô hiệu hóa nhầm admin)
            if (login == null || login.UserRole != "lecturer")
            {
                return false;
            }

            login.AccountStatus = dto.AccountStatus;
            login.UpdatedAt = DateTime.UtcNow;

            _context.Logins.Update(login);
            await _context.SaveChangesAsync();
            return true;
        }
    }
}