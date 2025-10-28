// Application/Services/MockGeoIpService.cs
using MyTLUServer.Application.Interfaces;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    // LƯU Ý: Đây là service giả lập. 
    // Trong thực tế, bạn cần tích hợp GeoIP (ví dụ: MaxMind)
    public class MockGeoIpService : IGeoIpService
    {
        // Tọa độ giả lập của TLU (Đại học Thủy Lợi)
        private const string TLU_COORDS = "21.0064,105.8248";

        public async Task<string?> GetCoordinatesFromIpAsync(string ipAddress)
        {
            // Giả lập: Nếu là IP localhost hoặc dải IP nội bộ
            if (ipAddress == "::1" || ipAddress == "127.0.0.1" || ipAddress.StartsWith("192.168."))
            {
                return await Task.FromResult(TLU_COORDS);
            }

            // Giả lập: IP từ bên ngoài
            // (Trong thực tế, bạn sẽ gọi API hoặc DB GeoIP ở đây)
            // return await Task.FromResult("10.0.0.1,10.0.0.1"); // Tọa độ xa
            return await Task.FromResult(TLU_COORDS); // Giả lập luôn đúng
        }
    }
}