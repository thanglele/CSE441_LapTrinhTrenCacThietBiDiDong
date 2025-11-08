<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt lại mật khẩu - My TLU</title>
    @vite(['resources/css/login.css'])
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<div class="container">
    <div class="left-panel">
        <img src="{{ asset('img/logo-tlu.png') }}" alt="Logo Đại học Thủy Lợi" class="top-logo">
        <div class="main-branding">
            <div class="system-logo">
                <img src="{{ asset('img/logo-mytlu.png') }}" alt="My TLU Logo">
                <span>My TLU</span>
            </div>
            <h1>HỆ THỐNG QUẢN LÝ ĐIỂM DANH BẰNG NHẬN DIỆN KHUÔN MẶT TRƯỜNG ĐẠI HỌC THỦY LỢI</h1>
        </div>
        <div class="bottom-branding">
            <h2>ĐẠI HỌC THỦY LỢI</h2>
            <h3>THUYLOI UNIVERSITY</h3>
        </div>
    </div>
    <div class="right-panel">
        <div class="login-card">
            <h2>Tạo mật khẩu mới</h2>
            <p class="subtitle">OTP đã được xác thực. Vui lòng nhập mật khẩu mới.</p>

            @if (session('error'))
                <div class="error-message"> {{ session('error') }} </div>
            @endif
            @if ($errors->any())
                <div class="error-message">
                    <ul>
                        @foreach ($errors->all() as $error) <li>{{ $error }}</li> @endforeach
                    </ul>
                </div>
            @endif

            <form action="{{ route('password.reset.submit') }}" method="POST">
                @csrf

                <input type="hidden" name="resetToken" value="{{ $resetToken ?? old('resetToken') }}">

                <div class="form-group">
                    <label for="username">Tài khoản:</label>
                    <input type="text" id="username" name="username" readonly
                           value="{{ $username ?? old('username') }}">
                </div>

                <div class="form-group">
                    <label for="newPassword">Mật khẩu mới:</label>
                    <input type="password" id="newPassword" name="newPassword" placeholder="Mật khẩu mới..." required>
                </div>

                <div class="form-group">
                    <label for="newPassword_confirmation">Xác nhận mật khẩu mới:</label>
                    <input type="password" id="newPassword_confirmation" name="newPassword_confirmation" placeholder="Nhập lại mật khẩu mới..." required>
                </div>

                <button type="submit" class="login-button">Đặt lại mật khẩu</button>
            </form>
        </div>
    </div>
</div>
</body>
</html>