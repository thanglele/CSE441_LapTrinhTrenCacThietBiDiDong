import './bootstrap';
import '../css/app.css';
import '../css/lecturer/lecturer.css';

document.addEventListener('DOMContentLoaded', function () {

    // === CODE NÀY ĐÃ ĐƯỢC ĐẶT TRONG DẤU NGOẶC NHỌN VÀ CHẠY ĐÚNG ===

    // Logic cho Menu Dropdown (Nút QL Lớp & Môn học)
    document.querySelectorAll('.has-submenu > a').forEach(menu => {
        menu.addEventListener('click', function(e) {
            e.preventDefault();
            let parent = this.parentElement;
            parent.classList.toggle('open');
        });
    });
    
    // Logic cho MODAL (Thêm/Sửa/Xóa sinh viên)
    const openButtons = document.querySelectorAll('[data-modal-target]');
    const closeButtons = document.querySelectorAll('.close-modal');

    // Mở modal (khi click vào nút [data-modal-target])
    openButtons.forEach(button => {
        button.addEventListener('click', function() {
            const modalId = this.getAttribute('data-modal-target');
            const modal = document.querySelector(modalId);
            if (modal) {
                modal.style.display = 'block';
            }
        });
    });

    // Đóng modal (Khi bấm nút X hoặc nút Hủy)
    closeButtons.forEach(button => {
        button.addEventListener('click', function() {
            const modal = this.closest('.modal');
            if (modal) {
                modal.style.display = 'none';
            }
        });
    });

    // Đóng modal khi click ra bên ngoài hộp thoại
    window.addEventListener('click', function(event) {
        if (event.target.classList.contains('modal')) {
            event.target.style.display = 'none';
        }
    });
});