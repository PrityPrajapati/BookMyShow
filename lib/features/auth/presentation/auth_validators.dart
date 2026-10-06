abstract final class AuthValidators {
  static final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static final RegExp _phonePattern = RegExp(r'^[6-9]\d{9}$');

  static String? name(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.length < 2) return 'Enter your name';
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (!_emailPattern.hasMatch(trimmed)) return 'Enter a valid email';
    return null;
  }

  static String? phone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
    if (!_phonePattern.hasMatch(local)) return 'Enter a 10-digit mobile number';
    return null;
  }

  static String? password(String? value) {
    if ((value ?? '').length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value != original) return 'Passwords do not match';
    return null;
  }
}

String normalizePhone(String value) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  final local = digits.length > 10 ? digits.substring(digits.length - 10) : digits;
  return '+91 $local';
}
