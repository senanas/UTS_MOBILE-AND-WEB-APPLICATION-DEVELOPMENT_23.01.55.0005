/// Hasil validasi sebuah field.
class ValidationResult {
  final bool isValid;
  final String? error;
  const ValidationResult(this.isValid, [this.error]);

  static const valid = ValidationResult(true, null);
  static ValidationResult invalid(String message) => ValidationResult(false, message);
}

/// Service validasi untuk form-form ChronoStore.
class ValidationService {
  /// Validasi email.
  static ValidationResult validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('Email wajib diisi');
    if (!v.contains('@') || !v.contains('.')) {
      return ValidationResult.invalid('Format email tidak valid');
    }
    return ValidationResult.valid;
  }

  /// Validasi password.
  static ValidationResult validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return ValidationResult.invalid('Kata sandi wajib diisi');
    if (v.length < 6) {
      return ValidationResult.invalid('Kata sandi minimal 6 karakter');
    }
    return ValidationResult.valid;
  }

  /// Validasi nama.
  static ValidationResult validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('Nama wajib diisi');
    if (v.length < 2) {
      return ValidationResult.invalid('Nama minimal 2 karakter');
    }
    return ValidationResult.valid;
  }

  /// Validasi teks wajib.
  static ValidationResult validateRequired(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('$fieldName wajib diisi');
    return ValidationResult.valid;
  }

  /// Validasi angka wajib & non-negatif.
  static ValidationResult validateNonNegativeInt(String? value, String fieldName) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('$fieldName wajib diisi');
    final n = int.tryParse(v);
    if (n == null) return ValidationResult.invalid('$fieldName harus berupa angka');
    if (n < 0) return ValidationResult.invalid('$fieldName tidak boleh negatif');
    return ValidationResult.valid;
  }

  /// Validasi harga > 0.
  static ValidationResult validatePrice(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('Harga wajib diisi');
    final n = int.tryParse(v);
    if (n == null) return ValidationResult.invalid('Harga harus berupa angka');
    if (n <= 0) return ValidationResult.invalid('Harga harus lebih dari 0');
    return ValidationResult.valid;
  }

  /// Validasi nomor seri unik.
  static ValidationResult validateSerialNumber(
    String? value, {
    required bool isTaken,
  }) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return ValidationResult.invalid('Nomor seri wajib diisi');
    if (isTaken) {
      return ValidationResult.invalid('Nomor seri sudah digunakan');
    }
    return ValidationResult.valid;
  }
}
