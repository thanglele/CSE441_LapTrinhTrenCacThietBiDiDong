{{-- Kế thừa layout chính từ 'layouts.app' --}}
@extends('layouts.app')

@section('title', 'Tạo mã QR')

@section('content')

    <h1 class="content-title">Tạo mã QR</h1>

    {{-- Khung chứa 2 cột chính: Thông tin và Mã QR --}}
    <div class="qr-container-grid">
        
        {{-- CỘT 1: THÔNG TIN BUỔI HỌC VÀ FORM --}}
        <div class="card">
            <div class="card-header">
                <h3>Thông tin buổi học:</h3>
            </div>
            {{-- TODO: Sửa action="{{ route('...') }}" cho API tạo QR --}}
            <form action="#" method="POST" id="qrCreationForm">
                @csrf
                <div class="card-body form-grid-qr">
                    
                    {{-- Các trường thông tin (ReadOnly) --}}
                    <div class="form-item form-item-full-width">
                        <label>Tên môn học</label>
                        <input type="text" class="form-control" value="CSE441.Mobile Dev" readonly>
                    </div>
                    <div class="form-item">
                        <label>Phòng học</label>
                        <input type="text" class="form-control" value="305 - B5" readonly>
                    </div>
                    <div class="form-item">
                        <label>Thời gian học</label>
                        <input type="text" class="form-control" value="8:00 - 9:30" readonly>
                    </div>
                    <div class="form-item">
                        <label>Lớp</label>
                        <input type="text" class="form-control" value="64KTPM3" readonly>
                    </div>
                    <div class="form-item">
                        <label>Ngày</label>
                        <input type="text" class="form-control" value="20/09/2025" readonly>
                    </div>

                    {{-- THỜI GIAN ĐIỂM DANH (Dropdown) --}}
                    <div class="form-item form-item-full-width mt-3">
                        <label>Thời gian điểm danh</label>
                        <div class="input-time-group">
                            {{-- Giờ bắt đầu --}}
                            <select name="start_time" class="form-control form-control-small">
                                <option value="8:00">8:00</option>
                                <option value="8:05">8:05</option>
                            </select>
                            <span class="time-separator">–</span>
                            {{-- Giờ kết thúc --}}
                            <select name="end_time" class="form-control form-control-small">
                                <option value="8:30">8:30</option>
                                <option value="8:35">8:35</option>
                            </select>
                        </div>
                    </div>
                    
                </div>
                
                <div class="card-footer qr-action-footer">
                    <button type="submit" class="btn btn-primary btn-icon-only">
                        <i class="fa-solid fa-qrcode"></i> Tạo QR
                    </button>
                </div>
            </form>
        </div>

        {{-- CỘT 2: KHUNG MÃ QR VÀ NÚT BẤM --}}
        <div class="card qr-display-card">
            <div class="card-header">
                <h3>Mã QR truy cập điểm danh</h3>
            </div>
            <div class="card-body qr-content-area">
                
                <div id="qrPlaceholder" class="qr-placeholder">
                    <p>Nhấn "Tạo QR" để bắt đầu phiên điểm danh.</p>
                </div>
                
            </div>
            <div class="card-footer qr-action-footer-buttons">
                <a href="#" class="btn btn-secondary">Chỉnh sửa</a>
                <a href="#" class="btn btn-primary">Quản lý điểm danh</a>
            </div>
        </div>
    </div>

@endsection