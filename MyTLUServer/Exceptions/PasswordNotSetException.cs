// Exceptions/PasswordNotSetException.cs
// Custom exception để xử lý nghiệp vụ mật khẩu null.

using System;

namespace MyTLUServer.Application.Exceptions
{
    public class PasswordNotSetException : Exception
    {
        public PasswordNotSetException() : base("Mật khẩu chưa được thiết lập.")
        {
        }
    }
}