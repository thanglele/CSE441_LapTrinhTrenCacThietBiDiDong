{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

@section('title', 'Quản lý môn học')

@section('content')

    <h1 class="content-title">Quản lý môn</h1>

    {{-- 1. KHUNG LỌC --}}
    <div class="card card-filter">
        <div class="card-body">
            <div class="filter-grid">
                {{-- Ô tìm kiếm --}}
                <div class="filter-item">
                    <label for="search_subject">Tìm kiếm</label>
                    <div class="input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="search_subject" class="form-control" placeholder="Tìm kiếm theo mã, tên môn học...">
                    </div>
                </div>

                {{-- Ô lọc --}}
                <div class="filter-item">
                    <label for="filter_category">Lọc</label>
                    <div class="input-group">
                        <i class="fa-solid fa-filter"></i>
                        <select id="filter_category" class="form-control">
                            <option value="all">Tất cả các môn học</option>
                            <option value="has_class">Môn học có lớp</option>
                            <option value="no_class">Môn học chưa có lớp</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. BẢNG DANH SÁCH MÔN HỌC --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Danh sách môn học</h3>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Mã môn học</th>
                            <th>Tên môn học</th>
                            <th>Số tín chỉ</th>
                            <th>Mô tả</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{-- Dữ liệu giả lập --}}
                        <tr>
                            <td>CSE441</td>
                            <td>Lập trình Mobile</td>
                            <td>3</td>
                            <td>Mô tả ngắn về môn học...</td>
                            <td>
                                <a href="#" class="table-action-link">Quản lý lớp »</a>
                            </td>
                        </tr>
                        <tr>
                            <td>CSE123</td>
                            <td>Cấu trúc dữ liệu và giải thuật</td>
                            <td>3</td>
                            <td>Mô tả ngắn về môn học...</td>
                            <td>
                                <a href="#" class="table-action-link">Quản lý lớp »</a>
                            </td>
                        </tr>
                        <tr>
                            <td>CSE321</td>
                            <td>Cơ sở dữ liệu</td>
                            <td>3</td>
                            <td>Mô tả ngắn về môn học...</td>
                            <td>
                                <a href="#" class="table-action-link">Quản lý lớp »</a>
                            </td>
                        </tr>
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