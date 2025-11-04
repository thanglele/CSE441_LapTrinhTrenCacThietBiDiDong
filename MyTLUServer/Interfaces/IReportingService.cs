// Application/Interfaces/IReportingService.cs
using Microsoft.AspNetCore.Mvc;
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

        // (Các hàm báo cáo khác cho DeptHead, DeanOffice sẽ ở đây)
    }
}