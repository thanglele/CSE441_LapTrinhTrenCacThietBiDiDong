import './bootstrap';
import '../css/app.css';
import '../css/lecturer/lecturer.css';

document.addEventListener('DOMContentLoaded', function () {

    // Logic cho Menu Dropdown (Đã đúng)
    document.querySelectorAll('.has-submenu > a').forEach(menu => {
        menu.addEventListener('click', function(e) {
            e.preventDefault();
            let parent = this.parentElement;
            parent.classList.toggle('open');
        });
    });
    
    // Logic cho MODAL (ĐÃ PHỤC HỒI NỘI DUNG HÀM)
    const openButtons = document.querySelectorAll('[data-modal-target]');
    const closeButtons = document.querySelectorAll('.close-modal');

    // Mở modal (khi click vào nút [data-modal-target])
    openButtons.forEach(button => {
        button.addEventListener('click', function() {
            const modalId = this.getAttribute('data-modal-target');
            const modal = document.querySelector(modalId);
            if (modal) {
                modal.style.display = 'block'; // <--- NỘI DUNG HÀM ĐƯỢC PHỤC HỒI
            }
        });
    });

    // Đóng modal (Khi bấm nút X hoặc nút Hủy)
    closeButtons.forEach(button => {
        button.addEventListener('click', function() {
            const modal = this.closest('.modal');
            if (modal) {
                modal.style.display = 'none'; // <--- NỘI DUNG HÀM ĐƯỢC PHỤC HỒI
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