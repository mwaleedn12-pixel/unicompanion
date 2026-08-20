abstract final class Validators {
  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
    return null;
  }

  static String? percentage(String? value) {
    if (value == null || value.isEmpty) return 'Enter a percentage';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > 100) return 'Must be between 0 and 100';
    return null;
  }

  static String? creditHours(String? value) {
    if (value == null || value.isEmpty) return 'Credit hours required';
    final num = int.tryParse(value);
    if (num == null || num < 1 || num > 6) return 'Must be between 1 and 6';
    return null;
  }

  static String? gpa(String? value, {double maxGpa = 4.0}) {
    if (value == null || value.isEmpty) return 'Enter GPA';
    final num = double.tryParse(value);
    if (num == null) return 'Enter a valid number';
    if (num < 0 || num > maxGpa) return 'Must be between 0 and $maxGpa';
    return null;
  }
}