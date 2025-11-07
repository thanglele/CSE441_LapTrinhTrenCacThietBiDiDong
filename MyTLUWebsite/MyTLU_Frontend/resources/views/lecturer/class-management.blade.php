{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

{{-- Đặt tiêu đề cho trang này --}}
@section('title', 'Quản lý lớp học')

{{-- Phần nội dung chính của trang --}}
@section('content')

    <h1 class="content-title">Quản lý lớp</h1>

    {{-- 1. KHUNG LỌC (4 CỘT) --}}
    <div class="card card-filter">
        <div class="card-body">
            {{-- Lưới lọc này có 4 cột --}}
            <div class="filter-grid filter-grid-4-cols">
                
                {{-- Ô tìm kiếm --}}
                <div class="filter-item">
                    <label for="search_class">Tìm kiếm</label>
                    <div class="input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="search_class" class="form-control" placeholder="Tìm kiếm theo mã, tên lớp...">
                    </div>
                </div>

                {{-- Ô lọc Môn học --}}
                <div class="filter-item">
                    <label for="filter_subject">Lọc</label>
                    <div class="input-group">
                        <i class="fa-solid fa-filter"></i>
                        <select id="filter_subject" class="form-control">
                            <option value="all">Tất cả các lớp học</option>
                            {{-- TODO: Lấy danh sách môn học từ Controller --}}
                            <option value="cse441">Lập trình Mobile</option>
                            <option value="cse123">Cấu trúc dữ liệu</option>
                        </select>
                    </div>
                </div>

                {{-- Ô lọc Học kỳ --}}
                <div class="filter-item">
                    <label for="filter_semester" style="visibility: hidden;">Học kỳ</label> {{-- Ẩn label để căn hàng --}}
                    <div class="input-group">
                        <i class="fa-solid fa-calendar-week"></i>
                        <select id="filter_semester" class="form-control">
                            <option value="all">Tất cả các học kỳ</option>
                            <option value="hk1_2025">2025 - Học kỳ 1</option>
                            <option value="hk2_2024">2024 - Học kỳ 2</option>
                        </select>
                    </div>
                </div>

                {{-- Ô lọc Trạng thái --}}
                <div class="filter-item">
                    <label for="filter_status" style="visibility: hidden;">Trạng thái</label> {{-- Ẩn label để căn hàng --}}
                    <div class="input-group">
                        <i class="fa-solid fa-check-circle"></i>
                        <select id="filter_status" class="form-control">
                            <option value="all">Tất cả các trạng thái</option>
                            <option value="active">Đang hoạt động</option>
                            <option value="finished">Đã kết thúc</option>
                        </select>
                    </div>
                </div>

                {{-- Thêm 2 ô lọc ở hàng 2 --}}
                <div class="filter-item">
                    <label for="filter_room">Tất cả các phòng học</label>
                    <div class="input-group">
                        <i class="fa-solid fa-location-dot"></i>
                        <select id="filter_room" class="form-control">
                            <option value="all">Tất cả các phòng học</option>
                            {{-- TODO: Lấy danh sách phòng --}}
                        </select>
                    </div>
                </div>

                <div class="filter-item">
                    <label for="filter_type">Tất cả các trạng thái</label> {{-- Label này trong thiết kế bị sai --}}
                    <div class="input-group">
                        <i class="fa-solid fa-book"></i>
                        <select id="filter_type" class="form-control">
                            <option value="all">Tất cả các loại hình</option>
                            <option value="ly_thuyet">Lý thuyết</option>
                            <option value="thuc_hanh">Thực hành</option>
                        </select>
                    </div>
                </div>

            </div>
        </div>
    </div>

    {{-- 2. BẢNG DANH SÁCH LỚP HỌC --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Danh sách lớp học</h3>
            <a href="{{ route('lecturer.classes.create') }}" class="btn btn-primary">Thêm lớp học</a>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Mã lớp học</th>
                            <th>Tên lớp học</th>
                            <th>Niên khóa</th>
                            <th>Học kỳ</th>
                            <th>Sĩ số lớp</th>
                            <th>Phòng học</th>
                            <th>Loại hình lớp học</th>
                            <th>Trạng thái</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{-- Dữ liệu giả lập --}}
                        <tr>
                            <td>64KTPM3</td>
                            <td>Lập trình Mobile (Lớp 3)</td>
                            <td>2024-2025</td>
                            <td>1</td>
                            <td>60</td>
                            <td>305-B5</td>
                            <td>Lý thuyết</td>
                            <td><span class="status-tag live">Đang diễn ra</span></td>
                            <td>
                                <a href="#" class="table-action-link">Chi tiết »</a>
                            </td>
                        </tr>
                        <tr>
                            <td>64KTPM1</td>
                            <td>Lập trình Mobile (Lớp 1)</td>
                            <td>2024-2025</td>
                            <td>1</td>
                            <td>60</td>
                            <td>305-B5</td>
                            <td>Lý thuyết</td>
                            <td><span class="status-tag finished">Đã kết thúc</span></td>
                            <td>
                                <a href="#" class="table-action-link">Chi tiết »</a>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            {{-- 3. PHẦN PHÂN TRANG (PAGINATION) --}}
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