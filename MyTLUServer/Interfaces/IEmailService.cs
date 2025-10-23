using System.Threading.Tasks;

namespace MyTLUServer.Application.Interfaces
{
    public interface IEmailService
    {
        /// <summary>
        /// Gửi một email chung
        /// </summary>
        Task SendEmailAsync(string toEmail, string subject, string body);

        /// <summary>
        /// Gửi email OTP với template HTML
        /// </summary>
        Task SendOtpEmailAsync(string toEmail, string otp);
    }
}