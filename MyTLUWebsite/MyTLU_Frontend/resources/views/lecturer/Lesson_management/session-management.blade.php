{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

@section('title', 'Quản lý buổi học')

@section('content')

    <h1 class="content-title">Quản lý buổi học</h1>

    {{-- 1. KHUNG LỌC --}}
    <div class="card card-filter">
        <div class="card-body">
            <div class="filter-grid filter-grid-3-cols">
                
                {{-- Ô tìm kiếm --}}
                <div class="filter-item">
                    <label for="search_session">Tìm kiếm</label>
                    <div class="input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="search_session" class="form-control" placeholder="Tìm kiếm môn buổi học...">
                    </div>
                </div>

                {{-- Ô lọc Lớp học --}}
                <div class="filter-item">
                    <label for="filter_class">Lọc</label>
                    <div class="input-group">
                        <i class="fa-solid fa-filter"></i>
                        <select id="filter_class" class="form-control">
                            <option value="all">Tất cả các lớp học</option>
                            {{-- TODO: Lấy danh sách lớp từ Controller --}}
                        </select>
                    </div>
                </div>

                {{-- Ô lọc Môn học --}}
                <div class="filter-item">
                    <label for="filter_subject" style="visibility: hidden;">Môn học</label>
                    <div class="input-group">
                        <i class="fa-solid fa-book"></i>
                        <select id="filter_subject" class="form-control">
                            <option value="all">Tất cả các môn học</option>
                            {{-- TODO: Lấy danh sách môn từ Controller --}}
                        </select>
                    </div>
                </div>

                {{-- Ô lọc Ngày --}}
                <div class="filter-item">
                    <label for="filter_date">Ngày</label>
                    <div class="input-group">
                        <i class="fa-solid fa-calendar-alt"></i>
                        <select id="filter_date" class="form-control">
                            <option value="all">Tất cả các ngày</option>
                            <option value="today">Hôm nay</option>
                            <option value="past">Đã qua</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. BẢNG DANH SÁCH BUỔI HỌC --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Danh sách buổi học</h3>
            {{-- SỬA: Nút Thêm buổi học đã được sửa thành <button> trong các bước trước --}}
            <button type="button" class="btn btn-primary" data-modal-target="#addSessionModal">
                <i class="fa-solid fa-plus"></i> Thêm buổi học
            </button>
        </div>
        
        <div class="card-body">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Id</th>
                            <th>Tên lớp học</th>
                            <th>Tên buổi</th>
                            <th>Ngày</th>
                            <th>Thời gian bắt đầu</th>
                            <th>Thời gian kết thúc</th>
                            <th>Phòng học</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        @for ($i = 1; $i <= 3; $i++)
                        <tr>
                            <td>{{ 500 + $i }}</td>
                            <td>64KTPM3 - Lập trình Mobile</td>
                            <td>Buổi #{{ $i }}</td>
                            <td>20/10/2025</td>
                            <td>08:00</td>
                            <td>09:30</td>
                            <td>305-B5</td>
                            <td><span class="status-tag live">Đang diễn ra</span></td>
                            <td class="action-cell">
                                {{-- NÚT: Quản lý điểm danh (chuyển trang) --}}
                                <a href="{{ route('lecturer.attendance.details', ['sessionId' => 500 + $i]) }}" class="btn btn-icon btn-sm" title="Quản lý điểm danh">
                                    <i class="fa-solid fa-clipboard-user"></i>
                                </a>
                                {{-- NÚT: Xóa (mở Modal) --}}
                                <button type="button" class="btn btn-icon btn-sm text-danger" data-modal-target="#deleteSessionModal" title="Xóa buổi học">
                                    <i class="fa-solid fa-trash-can"></i>
                                </button>
                            </td>
                        </tr>
                        @endfor
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
    
    {{-- MODAL --}}
    @push('modals')
        @include('lecturer.Lesson_management.Lesson_forms.session-create-modal')
        @include('lecturer.Lesson_management.Lesson_forms.session-delete-modal')
    @endpush

@endsection