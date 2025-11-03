using Microsoft.AspNetCore.Mvc;
using MyTLUServer.Application.DTOs; // Thêm DTOs
using System.Collections.Generic;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IReportingService
    {
        /// <summary>
        /// (PKT) Xuất dữ liệu cấm thi
        /// </summary>
        Task<FileContentResult> ExportEligibilityAsync(List<string> classCodes, int minRate);

        /// <summary>
        /// (Trưởng Bộ môn) Lấy báo cáo tổng hợp cấp Bộ môn
        /// </summary>
        Task<DepartmentSummaryDto?> GetDepartmentSummaryAsync(string deptCode, string semester);

        /// <summary>
        /// (Trưởng Khoa) Lấy báo cáo tổng hợp cấp Khoa
        /// </summary>
        Task<FacultySummaryDto?> GetFacultySummaryAsync(string facultyCode, string semester);
    }
}