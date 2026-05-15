/// Form validation utilities for SIANKES
class Validators {
  Validators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email wajib diisi';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Format email tidak valid';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    if (value.length < 6) return 'Password minimal 6 karakter';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Konfirmasi password wajib diisi';
    if (value != password) return 'Password tidak cocok';
    return null;
  }

  static String? required(String? value, [String field = 'Field']) {
    if (value == null || value.trim().isEmpty) return '$field wajib diisi';
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
    if (value.trim().length < 3) return 'Nama minimal 3 karakter';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nomor HP wajib diisi';
    final regex = RegExp(r'^[0-9+]{10,15}$');
    if (!regex.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''))) return 'Format nomor HP tidak valid';
    return null;
  }

  static String? complaint(String? value) {
    if (value == null || value.trim().isEmpty) return 'Keluhan wajib diisi';
    if (value.trim().length < 5) return 'Jelaskan keluhan minimal 5 karakter';
    return null;
  }
}
