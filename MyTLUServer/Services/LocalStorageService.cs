// Application/Services/LocalStorageService.cs
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Hosting; // Cần IWebHostEnvironment
using MyTLUServer.Application.Interfaces;
using System.IO;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    public class LocalStorageService : IFileStorageService
    {
        private readonly IWebHostEnvironment _env;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public LocalStorageService(IWebHostEnvironment env, IHttpContextAccessor httpContextAccessor)
        {
            _env = env;
            _httpContextAccessor = httpContextAccessor;
        }

        public async Task<string> SaveFileAsync(IFormFile file, string subFolder, string fileName)
        {
            // Đường dẫn vật lý tới thư mục wwwroot
            var wwwRootPath = _env.WebRootPath;
            if (string.IsNullOrEmpty(wwwRootPath))
            {
                // Fallback nếu wwwroot không được cấu hình
                wwwRootPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
                if (!Directory.Exists(wwwRootPath))
                    Directory.CreateDirectory(wwwRootPath);
            }

            // Đường dẫn tới thư mục lưu trữ (ví dụ: wwwroot/images/profiles)
            var folderPath = Path.Combine(wwwRootPath, "images", subFolder);
            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            // Tạo tên file duy nhất (ví dụ: 123456.jpg)
            var fileExtension = Path.GetExtension(file.FileName);
            var fullFileName = $"{fileName}{fileExtension}";
            var physicalPath = Path.Combine(folderPath, fullFileName);

            // Lưu file
            await using (var stream = new FileStream(physicalPath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            // Lấy request scheme và host (ví dụ: "https://mytlu.edu.vn")
            var request = _httpContextAccessor.HttpContext.Request;
            var baseUrl = $"{request.Scheme}://{request.Host}";

            // Trả về URL (ví dụ: https://mytlu.edu.vn/images/profiles/123456.jpg)
            var fileUrl = $"{baseUrl}/images/{subFolder}/{fullFileName}";
            return fileUrl;
        }
    }
}