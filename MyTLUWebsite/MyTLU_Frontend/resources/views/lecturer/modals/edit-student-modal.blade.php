<div id="editStudentModal" class="modal">
    <div class="modal-content modal-content-medium">
        <div class="modal-header">
            <h2 class="modal-title">Chỉnh sửa sinh viên</h2>
            <button type="button" class="close-modal">&times;</button>
        </div>
        <form action="#" method="POST">
            @csrf
            @method('PUT') {{-- Dùng method PUT/PATCH cho sửa --}}
            <div class="modal-body">
                <div class="form-grid-modal">
                    <div class="form-item form-item-full-width">
                        <label for="edit_name">Tên sinh viên *</label>
                        {{-- Ví dụ: Giả định lấy giá trị từ một biến Laravel $student['fullName'] --}}
                        <input type="text" id="edit_name" name="name" class="form-control" value="Nguyễn Thị Dinh"> 
                    </div>
                    
                    <div class="form-item">
                        <label for="edit_msv">Mã sinh viên *</label>
                        <input type="text" id="edit_msv" name="msv" class="form-control" value="2251177226" readonly> {{-- Mã sinh viên thường là readonly --}}
                    </div>
                    <div class="form-item">
                        <label for="edit_class">Lớp *</label>
                        <input type="text" id="edit_class" name="class" class="form-control" value="64KTPM3">
                    </div>
                    <div class="form-item">
                        <label for="edit_email">Email *</label>
                        <input type="email" id="edit_email" name="email" class="form-control" value="dinh.nt@tlu.edu.vn">
                    </div>
                    <div class="form-item">
                        <label for="edit_phone">Số điện thoại</label>
                        <input type="text" id="edit_phone" name="phone" class="form-control" value="090xxxxxxx">
                    </div>
                    <div class="form-item">
                        <label for="edit_dob">Ngày sinh</label>
                        <input type="date" id="edit_dob" name="dob" class="form-control" value="2004-09-20">
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