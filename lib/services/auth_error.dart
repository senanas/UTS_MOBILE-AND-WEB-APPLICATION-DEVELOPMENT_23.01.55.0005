/// Menerjemahkan FirebaseAuthException.code menjadi pesan yang dipahami pengguna.
/// Modul Minggu 9, bab 6 — "Menerjemahkan Kode Error".
class AuthError {
  static String message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        // Sengaja disamakan agar orang lain tidak bisa menebak email terdaftar.
        return 'Email atau password salah';
      case 'invalid-email':
        return 'Format email belum benar';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan masuk.';
      case 'weak-password':
        return 'Password terlalu lemah, minimal 6 karakter';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak dapat terhubung. Periksa koneksi internet.';
      case 'operation-not-allowed':
        return 'Login email/password belum diaktifkan';
      default:
        return 'Terjadi kesalahan. Coba lagi.';
    }
  }
}
