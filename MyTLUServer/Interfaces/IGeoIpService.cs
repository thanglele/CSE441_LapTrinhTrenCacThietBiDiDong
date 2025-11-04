// Application/Interfaces/IGeoIpService.cs
using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IGeoIpService
    {
        /// <summary>
        /// Lấy tọa độ (dưới dạng "lat,lon") từ địa chỉ IP
        /// </summary>
        Task<string?> GetCoordinatesFromIpAsync(string ipAddress);
    }
}