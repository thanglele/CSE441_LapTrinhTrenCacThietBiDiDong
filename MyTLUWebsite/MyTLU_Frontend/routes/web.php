<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;
// use App\Http\Controllers\SessionController; // KHÔNG CẦN THIẾT KHI CHƯA TẠO

Route::get('/', function () {
    return redirect()->route('login');
});

// =========================================================================
// 1. AUTHENTICATION ROUTES (ĐĂNG NHẬP/ĐĂNG XUẤT/KHÔI PHỤC)
// =========================================================================

Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'handleLogin'])->name('login.submit');

Route::get('/logout', [AuthController::class, 'logout'])->name('logout');

Route::get('/dashboard', [DashboardController::class, 'index'])
    ->middleware('auth.session')
    ->name('dashboard');

// KHÔI PHỤC MẬT KHẨU
Route::get('/forgot-password', [AuthController::class, 'showForgotPasswordForm'])->name('password.request');
Route::post('/forgot-password', [AuthController::class, 'handleForgotPassword'])->name('password.request.submit');

Route::get('/verify-otp', [AuthController::class, 'showVerifyOtpForm'])->name('password.verify');
Route::post('/verify-otp', [AuthController::class, 'handleVerifyOtp'])->name('password.verify.submit');

Route::get('/reset-password', [AuthController::class, 'showResetPasswordForm'])->name('password.reset');
Route::post('/reset-password', [AuthController::class, 'handleResetPassword'])->name('password.reset.submit');


// =========================================================================
// 2. LECTURER MANAGEMENT ROUTES (GIẢNG VIÊN)
// =========================================================================

// Quản lý Môn học
Route::get('/quan-ly-mon-hoc', function () {
    return view('lecturer.Class_and_subject_management.subject-management');
})->name('lecturer.subjects');

// Quản lý Lớp học (Danh sách)
Route::get('/quan-ly-lop', function () {
    return view('lecturer.Class_and_subject_management.class-management'); 
})->name('lecturer.classes');

// Quản lý Lớp học (Thêm mới Form)
Route::get('/quan-ly-lop/tao-moi', function () {
    return view('lecturer.Class_and_subject_management.class-create-form');
})->name('lecturer.classes.create');

// Quản lý Sinh viên
Route::get('/quan-ly-sinh-vien', function () {
    return view('lecturer.Student_management.student-management');
})->name('lecturer.students');


// Quản lý Buổi học (Danh sách)
Route::get('/quan-ly-buoi-hoc', function () {
    return view('lecturer.Lesson_management.session-management');
})->name('lecturer.sessions');

// Tạo Mã QR
Route::get('/tao-ma-qr', function () {
    return view('lecturer.Lesson_management.qr-generator-page');
})->name('lecturer.qrcode');

// Quản lý Điểm danh (Chi tiết buổi học)
Route::get('/bao-cao-diem-danh/{sessionId}', function ($sessionId) {
    return view('lecturer.Lesson_management.attendance-detail-page');
})->name('lecturer.attendance.details');

// Quản lý Nhận diện Khuôn mặt (Review List)
// Route::get('/quan-ly-nhan-dien-khuon-mat', function () {
//     return view('lecturer.face-approval-management'); 
// })->name('lecturer.face.approval');

// Quản lý Nhận diện Khuôn mặt (Review List)
use App\Http\Controllers\FaceController;
Route::get('/quan-ly-nhan-dien-khuon-mat', [FaceController::class, 'index']) // <--- Dùng Controller
    ->name('lecturer.face.approval');