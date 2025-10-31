<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController; // Import Controller
use Illuminate\Support\Facades\Session; // Import Session

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
*/

// 1. CHUYỂN HƯỚNG TRANG GỐC
// Khi người dùng truy cập / (trang chủ), chuyển hướng đến /login
Route::get('/', function () {
    return redirect()->route('login');
});

// 2. NHÓM ROUTE CHO XÁC THỰC
// GET /login: Hiển thị form
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');

// POST /login: Xử lý khi người dùng nhấn nút "Đăng nhập"
Route::post('/login', [AuthController::class, 'handleLogin'])->name('login.submit');

// GET /logout: Xử lý đăng xuất
Route::get('/logout', [AuthController::class, 'logout'])->name('logout');


// 3. ROUTE ĐƯỢC BẢO VỆ (TRANG SAU KHI ĐĂNG NHẬP)
// 'auth.custom' là middleware chúng ta tạo ra
Route::get('/dashboard', function () {

    // Kiểm tra xem session 'user_profile' có tồn tại không
    if (!Session::has('user_profile')) {
        // Nếu không có (lỗi gì đó), bắt đăng xuất
        return redirect()->route('logout');
    }

    // Lấy thông tin từ session
    $profile = Session::get('user_profile');
    $role = Session::get('user_role');

    // === DÒNG ĐÃ SỬA ===
    // Thay thế '$profile['fullName'] ?? 'Người dùng'' bằng cú pháp 'isset()'
    $fullName = isset($profile['fullName']) ? $profile['fullName'] : 'Người dùng'; // Lấy tên chung

    // Xây dựng chuỗi chào mừng
    $welcomeMessage = "<h2>Chào mừng, $fullName!</h2>";
    $welcomeMessage .= "<p>Vai trò của bạn: <strong>$role</strong></p>";

    // Hiển thị chi tiết profile (để debug)
    $welcomeMessage .= "<h3>Thông tin Profile (từ API /auth/me):</h3>";
    $welcomeMessage .= "<pre>" . json_encode($profile, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE) . "</pre>";

    $welcomeMessage .= '<br><a href="' . route('logout') . '">Đăng xuất</a>';

    return $welcomeMessage;

})->middleware('auth.custom')->name('dashboard');

Route::get('/dashboard', [DashboardController::class, 'index'])
    ->middleware('auth.custom') // Bảo vệ route, yêu cầu đăng nhập
    ->name('dashboard');