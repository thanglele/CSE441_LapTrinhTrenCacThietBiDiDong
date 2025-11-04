<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'My TLU')</title>
    <link rel="stylesheet" href="{{ asset('css/style.css') }}">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<div class="app-container">

    <nav class="sidebar">
        <div class="sidebar-header">
            <img src="{{ asset('img/logo-mytlu.png') }}" alt="My TLU Logo" class="sidebar-logo">
            <div class="sidebar-title">
                <span>My TLU</span>
                <strong>Giảng viên</strong>
            </div>
        </div>

        <ul class="sidebar-nav">
            @php
                $profile = session('user_profile', []);
                $fullName = isset($profile['fullName']) ? $profile['fullName'] : 'Giảng viên';
            @endphp

            <li class="nav-item {{ Route::is('dashboard') ? 'active' : '' }}">
                <a href="{{ route('dashboard') }}">
                    <i class="fa-solid fa-house-chimney"></i>
                    <span>Trang chủ giảng viên</span>
                </a>
            </li>

            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Quản lý lớp và môn học</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="#">Quản lý môn học</a></li>
                    <li><a href="#">Quản lý lớp</a></li>
                    <li><a href="#">Quản lý nhận diện khuôn mặt</a></li>
                </ul>
            </li>

            <li class="nav-item">
                <a href="#">
                    <i class="fa-solid fa-users"></i>
                    <span>Quản lý sinh viên</span>
                </a>
            </li>

            <li class="nav-item">
                <a href="#">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Quản lý buổi học</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="#">
                    <i class="fa-solid fa-qrcode"></i>
                    <span>Tạo mã QR</span>
                </a>
            </li>
            <li class="nav-item">
                <a href="#">
                    <i class="fa-solid fa-clipboard-user"></i>
                    <span>Quản lý điểm danh</span>
                </a>
            </li>
        </ul>

        <div class="sidebar-user">
            <i class="fa-solid fa-circle-user user-avatar"></i>
            <div class="user-info">
                <span>{{ $fullName }}</span>
                <a href="{{ route('logout') }}">Đăng xuất</a>
            </div>
        </div>
    </nav>

    <div class="main-wrapper">
        <header class="top-header">
            <div class="header-right">
                <a href="#" class="notification-bell">
                    <i class="fa-solid fa-bell"></i>
                </a>
                <div class="header-user">
                    <i class="fa-solid fa-circle-user"></i>
                    <div>
                        <span>{{ $fullName }}</span>
                        <small>Giảng viên</small>
                    </div>
                </div>
            </div>
        </header>

        <main class="content">
            @yield('content')
        </main>
    </div>

</div>

<script>
    document.querySelectorAll('.has-submenu > a').forEach(menu => {
        menu.addEventListener('click', function(e) {
            e.preventDefault();
            let parent = this.parentElement;
            parent.classList.toggle('open');
        });
    });
</script>
</body>
</html>