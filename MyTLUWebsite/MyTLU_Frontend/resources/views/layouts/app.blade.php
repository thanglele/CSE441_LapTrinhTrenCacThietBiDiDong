<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'My TLU')</title>
    
    {{-- LỖI 1: Bỏ thẻ <link> cũ, chỉ dùng @vite --}}
    @vite(['resources/css/app.css', 'resources/js/app.js']) 
    {{-- <link rel="stylesheet" href="{{ asset('css/style.css') }}"> <-- Dòng này đã được xử lý bởi @vite --}}
    
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

            {{-- 1. QUẢN LÝ LỚP VÀ MÔN HỌC (ĐÃ GỌT: Bỏ QL nhận diện) --}}
            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-layer-group"></i>
                    <span>Quản lý lớp và môn học</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="{{ route('lecturer.subjects') }}">Quản lý môn học</a></li>
                    <li><a href="{{ route('lecturer.classes') }}">Quản lý lớp</a></li>
                </ul>
            </li>

            {{-- 2. QUẢN LÝ SINH VIÊN (Thêm QL nhận diện vào đây) --}}
            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-users"></i>
                    <span>Quản lý sinh viên</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="{{ route('lecturer.students') }}">Quản lý sinh viên</a></li>
                    <li><a href="#">Quản lý nhận diện khuôn mặt</a></li> {{-- Đã di chuyển --}}
                </ul>
            </li>

            {{-- 3. QUẢN LÝ BUỔI HỌC, QR VÀ ĐIỂM DANH (Gom 3 mục lại) --}}
            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Quản lý buổi học, QR & ĐD</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="#">Quản lý buổi học</a></li>
                    <li><a href="#">Tạo mã QR</a></li>
                    <li><a href="#">Quản lý điểm danh</a></li>
                </ul>
            </li>
            
            {{-- XÓA CÁC MỤC ĐƠN BỊ GOM NHÓM:
            <li class="nav-item"><a href="#"><i class="fa-solid fa-qrcode"></i><span>Tạo mã QR</span></a></li>
            <li class="nav-item"><a href="#"><i class="fa-solid fa-clipboard-user"></i><span>Quản lý điểm danh</span></a></li>
            --}}

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
    // Logic Javascript để mở/đóng submenu
    document.querySelectorAll('.has-submenu > a').forEach(menu => {
        menu.addEventListener('click', function(e) {
            e.preventDefault();
            let parent = this.parentElement;
            parent.classList.toggle('open');
        });
    });
</script>
@stack('modals')
</body>
</html>