{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

@section('title', 'Trang chủ giảng viên')

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

        {{-- LỚP HỌC HÔM NAY --}}
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
                                    $status = $session['attendanceStatus'] ?? 'pending';
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
                <a href="{{ route('lecturer.sessions') }}" class="btn btn-primary">Đi tới quản lý buổi học</a>
            </div>
        </div>

        {{-- LỚP HỌC ĐANG GIẢNG DẠY --}}
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
                <a href="{{ route('lecturer.classes') }}" class="btn btn-primary">Đi tới Quản lý lớp</a>
            </div>
        </div>

        {{-- THAO TÁC NHANH --}}
        <div class="dashboard-sidebar">
            <div class="card">
                <div class="card-header">
                    <h3>Thao tác nhanh</h3>
                </div>
                <div class="card-body">
                    <div class="quick-actions">
                        <a href="{{ route('lecturer.qrcode') }}" class="action-card">
                            <i class="fa-solid fa-qrcode"></i>
                            <span>Tạo mã QR</span>
                        </a>
                        <a href="{{ route('lecturer.students') }}" class="action-card">
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

        {{-- ĐIỂM DANH GẦN ĐÂY --}}
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