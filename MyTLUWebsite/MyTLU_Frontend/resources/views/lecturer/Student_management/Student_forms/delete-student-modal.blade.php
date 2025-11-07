<div id="deleteStudentModal" class="modal modal-confirmation">
    <div class="modal-content modal-content-small">
        <div class="modal-header modal-header-danger">
            <h2 class="modal-title">Xác nhận xóa sinh viên</h2>
            <button type="button" class="close-modal">&times;</button>
        </div>
        {{-- TODO: Sửa action="{{ route('...') }}" và truyền ID sinh viên --}}
        <form action="#" method="POST">
            @csrf
            @method('DELETE')
            <div class="modal-body text-center">
                <div class="modal-icon-danger">
                    <i class="fa-solid fa-trash-can"></i>
                </div>
                <p>Bạn có chắc chắn muốn xóa sinh viên **Nguyễn Thị Dinh** khỏi danh sách lớp 64KTPM3?</p>
                <input type="hidden" name="student_id" id="delete_student_id">
            </div>
            <div class="modal-footer form-actions">
                <button type="button" class="btn btn-secondary close-modal">Hủy</button>
                <button type="submit" class="btn btn-danger">Xác nhận</button>
            </div>
        </form>
    </div>
</div>