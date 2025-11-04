{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

{{-- Đặt tiêu đề cho trang này --}}
@section('title', 'Dashboard Giảng viên')

{{-- Phần nội dung chính của trang --}}
@section('content')

    <h1 class="content-title">Trang chủ giảng viên</h1>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-info">
                <span class="stat-label">Tổng số lớp</span>
                <span class="stat-value">{{ $stats['totalClasses'] ?? 0 }}</span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <span class="stat-label">Tổng sinh viên</span>
                <span class="stat-value">{{ $stats['totalStudents'] ?? 0 }}</span>
            </div>
        </div>

        <div class="stat-card">
            <div class="stat-info">
                <span class="stat-label">Buổi học hôm nay</span>
                <span class="stat-value">{{ $stats['todaySessionsCount'] ?? 0 }}</span>
            </div>
        </div>
    </div>

    <div class="dashboard-grid">

        <div class="card">
            <div class="card-header">
                <h3>Lớp học hôm nay</h3>
                <span>{{ date('l, d/m/Y') }}</span>
            </div>
            <div class="card-body">
                <ul class="session-list">
                    @forelse($todaySessions as $session)
                        <li class="session-item">
                            <div class="session-info">
                                <span class="session-name">{{ $session['className'] ?? 'N/A' }}</span>
                                <small class="session-room">{{ $session['location'] ?? 'N/A' }}</small>
                                <small class="session-time">
                                    {{ \Carbon\Carbon::parse($session['startTime'])->format('H:i') }} -
                                    {{ \Carbon\Carbon::parse($session['endTime'])->format('H:i') }}
                                </small>
                            </div>
                            <div class="session-status">
                                @php
                                    // (Xử lý logic trạng thái dựa trên dữ liệu API)
                                    $status = $session['attendanceStatus'] ?? 'pending'; // (pending, in_progress, completed)
                                    if ($status == 'pending' && \Carbon\Carbon::parse($session['startTime'])->isPast() && \Carbon\Carbon::parse($session['endTime'])->isFuture()) {
                                        $status = 'live';
                                    } elseif ($status == 'pending' && \Carbon\Carbon::parse($session['endTime'])->isPast()) {
                                        $status = 'finished';
                                    }
                                @endphp

                                @if($status == 'live')
                                    <span class="status-tag live">Đang diễn ra</span>
                                @elseif($status == 'pending')
                                    <span class="status-tag upcoming">Sắp diễn ra</span>
                                @else
                                    <span class="status-tag finished">Đã kết thúc</span>
                                @endif
                            </div>
                        </li>
                    @empty
                        <p>Không có lớp học nào hôm nay.</p>
                    @endforelse
                </ul>
            </div>
            <div class="card-footer">
                <a href="#" class="btn btn-primary">Đi tới quản lý buổi học</a>
            </div>
        </div>

        <div class="card">
            <div class="card-header">
                <h3>Lớp học đang giảng dạy</h3>
            </div>
            <div class="card-body">
                <ul class="class-list">
                    @forelse($teachingClasses as $class)
                        <li class="class-item">
                            <div class="class-info">
                                <span class="class-name">{{ $class['className'] }}</span>
                                <small class="class-code">{{ $class['classCode'] }}</small>
                            </div>
                            <span class="class-tag">{{ $class['tag'] }}</span>
                        </li>
                    @empty
                        <p>Không có lớp nào đang giảng dạy.</p>
                    @endforelse
                </ul>
            </div>
            <div class="card-footer">
                <a href="#" class="btn btn-primary">Đi tới Quản lý lớp</a>
            </div>
        </div>

        <div class="dashboard-sidebar">
            <div class="card">
                <div class="card-header">
                    <h3>Thao tác nhanh</h3>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="#" class="action-card">
                            <i class="fa-solid fa-qrcode"></i>
                            <span>Tạo mã QR</span>
                        </a>
                        <a href="#" class="action-card">
                            <i class="fa-solid fa-users"></i>
                            <span>Quản lý sinh viên</span>
                        </a>
                        <a href="#" class="action-card">
                            <i class="fa-solid fa-chart-pie"></i>
                            <span>Báo cáo phân tích</span>
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <div class="card card-full-width">
            <div class="card-header">
                <h3>Điểm danh gần đây</h3>
                <a href="#" class="view-all">Xem tất cả <i class="fa-solid fa-arrow-right"></i></a>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="data-table">
                        <thead>
                        <tr>
                            <th>Môn học</th>
                            <th>Lớp học</th>
                            <th>Buổi học</th>
                            <th>Ngày</th>
                            <th>Giờ</th>
                            <th>Điểm danh</th>
                            <th>Tỷ lệ</th>
                        </tr>
                        </thead>
                        <tbody>
                        @forelse($recentAttendance as $record)
                            <tr>
                                <td>{{ $record['subject'] }}</td>
                                <td>{{ $record['classCode'] }}</td>
                                <td>{{ $record['sessionTitle'] }}</td>
                                <td>{{ \Carbon\Carbon::parse($record['sessionDate'])->format('d/m/Y') }}</td>
                                <td>{{ $record['checkInTime'] }}</td>
                                <td>{{ $record['presentCount'] }}</td>
                                <td>{{ $record['attendanceRate'] }}</td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7">Không có dữ liệu điểm danh.</td>
                            </tr>
                        @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

@endsection