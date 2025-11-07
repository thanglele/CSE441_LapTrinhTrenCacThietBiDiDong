{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

{{-- Đặt tiêu đề cho trang này --}}
@section('title', 'Thêm lớp học mới')

{{-- Phần nội dung chính của trang --}}
@section('content')

    <h1 class="content-title">Thêm lớp học</h1>

    {{-- Form thêm lớp học --}}
    {{-- TODO: Sửa action="{{ route('...') }}" và thêm @csrf token --}}
    <form action="#" method="POST">
        @csrf 
        <div class="card card-full-width">
            <div class="card-body">
                {{-- Dùng CSS Grid để chia form --}}
                <div class="form-grid">
                    
                    {{-- Tên môn học (Dropdown) --}}
                    <div class="form-item form-item-full-width">
                        <label for="subject_code">Tên môn học *</label>
                        {{-- TODO: Lấy danh sách môn học từ Controller --}}
                        <select id="subject_code" name="subject_code" class="form-control">
                            <option value="CSE441.Mobile Dev">CSE441.Mobile Dev</option>
                            <option value="CSE123">CSE123.Cấu trúc dữ liệu</option>
                        </select>
                    </div>

                    {{-- Tên lớp học phần --}}
                    <div class="form-item">
                        <label for="class_code">Tên lớp học phần *</label>
                        <input type="text" id="class_code" name="class_code" class="form-control" value="CSE441.Mobile Dev">
                    </div>

                    {{-- Niên khóa --}}
                    <div class="form-item">
                        <label for="academic_year">Niên khóa *</label>
                        <input type="text" id="academic_year" name="academic_year" class="form-control" value="2000">
                    </div>

                    {{-- Học kỳ --}}
                    <div class="form-item">
                        <label for="semester">Học kỳ *</label>
                        <input type="text" id="semester" name="semester" class="form-control" value="Học Kỳ I">
                    </div>

                    {{-- Phòng học --}}
                    <div class="form-item">
                        <label for="room">Phòng học *</label>
                        <input type="text" id="room" name="room" class="form-control" value="00000000">
                    </div>

                    {{-- Sĩ số --}}
                    <div class="form-item">
                        <label for="student_count">Sĩ số *</label>
                        <input type="number" id="student_count" name="student_count" class="form-control" value="60">
                    </div>

                    {{-- Loại hình học --}}
                    <div class="form-item">
                        <label for="class_type">Loại hình học *</label>
                        <select id="class_type" name="class_type" class="form-control">
                            <option value="LyThuyet">Lý thuyết</option>
                            <option value="ThucHanh">Thực hành</option>
                        </select>
                    </div>

                    {{-- Ngày bắt đầu --}}
                    <div class="form-item">
                        <label for="start_date">Ngày bắt đầu *</label>
                        <input type="date" id="start_date" name="start_date" class="form-control" value="2025-09-20">
                    </div>

                    {{-- Ngày kết thúc --}}
                    <div class="form-item">
                        <label for="end_date">Ngày kết thúc *</label>
                        <input type="date" id="end_date" name="end_date" class="form-control" value="2025-09-20">
                    </div>

                    {{-- Trạng thái --}}
                    <div class="form-item">
                        <label for="status">Trạng thái *</label>
                        <select id="status" name="status" class="form-control">
                            <option value="active">Đang hoạt động</option>
                            <option value="finished">Đã kết thúc</option>
                        </select>
                    </div>

                </div>
            </div>

            {{-- Nút bấm (Footer) --}}
            <div class="card-footer form-actions">
                <button type="button" class="btn btn-secondary">Hủy</button>
                <button type="submit" class="btn btn-primary">Xác nhận</button>
            </div>
        </div>
    </form>

@endsection