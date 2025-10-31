<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đăng nhập - My TLU</title>
    <link rel="stylesheet" href="{{ asset('css/style.css') }}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>

<div class="container">

    <div class="left-panel">
        <div></div>

        <div class="main-branding">
            <div class="system-logo">
                <img src="{{ asset('image/logo-mytlu.jpg') }}" alt="My TLU Logo">
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
            <h2>Đăng nhập</h2>
            <p class="subtitle">Chào mừng bạn đến MyTLU! Hãy đăng nhập để tiếp tục.</p>

            @if (session('error'))
                <div class="error-message">
                    {{ session('error') }}
                </div>
            @endif

            <form action="{{ route('login.submit') }}" method="POST">
                @csrf

                <div class="form-group">
                    <label for="username">Tài khoản:</label>
                    <input type="text" id="username" name="username" placeholder="Tài khoản..." required value="{{ old('username') }}">
                </div>

                <div class="form-group">
                    <label for="password">Mật khẩu:</label>
                    <div class="password-wrapper">
                        <input type="password" id="password" name="password" placeholder="Mật khẩu..." required>
                        <span class="toggle-password" id="togglePassword">
                                <i class="fa-solid fa-eye"></i>
                            </span>
                    </div>
                </div>

                <div class="form-options">
                    <div class="remember-me">
                        <input type="checkbox" id="remember" name="remember">
                        <label for="remember">Ghi nhớ đăng nhập.</label>
                    </div>
                    <a href="#">Quên mật khẩu</a>
                </div>

                <button type="submit" class="login-button">Đăng nhập</button>
            </form>

            <div class="support-info">
                <p>(*) Đăng nhập bằng tài khoản/mật khẩu của trang khai báo thông tin</p>
                <p>(*) Email + điện thoại hỗ trợ:</p>
                <p><a href="mailto:Ngotm@tlu.edu.vn">Ngotm@tlu.edu.vn</a> - 0392513985</p>

            </div>
            <p class="copyright">© 2025 Đại học Thủy Lợi.</p>
        </div>
    </div>
</div>
<script src="{{ asset('js/login.js') }}"></script>
</body>
</html>