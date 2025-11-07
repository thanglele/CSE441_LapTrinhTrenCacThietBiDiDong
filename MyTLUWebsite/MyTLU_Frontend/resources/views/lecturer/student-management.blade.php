{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

{{-- Đặt tiêu đề cho trang này --}}
@section('title', 'Quản lý sinh viên')

{{-- Phần nội dung chính của trang --}}
@section('content')

    <h1 class="content-title">Quản lý sinh viên</h1>

    {{-- 1. KHUNG LỌC (TÌM KIẾM VÀ DROPDOWN) --}}
    <div class="card card-filter">
        <div class="card-body">
            <div class="filter-grid filter-grid-3-cols"> {{-- Lưới 3 cột --}}
                
                {{-- Ô tìm kiếm --}}
                <div class="filter-item">
                    <label for="search_student">Tìm kiếm</label>
                    <div class="input-group">
                        <i class="fa-solid fa-magnifying-glass"></i>
                        <input type="text" id="search_student" class="form-control" placeholder="Tìm kiếm theo mã, tên sinh viên...">
                    </div>
                </div>

                {{-- Ô lọc Lớp học --}}
                <div class="filter-item">
                    <label for="filter_class">Lọc</label>
                    <div class="input-group">
                        <i class="fa-solid fa-filter"></i>
                        <select id="filter_class" class="form-control">
                            <option value="all">Tất cả các lớp học</option>
                            {{-- TODO: Lấy danh sách lớp học từ Controller --}}
                        </select>
                    </div>
                </div>

                {{-- Ô lọc Chuyên ngành --}}
                <div class="filter-item">
                    <label for="filter_major" style="visibility: hidden;">Chuyên ngành</label> {{-- Ẩn label để căn hàng --}}
                    <div class="input-group">
                        <i class="fa-solid fa-graduation-cap"></i>
                        <select id="filter_major" class="form-control">
                            <option value="all">Tất cả các chuyên ngành</option>
                            {{-- TODO: Lấy danh sách chuyên ngành từ Controller --}}
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. BẢNG DANH SÁCH SINH VIÊN --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Danh sách sinh viên: Lớp 64KTPM3</h3> {{-- Sẽ được Controller truyền vào --}}
            <div class="action-buttons-group">
                <button type="button" class="btn btn-primary" data-modal-target="#addStudentModal">
                    <i class="fa-solid fa-plus"></i> Thêm sinh viên
                </button>
                <a href="#" class="btn btn-secondary">
                    <i class="fa-solid fa-file-excel"></i> Nhập Excel
                </a>
                <a href="#" class="btn btn-secondary">
                    <i class="fa-solid fa-download"></i> Xuất Excel
                </a>
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
                            <th>Số điện thoại</th>
                            <th>Chuyên ngành</th>
                            <th>Lớp sinh hoạt</th>
                            <th>Nhận diện khuôn mặt</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        {{-- Dữ liệu giả lập --}}
                        @for ($i = 0; $i < 5; $i++)
                        <tr>
                            <td>22511772{{ $i }}</td>
                            <td>Nguyễn Văn A</td>
                            <td>a.nv@tlu.edu.vn</td>
                            <td>090xxxxxxx</td>
                            <td>Kỹ thuật phần mềm</td>
                            <td>64KTPM3</td>
                            <td>
                                <i class="fa-solid fa-circle-check text-success"></i> Đã ĐK
                            </td>
                            <td class="action-cell">
                                {{-- Nút chi tiết/sửa --}}
                                <button type="button" class="btn btn-icon btn-sm" data-modal-target="#editStudentModal">
                                    <i class="fa-solid fa-pencil"></i>
                                </button>
                                {{-- Nút xóa --}}
                                <button type="button" class="btn btn-icon btn-sm text-danger" data-modal-target="#deleteStudentModal">
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

@endsection

{{-- 
|--------------------------------------------------------------------------
| CODE MODAL (HỘP THOẠI)
|--------------------------------------------------------------------------
--}}
@push('modals')
    @include('lecturer.modals.add-student-modal')
    @include('lecturer.modals.edit-student-modal')
    @include('lecturer.modals.delete-student-modal')
@endpush