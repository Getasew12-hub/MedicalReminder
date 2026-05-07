class Validators {
  const Validators._();

  static String? required(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  static String? email(String? value) {
    final requiredMessage = required(value, 'Email');
    if (requiredMessage != null) return requiredMessage;

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    final requiredMessage = required(value, 'Password');
    if (requiredMessage != null) return requiredMessage;
    if (value!.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    final requiredMessage = required(value, 'Confirm password');
    if (requiredMessage != null) return requiredMessage;
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
