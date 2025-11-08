
document.addEventListener('DOMContentLoaded', function() {
    // Tìm phần tử nút bấm (span) và ô nhập (input)
    const togglePassword = document.getElementById('togglePassword');
    const password = document.getElementById('password');

    // Kiểm tra xem cả hai phần tử có tồn tại không
    if (togglePassword && password) {
        // Lấy phần tử icon <i> bên trong nút bấm
        const eyeIcon = togglePassword.querySelector('i');

        // Thêm sự kiện 'click' cho nút bấm
        togglePassword.addEventListener('click', function () {
            // Lấy kiểu (type) hiện tại của ô mật khẩu
            const type = password.getAttribute('type') === 'password' ? 'text' : 'password';
            // Gán kiểu mới cho ô mật khẩu
            password.setAttribute('type', type);

            // Đổi biểu tượng con mắt (bật/tắt 2 class)
            eyeIcon.classList.toggle('fa-eye');
            eyeIcon.classList.toggle('fa-eye-slash');
        });
    }
});