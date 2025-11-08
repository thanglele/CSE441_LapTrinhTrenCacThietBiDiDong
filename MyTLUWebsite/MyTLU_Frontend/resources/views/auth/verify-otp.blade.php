<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Xác thực OTP - My TLU</title>
    @vite(['resources/css/login.css'])
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        .resend-otp-btn {
            background: none; border: none; color: var(--primary-color);
            cursor: pointer; padding: 0; font-size: 14px; font-family: inherit;
        }
        .resend-otp-btn:disabled { color: #999; cursor: not-allowed; text-decoration: none; }
        .info-message {
            background-color: #e6f7ff; color: #1890ff; border: 1px solid #91d5ff;
            padding: 10px 15px; border-radius: 5px; margin-bottom: 20px;
            text-align: left; font-size: 14px;
        }
    </style>
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
            <h2>Xác thực tài khoản</h2>

            @if (session('success'))
                <div class="success-message"> {{ session('success') }} </div>
            @endif
            @if (session('error'))
                <div class="error-message"> {{ session('error') }} </div>
            @endif
            <div id="resend-status"></div> @if ($errors->any())
                <div class="error-message">
                    <ul>
                        @foreach ($errors->all() as $error) <li>{{ $error }}</li> @endforeach
                    </ul>
                </div>
            @endif

            <form action="{{ route('password.verify.submit') }}" method="POST">
                @csrf

                <div class="form-group">
                    <label for="username">Tài khoản:</label>
                    <input type="text" id="username" name="username" readonly
                           value="{{ $username ?? old('username') }}">
                </div>

                <div class="form-group">
                    <label for="otp">Mã OTP:</label>
                    <input type="text" id="otp" name="otp" placeholder="Nhập 6 số OTP từ email..." required autofocus>
                </div>

                <div class="form-options">
                    <a href="{{ route('login') }}">Quay lại đăng nhập</a>
                    <button type="button" class="resend-otp-btn" id="resendBtn" disabled>
                        Gửi lại OTP (60s)
                    </button>
                </div>

                <button type="submit" class="login-button">Xác thực OTP</button>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        const resendBtn = document.getElementById('resendBtn');
        const usernameInput = document.getElementById('username');
        const statusDiv = document.getElementById('resend-status');
        const csrfToken = document.querySelector('form input[name="_token"]').value;
        let timer = 60;

        function startTimer() {
            timer = 60;
            resendBtn.disabled = true;
            const interval = setInterval(() => {
                timer--;
                resendBtn.textContent = `Gửi lại OTP (${timer}s)`;
                if (timer <= 0) {
                    clearInterval(interval);
                    resendBtn.textContent = 'Gửi lại OTP';
                    resendBtn.disabled = false;
                }
            }, 1000);
        }
        startTimer(); // Bắt đầu đếm ngược ngay khi tải trang

        resendBtn.addEventListener('click', async function() {
            const username = usernameInput.value;
            if (!username) {
                statusDiv.innerHTML = '<div class="error-message">Thiếu thông tin tài khoản.</div>';
                return;
            }
            resendBtn.disabled = true;
            statusDiv.innerHTML = '<div class="info-message">Đang gửi lại OTP...</div>';
            try {
                // Gọi API /auth/request-reset (chính là route 'password.request.submit')
                const response = await fetch("{{ route('password.request.submit') }}", {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken,
                        'Accept': 'application/json'
                    },
                    body: JSON.stringify({ username: username })
                });
                if (response.ok) {
                    statusDiv.innerHTML = '<div class="success-message">Đã gửi lại OTP thành công!</div>';
                    startTimer();
                } else {
                    statusDiv.innerHTML = '<div class="error-message">Gửi lại OTP thất bại.</div>';
                    resendBtn.disabled = false;
                }
            } catch (error) {
                statusDiv.innerHTML = '<div class="error-message">Lỗi kết nối.</div>';
                resendBtn.disabled = false;
            }
        });
    });
</script>
</body>
</html>