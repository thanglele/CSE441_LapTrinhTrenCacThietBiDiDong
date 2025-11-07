<div id="deleteSessionModal" class="modal modal-confirmation">
    <div class="modal-content modal-content-small">
        <div class="modal-header modal-header-danger">
            <h2 class="modal-title">Xác nhận xóa buổi học</h2>
            <button type="button" class="close-modal">&times;</button>
        </div>
        {{-- TODO: Sửa action="{{ route('...') }}" và truyền ID buổi học --}}
        <form action="#" method="POST">
            @csrf
            @method('DELETE')
            <div class="modal-body text-center">
                <div class="modal-icon-danger">
                    <i class="fa-solid fa-trash-can"></i>
                </div>
                <p>Bạn có chắc chắn muốn xóa buổi học **Buổi #1 (64KTPM3)** này không?</p>
                <input type="hidden" name="session_id" id="delete_session_id">
            </div>
            <div class="modal-footer form-actions">
                <button type="button" class="btn btn-secondary close-modal">Hủy</button>
                <button type="submit" class="btn btn-danger">Xác nhận</button>
            </div>
        </form>
    </div>
</div>