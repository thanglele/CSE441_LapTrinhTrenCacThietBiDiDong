<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quên mật khẩu - My TLU</title>
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
            <h2>Quên mật khẩu</h2>
            <p class="subtitle">Vui lòng nhập tài khoản (Mã SV/GV) để nhận mã OTP qua email.</p>

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

            <form action="{{ route('password.request.submit') }}" method="POST">
                @csrf
                <div class="form-group">
                    <label for="username">Tài khoản (Mã SV / Mã GV):</label>
                    <input type="text" id="username" name="username" placeholder="Tài khoản..." required value="{{ old('username') }}">
                </div>
                <button type="submit" class="login-button">Nhận mã OTP</button>
            </form>

            <div class="support-info" style="border-top: none; padding-top: 15px; text-align: center;">
                <p><a href="{{ route('login') }}">Quay lại trang Đăng nhập</a></p>
            </div>
        </div>
    </div>
</div>
</body>
</html>