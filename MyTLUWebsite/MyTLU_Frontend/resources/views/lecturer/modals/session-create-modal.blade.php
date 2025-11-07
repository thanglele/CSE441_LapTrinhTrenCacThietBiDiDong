<div id="addSessionModal" class="modal">
    <div class="modal-content modal-content-medium">
        <div class="modal-header">
            <h2 class="modal-title">Thêm buổi học mới</h2>
            <button type="button" class="close-modal">&times;</button>
        </div>
        <form action="#" method="POST">
            @csrf 
            <div class="modal-body">
                <div class="form-grid-modal">
                    
                    {{-- Tên lớp học --}}
                    <div class="form-item form-item-full-width">
                        <label for="session_class_id">Lớp học *</label>
                        {{-- TODO: Lấy danh sách lớp từ Controller --}}
                        <select id="session_class_id" name="class_id" class="form-control">
                            <option value="64KTPM3">64KTPM3 - Lập trình Mobile</option>
                            <option value="64KTPM1">64KTPM1 - Cấu trúc dữ liệu</option>
                        </select>
                    </div>

                    {{-- Tên buổi học --}}
                    <div class="form-item">
                        <label for="session_title">Tên buổi học *</label>
                        <input type="text" id="session_title" name="session_title" class="form-control" placeholder="Ví dụ: Buổi học #1">
                    </div>

                    {{-- Ngày --}}
                    <div class="form-item">
                        <label for="session_date">Ngày *</label>
                        <input type="date" id="session_date" name="session_date" class="form-control" value="{{ date('Y-m-d') }}">
                    </div>

                    {{-- Thời gian Bắt đầu --}}
                    <div class="form-item">
                        <label for="start_time">Thời gian bắt đầu *</label>
                        <input type="time" id="start_time" name="start_time" class="form-control" value="08:00">
                    </div>

                    {{-- Thời gian Kết thúc --}}
                    <div class="form-item">
                        <label for="end_time">Thời gian kết thúc *</label>
                        <input type="time" id="end_time" name="end_time" class="form-control" value="09:30">
                    </div>

                    {{-- Phòng học --}}
                    <div class="form-item">
                        <label for="room">Phòng học *</label>
                        <input type="text" id="room" name="room" class="form-control" value="305-B5">
                    </div>

                </div>
            </div>
            <div class="modal-footer form-actions">
                <button type="button" class="btn btn-secondary close-modal">Hủy</button>
                <button type="submit" class="btn btn-primary">Xác nhận</button>
            </div>
        </form>
    </div>
</div>