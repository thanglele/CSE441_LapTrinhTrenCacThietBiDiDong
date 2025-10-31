/**
 * Chờ cho toàn bộ nội dung trang được tải
 */
document.addEventListener('DOMContentLoaded', function() {

    // Tìm các phần tử trên trang
    const togglePassword = document.getElementById('togglePassword');
    const password = document.getElementById('password');

    // Kiểm tra xem các phần tử có tồn tại không
    if (togglePassword && password) {

        // Lấy icon bên trong nút
        const eyeIcon = togglePassword.querySelector('i');

        // Thêm sự kiện click
        togglePassword.addEventListener('click', function () {
            // Lấy kiểu của input (password hay text)
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            password.setAttribute('type', type);

            // Đổi biểu tượng con mắt
            eyeIcon.classList.toggle('fa-eye');
            eyeIcon.classList.toggle('fa-eye-slash');
        });
    }
});