{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

@section('title', 'Duyệt nhận diện khuôn mặt')

@section('content')

    <h1 class="content-title">Quản lý duyệt nhận diện khuôn mặt</h1>

    {{-- 1. KHUNG LỌC --}}
    <div class="card card-filter">
        <div class="card-body">
            <div class="filter-grid filter-grid-3-cols">
                <div class="filter-item">
                    <label for="filter_class">Lọc theo Lớp</label>
                    <div class="input-group">
                        <i class="fa-solid fa-graduation-cap"></i>
                        <select id="filter_class" class="form-control">
                            <option value="all">Tất cả các lớp</option>
                            {{-- TODO: Lấy danh sách lớp giảng viên dạy --}}
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- 2. DANH SÁCH YÊU CẦU CHỜ DUYỆT --}}
    <div class="card card-full-width">
        <div class="card-header">
            <h3>Yêu cầu chờ duyệt</h3>
        </div>
        <div class="card-body">
            
            {{-- BLADE FORELSE: Lặp qua dữ liệu $reviewList từ Controller --}}
            @forelse ($reviewList as $request)
            <div class="review-item-card">
                <div class="student-info-section">
                    <h4 class="student-name">{{ $request['fullName'] }} ({{ $request['studentCode'] }})</h4>
                    <p>Mã yêu cầu: **{{ $request['faceDataId'] }}** | Ngày gửi: {{ \Carbon\Carbon::parse($request['uploadedAt'])->format('H:i d/m/Y') }}</p>
                </div>
                
                <div class="photo-comparison-grid">
                    
                    {{-- Ảnh Gốc (2D từ Hồ sơ) --}}
                    <div class="photo-box">
                        <span class="photo-label">Ảnh Gốc (2D - Hồ sơ)</span>
                        <img src="{{ $request['profileImageUrl'] }}" alt="Ảnh Gốc 2D" class="photo-img">
                        <small class="photo-source">Nguồn: P.QLSV cung cấp</small>
                    </div>
                    
                    {{-- Ảnh Mới (3D/Liveness SV tự gửi) --}}
                    <div class="photo-box">
                        <span class="photo-label text-warning">Ảnh Mới (3D - Chờ duyệt)</span>
                        <img src="{{ $request['uploadedImageUrl'] }}" alt="Ảnh Mới 3D" class="photo-img border-warning">
                        <small class="photo-source">Nguồn: Sinh viên tự upload</small>
                    </div>
                </div>

                {{-- NÚT DUYỆT / TỪ CHỐI --}}
                <div class="review-actions">
                    {{-- Form TỪ CHỐI --}}
                    <form action="#" method="POST" class="d-inline-block">
                        @csrf
                        {{-- TODO: Thay dấu # bằng route POST /verify --}}
                        <input type="hidden" name="faceDataId" value="{{ $request['faceDataId'] }}">
                        <input type="hidden" name="isApproved" value="false">
                        <button type="submit" class="btn btn-danger">
                            <i class="fa-solid fa-times-circle"></i> Từ chối
                        </button>
                    </form>

                    {{-- Form DUYỆT --}}
                    <form action="#" method="POST" class="d-inline-block ml-2">
                        @csrf
                        <input type="hidden" name="faceDataId" value="{{ $request['faceDataId'] }}">
                        <input type="hidden" name="isApproved" value="true">
                        <button type="submit" class="btn btn-success">
                            <i class="fa-solid fa-check-circle"></i> Duyệt
                        </button>
                    </form>
                </div>
            </div>
            @empty
                <p class="text-center text-muted">Không có yêu cầu đăng ký sinh trắc học nào đang chờ duyệt.</p>
            @endforelse
            
        </div>
    </div>

@endsection