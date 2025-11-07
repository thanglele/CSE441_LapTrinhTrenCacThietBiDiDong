<div id="addStudentModal" class="modal">
    <div class="modal-content modal-content-medium">
        <div class="modal-header">
            <h2 class="modal-title">Thêm sinh viên</h2>
            <button type="button" class="close-modal">&times;</button>
        </div>
        {{-- TODO: Sửa action="{{ route('...') }}" cho API thêm SV --}}
        <form action="#" method="POST">
            @csrf
            <div class="modal-body">
                <div class="form-grid-modal">
                    <div class="form-item form-item-full-width">
                        <label for="add_name">Tên sinh viên *</label>
                        <input type="text" id="add_name" name="name" class="form-control" value="Tên sinh viên mẫu">
                    </div>
                    <div class="form-item">
                        <label for="add_msv">Mã sinh viên *</label>
                        <input type="text" id="add_msv" name="msv" class="form-control" value="2251177299">
                    </div>
                    <div class="form-item">
                        <label for="add_class">Lớp *</label>
                        <input type="text" id="add_class" name="class" class="form-control" value="64KTPM3">
                    </div>
                    <div class="form-item">
                        <label for="add_email">Email *</label>
                        <input type="email" id="add_email" name="email" class="form-control" value="a@tlu.edu.vn">
                    </div>
                    <div class="form-item">
                        <label for="add_phone">Số điện thoại</label>
                        <input type="text" id="add_phone" name="phone" class="form-control" value="090xxxxxxx">
                    </div>
                    <div class="form-item">
                        <label for="add_dob">Ngày sinh</label>
                        <input type="date" id="add_dob" name="dob" class="form-control" value="2025-09-20">
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