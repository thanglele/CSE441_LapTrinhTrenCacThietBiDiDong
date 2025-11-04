using Microsoft.Extensions.Configuration;
using MyTLUServer.Application.Interfaces;
using System;
using System.Net;
using System.Net.Mail;
using System.Threading.Tasks;

namespace MyTLUServer.Application.Services
{
    public class SmtpEmailService : IEmailService
    {
        private readonly string _from;
        private readonly string _pass;
        private readonly string _host;
        private readonly int _port;

        public SmtpEmailService(IConfiguration configuration)
        {
            var smtpSettings = configuration.GetSection("SmtpSettings");
            _host = smtpSettings["Host"] ?? string.Empty;
            _port = int.Parse(smtpSettings["Port"] ?? "587"); // Thêm port mặc định
            _from = smtpSettings["From"] ?? string.Empty;
            _pass = smtpSettings["Password"] ?? string.Empty;
        }

        public async Task SendEmailAsync(string toEmail, string subject, string body)
        {
            // (Triển khai logic gửi email chung nếu cần)
            await Task.CompletedTask;
        }

        public async Task SendOtpEmailAsync(string toEmail, string otp)
        {
            if (string.IsNullOrEmpty(_host) || string.IsNullOrEmpty(_from) || string.IsNullOrEmpty(_pass))
            {
                Console.WriteLine("[SmtpEmailService] SMTP settings are missing.");
                return;
            }

            try
            {
                MailMessage mail = new MailMessage();
                SmtpClient SmtpServer = new SmtpClient(_host);

                mail.From = new MailAddress(_from, "Hệ thống MyTLU"); // Thêm tên hiển thị
                mail.To.Add(toEmail);
                mail.Subject = $"Đây là mã xác minh của bạn: {otp}";
                mail.IsBodyHtml = true;
                mail.Body = GetHtmlBody(otp);

                SmtpServer.Port = _port;
                SmtpServer.Credentials = new NetworkCredential(_from, _pass);
                SmtpServer.EnableSsl = true;

                await SmtpServer.SendMailAsync(mail);
            }
            catch (Exception ex)
            {
                // Rất quan trọng: Ghi log lỗi gửi email
                Console.WriteLine($"[SmtpEmailService] Failed to send email to {toEmail}: {ex.Message}");
                // Không ném lỗi ra ngoài để không làm gián đoạn luồng reset pass
                // (User vẫn nhận được 200 OK)
            }
        }

        private string GetHtmlBody(string otp)
        {
            // Lấy thời gian hiện tại
            string thoiGianTao = DateTime.Now.ToString("dd/MM/yyyy HH:mm:ss");

            // Thay thế các placeholder
            // Lưu ý: Đã sửa lỗi class="""" thành class=""...""
            string htmlBody = $@"
<div class=""""><div class=""aHl""></div><div id="":pi"" tabindex=""-1""></div><div id="":ps"" class=""ii gt"">
<div id="":p0"" class=""a3s aiL ""><u></u>
    <div style=""padding:0;margin:0;font-family:Tahoma;font-size:14px;display:block;background:#ffffff"" bgcolor=""#ffffff"">
        <img width=""1px"" height=""1px"" alt="""" class=""CToWUd"" data-bit=""iit"">
        <table align=""center"" cellpadding=""0"" cellspacing=""0"" width=""100%"" height=""100%"">
            <tbody>
                <tr>
                    <td align=""center"" valign=""top"" bgcolor=""#ffffff"" width=""100%"">
                        <table cellspacing=""0"" cellpadding=""0"" width=""100%"">
                            <tbody>
                                <tr>
                                    <td style=""background:#1f1f1f"" width=""100%"">
                                        <center>
                                            <table cellspacing=""0"" cellpadding=""0"" width=""100%"" style=""max-width:600px"">
                                                <tbody>
                                                    <tr>
                                                        <td valign=""top"" style=""background:#1f1f1f;padding:10px 10px 10px 20px"">
                                                            <a href=""#"" style=""text-decoration:none"">
                                                                <img src=""https://cdn.thanglele.cloud/img/lele.png"" height=""40"" alt=""lele Logo"" class=""CToWUd"" data-bit=""iit"">
                                                            </a>
                                                        </td>
                                                        <td valign=""top"" style=""background:#1f1f1f;padding:10px 15px 10px 10px"">
                                                            <table border=""0"" cellpadding=""0"" cellspacing=""0"" align=""right"">
                                                                <tbody>
                                                                    <tr>
                                                                        <td align=""right"" style=""color:#b9b9b9"">
                                                                            Hệ thống Điểm danh Sinh viên MyTLU
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </center>
                                    </td>
                                </tr>
                                <tr>
                                    <td style=""background:#1660cf"" width=""100%"">
                                        <center>
                                            <table cellspacing=""0"" cellpadding=""10"" width=""100%"" style=""max-width:600px"">
                                                <tbody>
                                                    <tr>
                                                        <td style=""font-family:tahoma;background:#1660cf;color:#ffffff;font-weight:bold;font-size:16px;padding-bottom:0"">
                                                            THƯ XÁC THỰC OTP
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td style=""font-style:italic;color:#ffffff;font-size:10pt"">
                                                            Email tự động vui lòng không phản hồi
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </center>
                                    </td>
                                </tr>
                                <tr>
                                    <td style=""color:#282828"">
                                        <center>
                                            <table cellpadding=""0"" cellspacing=""0"" width=""100%"" style=""max-width:600px"">
                                                <tbody>
                                                    <tr>
                                                        <td align=""left"" style=""padding:20px"">
                                                            <div>
                                                                <p>Nhập mã gồm 6 chữ số bên dưới để xác minh danh tính của bạn và lấy lại quyền truy cập vào tài khoản MyTLU của bạn.</p>
                                                                <b>OTP: {otp}</b><br>
                                                                <p>Mã OTP có có hiệu lực trong vòng 5 phút.</p>
                                                                <p>Cảm ơn bạn đã giúp chúng tôi bảo vệ tài khoản của bạn.</p>
                                                                <p>Hệ thống MyTLU</p>
                                                                <p>===================================================</p>
                                                                <p>Nếu bạn không thực hiện thao tác này, hãy bỏ qua Email này.</p>
                                                                <p>Thời gian: {thoiGianTao}</p>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </center>
                                    </td>
                                </tr>
                                <tr>
                                    <td valign=""top"" style=""background-color:#363636"">
                                        <center>
                                            <table border=""0"" cellpadding=""0"" cellspacing=""0"" width=""100%"" style=""max-width:600px"">
                                                <tbody>
                                                    <tr>
                                                        <td valign=""top"" style=""padding:20px"">
                                                            <table cellspacing=""0"" cellpadding=""0"" width=""100%"">
                                                                <tbody>
                                                                    <tr>
                                                                        <td style=""padding-top:15px;padding-right:20px;color:#e9e9e9"">
                                                                            <b>Trường Đại học Thủy lợi</b>
                                                                            <br>
                                                                            Địa chỉ: 175 Tây Sơn, Trung Liệt, Đống Đa, Hà Nội
                                                                        </td>
                                                                        <td style=""padding-top:15px;padding-right:20px;color:#e9e9e9"">
                                                                            <b>Hệ thống Điểm danh Sinh viên MyTLU</b>
                                                                            <br>
                                                                        </td>
                                                                    </tr>
                                                                </tbody>
                                                            </table>
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </center>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>
</div>";
            return htmlBody;
        }
    }
}