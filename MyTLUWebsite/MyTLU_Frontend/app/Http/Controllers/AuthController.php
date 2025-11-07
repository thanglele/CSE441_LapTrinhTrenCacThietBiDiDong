<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;    // Dùng để gọi API
use Illuminate\Support\Facades\Session; // Dùng để quản lý Session
use Illuminate\Http\Client\ConnectionException; // Bắt lỗi kết nối

class AuthController extends Controller
{
    /**
     * Hiển thị form đăng nhập.
     * Tương ứng với: GET /login
     */
    public function showLoginForm()
    {
        // Nếu đã đăng nhập (có token), chuyển thẳng vào dashboard
        if (Session::has('auth_token')) {
            return redirect()->route('dashboard');
        }

        // Trả về view: resources/views/auth/login.blade.php
        return view('auth.login');
    }

    /**
     * Xử lý thông tin đăng nhập từ form.
     * Tương ứng với: POST /login
     */
    public function handleLogin(Request $request)
    {
        // 1. Validate dữ liệu đầu vào
        $credentials = $request->validate([
            'username' => 'required|string',
            'password' => 'required|string',
            // API v3.0 yêu cầu loginPosition (Source 58)
            // Tạm thời hardcode, sau này bạn có thể lấy bằng JS
            'loginPosition' => 'string|nullable',
        ]);

        // 2. Lấy API Base URL từ file .env
        $apiUrl = env('NET_API_URL');

        if (!$apiUrl) {
            return back()->withError('Lỗi: Chưa cấu hình NET_API_URL trong file .env');
        }

        try {
            // 3. GỌI API /auth/login CỦA .NET (API v3.0)
            $response = Http::post($apiUrl . '/auth/login', [
                'username' => $credentials['username'],
                'password' => $credentials['password'],
                // Gửi kèm loginPosition (Source 58)
                'loginPosition' => $request->input('loginPosition', '21.0064,105.8248') // Tọa độ TLU (Tạm thời)
            ]);

            // 4. Xử lý kết quả trả về
            if ($response->successful()) {
                // --- ĐĂNG NHẬP THÀNH CÔNG (200 OK) ---
                $data = $response->json();
                $token = $data['token']; // (Source 62)
                $role = $data['userRole']; // (Source 63)

                // Lưu token và role vào Session
                Session::put('auth_token', $token);
                Session::put('user_role', $role);

                // 4.1. Gọi ngay API GET /auth/me để lấy thông tin profile
                $profileResponse = Http::withToken($token)->get($apiUrl . '/auth/me'); // (Source 78)

                if ($profileResponse->successful()) {
                    // Lưu toàn bộ thông tin người dùng vào Session
                    Session::put('user_profile', $profileResponse->json());
                } else {
                    // Nếu gọi /auth/me thất bại, hủy session và báo lỗi
                    Session::flush();
                    return back()->withError('Đăng nhập thành công nhưng không thể lấy thông tin người dùng.');
                }

                // Chuyển hướng đến trang dashboard
                return redirect()->route('dashboard');

            } else {
                // --- ĐĂNG NHẬP THẤT BẠI (4xx) ---

                if ($response->status() == 401) { // (Source 71)
                    // Sai username/password
                    return back()->withError('Sai tài khoản hoặc mật khẩu, hoặc tài khoản đã bị khóa.')
                        ->withInput($request->only('username'));
                }

                if ($response->status() == 428) { // (Source 73)
                    // Lỗi 428: PASSWORD_NOT_SET
                    $errorData = $response->json();
                    $message = isset($errorData['message']) ? $errorData['message'] : 'Tài khoản chưa khởi tạo mật khẩu.';
                    return back()->withError($message)
                        ->withInput($request->only('username'));
                }

                // Các lỗi 4xx, 5xx khác
                return back()->withError('Đã xảy ra lỗi từ máy chủ xác thực.')
                    ->withInput($request->only('username'));
            }

        } catch (ConnectionException $e) {
            // Lỗi không thể kết nối đến API
            return back()->withError('Không thể kết nối đến máy chủ. Vui lòng thử lại sau.')
                ->withInput($request->only('username'));
        }
    }

    /**
     * Xử lý đăng xuất.
     * Tương ứng với: GET /logout
     */
    public function logout(Request $request)
    {
        $request->session()->flush();
        return redirect()->route('login');
    }


    /*
    |--------------------------------------------------------------------------
    | CÁC HÀM XỬ LÝ QUÊN MẬT KHẨU (CHUẨN API v3.0 - ĐÃ SỬA)
    |--------------------------------------------------------------------------
    */

    // === BƯỚC 1: YÊU CẦU OTP ===

    /**
     * Hiển thị trang yêu cầu reset mật khẩu
     * (GET /forgot-password)
     */
    public function showForgotPasswordForm()
    {
        return view('auth.forgot-password');
    }

    /**
     * Xử lý yêu cầu reset (gọi API /request-reset)
     * (POST /forgot-password)
     */
    public function handleForgotPassword(Request $request)
    {
        $request->validate(['username' => 'required|string']);
        $apiUrl = env('NET_API_URL');

        try {
            // Gọi API /request-reset (Source 118)
            $response = Http::post($apiUrl . '/auth/request-reset', [
                'username' => $request->username,
            ]);

            // Chuyển hướng đến trang nhập OTP (Bước 2)
            return redirect()->route('password.verify', ['username' => $request->username])
                ->with('success', 'Mã OTP đã được gửi đến email của bạn. Vui lòng kiểm tra (cả thư rác).');

        } catch (ConnectionException $e) {
            return back()->withError('Không thể kết nối đến máy chủ xác thực.');
        }
    }

    // === BƯỚC 2: XÁC THỰC OTP (MỚI) ===

    /**
     * Hiển thị trang nhập OTP
     * (GET /verify-otp)
     */
    public function showVerifyOtpForm(Request $request)
    {
        // Lấy username từ URL (do hàm trên chuyển hướng sang)
        $username = $request->query('username', old('username', ''));
        return view('auth.verify-otp', ['username' => $username]);
    }

    /**
     * Xử lý xác thực OTP (gọi API /verify-otp)
     * (POST /verify-otp)
     */
    public function handleVerifyOtp(Request $request)
    {
        $data = $request->validate([
            'username' => 'required|string',
            'otp' => 'required|string',
        ]);

        $apiUrl = env('NET_API_URL');

        try {
            // Gọi API /verify-otp (Source 128)
            $response = Http::post($apiUrl . '/auth/verify-otp', [
                'username' => $data['username'],
                'otp' => $data['otp'],
            ]);

            if ($response->successful()) {
                // Lấy resetToken từ API (Source 135)
                $resetToken = $response->json('resetToken');

                // Chuyển hướng đến trang đặt mật khẩu mới (Bước 3)
                // Gửi kèm username và resetToken
                return redirect()->route('password.reset', [
                    'username' => $data['username'],
                    'token' => $resetToken
                ]);

            } else {
                // Thất bại (sai OTP) (Source 136)
                $error = $response->json('message', 'Mã OTP không hợp lệ hoặc đã hết hạn.');
                return back()->withError($error)->withInput();
            }

        } catch (ConnectionException $e) {
            return back()->withError('Không thể kết nối đến máy chủ xác thực.');
        }
    }

    // === BƯỚC 3: ĐẶT LẠI MẬT KHẨU MỚI ===

    /**
     * Hiển thị trang đặt lại mật khẩu mới
     * (GET /reset-password)
     */
    public function showResetPasswordForm(Request $request)
    {
        // Lấy username và token từ URL (do hàm trên chuyển hướng sang)
        $username = $request->query('username', '');
        $resetToken = $request->query('token', '');

        if (empty($resetToken)) {
            // Nếu không có token, không cho vào, đá về trang yêu cầu
            return redirect()->route('password.request')
                ->withError('Phiên làm việc đã hết hạn. Vui lòng yêu cầu OTP lại.');
        }

        return view('auth.reset-password', [
            'username' => $username,
            'resetToken' => $resetToken
        ]);
    }

    /**
     * Xử lý đặt lại mật khẩu mới (gọi API /reset-password)
     * (POST /reset-password)
     */
    public function handleResetPassword(Request $request)
    {
        // Validate dữ liệu
        $data = $request->validate([
            'username' => 'required|string',
            'resetToken' => 'required|string', // Lấy từ input hidden (Source 146)
            'newPassword' => 'required|string|min:6|confirmed',
        ]);

        $apiUrl = env('NET_API_URL');

        try {
            // Gọi API /reset-password (Source 138)
            $response = Http::post($apiUrl . '/auth/reset-password', [
                'username' => $data['username'],
                'resetToken' => $data['resetToken'],
                'newPassword' => $data['newPassword'],
            ]);

            if ($response->successful()) {
                // Thành công (Source 149)
                return redirect()->route('login')
                    ->with('success', 'Đổi mật khẩu thành công! Bạn có thể đăng nhập ngay bây giờ.');
            } else {
                // Thất bại (sai Token) (Source 150)
                $error = $response->json('message', 'Mã reset không hợp lệ hoặc đã hết hạn.');
                return back()->withError($error)->withInput();
            }

        } catch (ConnectionException $e) {
            return back()->withError('Không thể kết nối đến máy chủ xác thực.');
        }
    }

}