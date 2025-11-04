// Application/Interfaces/IFileStorageService.cs
using Microsoft.AspNetCore.Http;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IFileStorageService
    {
        /// <summary>
        /// Lưu file và trả về đường dẫn (URL)
        /// </summary>
        /// <param name="file">File ảnh</param>
        /// <param name="subFolder">Thư mục con (ví dụ: "profiles" hoặc "enrollments")</param>
        /// <param name="fileName">Tên file (không bao gồm phần mở rộng)</param>
        /// <returns>Đường dẫn web tới file</returns>
        Task<string> SaveFileAsync(IFormFile file, string subFolder, string fileName);
    }
}