// Application/Exceptions/CheckInException.cs
using System;

// Lỗi 400 - Buổi học/QR không hợp lệ
public class SessionInvalidException : Exception
{
    public SessionInvalidException(string message) : base(message) { }
}

// Lỗi 401 - Khuôn mặt không khớp
public class FaceMismatchException : Exception
{
    public FaceMismatchException(string message) : base(message) { }
}

// Lỗi 403 - Sinh trắc học chưa được duyệt
public class BiometricNotVerifiedException : Exception
{
    public BiometricNotVerifiedException(string message) : base(message) { }
}