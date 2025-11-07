{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

{{-- Đặt tiêu đề cho trang này --}}
@section('title', 'Quản lý điểm danh')

{{-- Phần nội dung chính của trang --}}
@section('content')

    <h1 class="content-title">Quản lý điểm danh</h1>

    {{-- 1. HEADER THÔNG TIN BUỔI HỌC --}}
    <div class="card card-session-header">
        <div class="card-body">
            <div class="session-info-grid">
                {{-- Giả định dữ liệu được Controller truyền vào --}}
                <div class="session-info-item">
                    <span>Tên môn học:</span>
                    <strong>CSE441.Mobile Dev</strong>
                </div>
                <div class="session-info-item">
                    <span>Phòng học:</span>
                    <strong>305 - B5</strong>
                </div>
                <div class="session-info-item">
                    <span>Lớp:</span>
                    <strong>64KTPM3</strong>
                </div>
                <div class="session-info-item">
                    <span>Thời gian học:</span>
                    <strong>8:00 - 9:30</strong>
                </div>
                <div class="session-info-item">
                    <span>Ngày:</span>
                    <strong>20/09/2025</strong>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. KHUNG LỌC & TÌM KIẾM --}}
    <div class="card card-filter">
        <div class="card-body filter-body-full">
            <div class="filter-grid filter-grid-2-cols">
                {{-- Ô tìm kiếm --}}
                <div class="filter-item">
                    <label for="search_student">Tìm kiếm</label>
                    <div class="input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="search_student" class="form-control" placeholder="Tìm kiếm tên sinh viên...">
                    </div>
                </div>

                {{-- Ô lọc (theo Trạng thái) --}}
                <div class="filter-item">
                    <label for="filter_status">Lọc</label>
                    <div class="input-group">
                        <i class="fa-solid fa-filter"></i>
                        <select id="filter_status" class="form-control">
                            <option value="all">Tất cả trạng thái</option>
                            <option value="present">Đúng giờ</option>
                            <option value="late">Đi muộn</option>
                            <option value="absent">Chưa điểm danh</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 3. BẢNG DANH SÁCH ĐIỂM DANH --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Danh sách sinh viên</h3>
            <div class="action-buttons-group">
                <button type="button" class="btn btn-primary">
                    <i class="fa-solid fa-plus"></i>
                </button>
                <button type="button" class="btn btn-primary">
                    <i class="fa-solid fa-minus"></i>
                </button>
            </div>
        </div>
        
        <div class="card-body">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Mã sinh viên</th>
                            <th>Họ và tên</th>
                            <th>Email</th>
                            <th>Lớp sinh hoạt</th>
                            <th>Trạng thái</th>
                            <th>Thời gian điểm danh</th>
                            <th>Phương thức</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{-- Dữ liệu giả lập --}}
                        @php
                            $students = [
                                ['id' => '2251177226', 'name' => 'Nguyễn Văn A', 'status' => 'Đúng giờ', 'status_class' => 'present', 'time' => '07:58', 'method' => 'Face ID'],
                                ['id' => '2251177227', 'name' => 'Nguyễn Thị B', 'status' => 'Đi muộn', 'status_class' => 'late', 'time' => '08:15', 'method' => 'Face ID'],
                                ['id' => '2251177228', 'name' => 'Trần Văn C', 'status' => 'Chưa ĐD', 'status_class' => 'absent', 'time' => 'N/A', 'method' => 'N/A'],
                                ['id' => '2251177229', 'name' => 'Lê Thị D', 'status' => 'Đúng giờ', 'status_class' => 'present', 'time' => '07:59', 'method' => 'Manual'],
                            ];
                        @endphp

                        @foreach ($students as $student)
                        <tr>
                            <td>{{ $student['id'] }}</td>
                            <td>{{ $student['name'] }}</td>
                            <td>{{ $student['id'] }}@tlu.edu.vn</td>
                            <td>64KTPM3</td>
                            <td><span class="status-tag {{ $student['status_class'] }}">{{ $student['status'] }}</span></td>
                            <td>{{ $student['time'] }}</td>
                            <td>{{ $student['method'] }}</td>
                            <td class="action-cell">
                                <a href="#" class="btn btn-icon btn-sm" title="Sửa điểm danh">
                                    <i class="fa-solid fa-clock"></i>
                                </a>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            
            {{-- PHẦN PHÂN TRANG (PAGINATION) --}}
            <div class="pagination-container">
                <span class="pagination-info">Hiển thị 1 – 10 / 5 kết quả</span>
                <div class="pagination-links">
                    <a href="#" class="page-link disabled">« Trang trước</a>
                    <a href="#" class="page-link active">1</a>
                    <a href="#" class="page-link">2</a>
                    <a href="#" class="page-link">3</a>
                    <a href="#" class="page-link">Trang sau »</a>
                </div>
            </div>

        </div>
    </div>

@endsection