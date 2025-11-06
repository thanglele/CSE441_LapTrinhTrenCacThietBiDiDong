<<<<<<< Updated upstream
﻿// Application/Interfaces/IReportingService.cs
using Microsoft.AspNetCore.Mvc;
=======
﻿using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs;
>>>>>>> Stashed changes
using System.Collections.Generic;
using System.Security.Claims; // Cần dùng ClaimsPrincipal
using System.Threading.Tasks;
using System; // Cần dùng DateOnly

namespace MyTLUServer.Application.Interfaces
{
    public interface IReportingService
    {
        /// <summary>
        /// (PKT) Xuất dữ liệu cấm thi
        /// </summary>
        Task<FileContentResult> ExportEligibilityAsync(List<string> classCodes, int minRate);

<<<<<<< Updated upstream
        // (Các hàm báo cáo khác cho DeptHead, DeanOffice sẽ ở đây)
=======
        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp cho Bộ môn
        /// </summary>
        Task<DeptAttendanceSummaryDto> GetDepartmentSummaryAsync(string deptCode, string semester);

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cho Khoa
        /// </summary>
        Task<FacultyAttendanceSummaryDto> GetFacultySummaryAsync(string facultyCode, string semester);

        /// <summary>
        /// (MỚI) (Giảng viên/Quản lý) Lấy lịch sử các buổi học (có phân trang)
        /// </summary>
        Task<PaginatedSessionHistoryDto> GetSessionHistoryAsync(
            ClaimsPrincipal user, // Để kiểm tra quyền
            DateOnly? startDate,
            DateOnly? endDate,
            string? lecturerCode,
            string? classCode,
            string? deptCode,
            int page,
            int pageSize
        );
>>>>>>> Stashed changes
    }
}