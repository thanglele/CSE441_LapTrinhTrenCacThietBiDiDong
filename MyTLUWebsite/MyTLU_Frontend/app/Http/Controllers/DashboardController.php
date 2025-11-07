<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Session;

class DashboardController extends Controller
{
    /**
     * Hiển thị trang dashboard của giảng viên.
     */
    public function index(Request $request)
    {
        // 1. Lấy thông tin cần thiết từ Session
        $apiUrl = env('NET_API_URL');
        $token = $request->session()->get('auth_token');
        $userProfile = $request->session()->get('user_profile', []);

        // 2. GỌI API TỔNG HỢP (GET /api/v1/lecturer/dashboard)
        try {
            $response = Http::withToken($token)
                ->get($apiUrl . '/lecturer/dashboard');

            if ($response->successful()) {
                // Lấy toàn bộ DTO từ API
                $dashboardData = $response->json();
            } else {
                // Nếu gọi API lỗi, gán dữ liệu rỗng
                $dashboardData = $this->getEmptyDashboardData();
                // (Bạn có thể thêm thông báo lỗi ở đây)
                // session()->flash('error', 'Không thể tải dữ liệu dashboard.');
            }
        } catch (\Exception $e) {
            // Lỗi kết nối, gán dữ liệu rỗng
            $dashboardData = $this->getEmptyDashboardData();
            // session()->flash('error', 'Lỗi kết nối máy chủ API.');
        }

        // 3. Trả về view và truyền dữ liệu
        // (Tách các thành phần từ DTO chính)
        return view('lecturer.dashboard', [
            'userProfile' => $userProfile,
            'stats' => $dashboardData['stats'],
            'todaySessions' => $dashboardData['todaySessions'],
            'teachingClasses' => $dashboardData['teachingClasses'],
            'recentAttendance' => $dashboardData['recentAttendance']
        ]);
    }

    /**
     * Hàm helper để tạo cấu trúc dữ liệu rỗng khi API lỗi,
     * tránh làm vỡ giao diện Blade.
     */
    private function getEmptyDashboardData()
    {
        return [
            'stats' => [
                'totalClasses' => 0,
                'totalStudents' => 0,
                'todaySessionsCount' => 0
            ],
            'todaySessions' => [],
            'teachingClasses' => [],
            'recentAttendance' => []
        ];
    }
}