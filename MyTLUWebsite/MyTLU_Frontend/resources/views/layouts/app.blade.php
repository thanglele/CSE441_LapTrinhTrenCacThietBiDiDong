<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>@yield('title', 'My TLU')</title>
    
    @vite(['resources/css/app.css', 'resources/js/app.js'])
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body>
<div class="app-container">

    {{-- SIDEBAR: THANH MENU BÊN TRÁI --}}
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

            {{-- 1. QUẢN LÝ LỚP VÀ MÔN HỌC --}}
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

            {{-- 2. QUẢN LÝ SINH VIÊN & NHẬN DIỆN --}}
            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-users"></i>
                    <span>Quản lý sinh viên</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="{{ route('lecturer.students') }}">Quản lý sinh viên</a></li>
                    <li><a href="#">Quản lý nhận diện khuôn mặt</a></li> 
                </ul>
            </li>

            {{-- 3. QUẢN LÝ BUỔI HỌC, QR VÀ ĐIỂM DANH --}}
            <li class="nav-item has-submenu">
                <a href="#">
                    <i class="fa-solid fa-calendar-days"></i>
                    <span>Quản lý buổi học, QR & ĐD</span>
                    <i class="fa-solid fa-chevron-down submenu-arrow"></i>
                </a>
                <ul class="submenu">
                    <li><a href="{{ route('lecturer.sessions') }}">Quản lý buổi học</a></li>
                    <li><a href="{{ route('lecturer.qrcode') }}">Tạo mã QR</a></li>
                    {{-- [sessionId => 1] là giá trị giả để route hoạt động --}}
                    <li><a href="{{ route('lecturer.attendance.details', ['sessionId' => 1]) }}">Quản lý điểm danh</a></li>
                </ul>
            </li>

        </ul>

        {{-- KHU VỰC THÔNG TIN NGƯỜI DÙNG --}}
        <div class="sidebar-user">
            <i class="fa-solid fa-circle-user user-avatar"></i>
            <div class="user-info">
                <span>{{ $fullName }}</span>
                <a href="{{ route('logout') }}">Đăng xuất</a>
            </div>
        </div>
    </nav>

    {{-- KHUNG NỘI DUNG CHÍNH --}}
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

@stack('modals')
</body>
</html>