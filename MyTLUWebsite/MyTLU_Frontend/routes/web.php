<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Session;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DashboardController;

Route::get('/', function () {
    return redirect()->route('login');
});

// ==== LOGIN ====
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'handleLogin'])->name('login.submit');

// ==== LOGOUT ====
Route::get('/logout', [AuthController::class, 'logout'])->name('logout');

// ==== DASHBOARD (YÊU CẦU ĐĂNG NHẬP) ====
Route::get('/dashboard', [DashboardController::class, 'index'])
    ->middleware('auth.session') // middleware tùy chỉnh dùng session, không phải 'auth'
    ->name('dashboard');
/*
|--------------------------------------------------------------------------
| CÁC ROUTE QUÊN MẬT KHẨU
|--------------------------------------------------------------------------
*/

// --- BƯỚC 1: YÊU CẦU OTP ---
Route::get('/forgot-password', [AuthController::class, 'showForgotPasswordForm'])
    ->name('password.request');
Route::post('/forgot-password', [AuthController::class, 'handleForgotPassword'])
    ->name('password.request.submit');

// --- BƯỚC 2: XÁC THỰC OTP (MỚI) ---
Route::get('/verify-otp', [AuthController::class, 'showVerifyOtpForm'])
    ->name('password.verify');
Route::post('/verify-otp', [AuthController::class, 'handleVerifyOtp'])
    ->name('password.verify.submit');

// --- BƯỚC 3: ĐẶT LẠI MẬT KHẨU MỚI ---
Route::get('/reset-password', [AuthController::class, 'showResetPasswordForm'])
    ->name('password.reset');
Route::post('/reset-password', [AuthController::class, 'handleResetPassword'])
    ->name('password.reset.submit');

Route::get('/quan-ly-mon-hoc', function () {
    return view('lecturer.subject-management'); 
})->name('lecturer.subjects');

Route::get('/quan-ly-lop', function () {
    return view('lecturer.class-management'); 
})->name('lecturer.classes');

Route::get('/quan-ly-lop/tao-moi', function () {
    return view('lecturer.class-create-form'); 
})->name('lecturer.classes.create');

Route::get('/quan-ly-sinh-vien', function () {
    return view('lecturer.student-management');
})->name('lecturer.students');

Route::get('/quan-ly-buoi-hoc', function () {
    return view('lecturer.session-management');
})->name('lecturer.sessions');

Route::get('/tao-ma-qr', function () {
    return view('lecturer.qr-generator-page');
})->name('lecturer.qrcode');