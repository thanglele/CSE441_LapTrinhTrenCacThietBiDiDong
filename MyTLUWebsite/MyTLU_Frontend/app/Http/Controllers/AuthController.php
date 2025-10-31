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
        ]);

        // 2. Lấy API Base URL từ file .env
        $apiUrl = env('NET_API_URL');

        if (!$apiUrl) {
            return back()->withError('Lỗi: Chưa cấu hình NET_API_URL trong file .env');
        }

        try {
            // 3. GỌI API /auth/login CỦA .NET
            $response = Http::post($apiUrl . '/auth/login', [
                'username' => $credentials['username'],
                'password' => $credentials['password'],
            ]);

            // 4. Xử lý kết quả trả về
            if ($response->successful()) {
                // --- ĐĂNG NHẬP THÀNH CÔNG (200 OK) ---
                $data = $response->json();
                $token = $data['token'];
                $role = $data['userRole'];

                // Lưu token và role vào Session
                Session::put('auth_token', $token);
                Session::put('user_role', $role);

                // 4.1. Gọi ngay API GET /auth/me để lấy thông tin profile
                // Dùng Http::withToken() để gửi kèm token
                $profileResponse = Http::withToken($token)->get($apiUrl . '/auth/me');

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

                if ($response->status() == 401) {
                    // Sai username/password
                    return back()->withError('Sai tài khoản hoặc mật khẩu, hoặc tài khoản đã bị khóa.')
                        ->withInput($request->only('username'));
                }

                if ($response->status() == 428) {
                    // Lỗi 428: PASSWORD_NOT_SET
                    $errorData = $response->json();

                    // === DÒNG ĐÃ SỬA ===
                    // Thay thế '$errorData['message'] ?? ...' bằng cú pháp 'isset()'
                    $message = isset($errorData['message']) ? $errorData['message'] : 'Tài khoản chưa khởi tạo mật khẩu.';

                    return back()->withError($message)
                        ->withInput($request->only('username'));
                }

                // Các lỗi 4xx, 5xx khác
                return back()->withError('Đã xảy ra lỗi từ máy chủ xác thực.')
                    ->withInput($request->only('username'));
            }

        } catch (ConnectionException $e) {
            // Lỗi không thể kết nối đến API (máy chủ .NET bị sập, sai URL...)
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
        // API không có endpoint /logout, nên ta chỉ cần xóa session phía Laravel
        $request->session()->flush();

        return redirect()->route('login');
    }
}
