// Quy tắc giao diện tạm thời; cần thống nhất lại khi kết nối Backend.
class AuthValidators {
  static String? fullName(String? value) {
    final name = (value ?? '').trim();
    if (name.isEmpty) return 'Vui lòng nhập họ tên';
    if (name.length < 2) return 'Họ tên cần ít nhất 2 ký tự';
    return null;
  }

  static String? email(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  static String? phone(String? value) {
    final phone = (value ?? '').trim();
    if (phone.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^(0\d{9}|\+84\d{9})$').hasMatch(phone)) {
      return 'Nhập 10 chữ số bắt đầu bằng 0 hoặc dạng +84';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    return null;
  }

  static String? registerPassword(String? value) {
    final requiredError = loginPassword(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 8) return 'Mật khẩu cần ít nhất 8 ký tự';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu';
    if (value != password) return 'Mật khẩu xác nhận không khớp';
    return null;
  }
}
