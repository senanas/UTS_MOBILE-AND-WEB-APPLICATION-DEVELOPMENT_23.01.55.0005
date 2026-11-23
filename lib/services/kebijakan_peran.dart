import '../app/constants.dart';
import '../models/user_account.dart';

/// Kebijakan satu pintu untuk menentukan peran akun.
///
/// Masalah yang diatasi: Firebase Authentication tidak menyimpan role, dan
/// akun lama (dibuat sebelum collection `users` aktif, atau dibuat langsung
/// di Firebase Console) punya dokumen `users/{uid}` dengan `peran: pelanggan`.
/// Akibatnya akun `admin@chronostore.com` tetap tampil "(Pelanggan)" dan tidak
/// bisa menambah produk. Email yang terdaftar di [AppConstants.emailAdmin]
/// dipaksa menjadi Admin pada setiap login, lalu dokumen Firestore-nya
/// diperbaiki otomatis oleh `AuthRepository`.
///
/// Kelas ini sengaja murni (tanpa Firebase) supaya mudah diuji.
class KebijakanPeran {
  KebijakanPeran._();

  static String _normalkan(String? email) =>
      (email ?? '').trim().toLowerCase();

  /// Apakah email termasuk daftar bootstrap admin?
  static bool adalahEmailAdmin(String? email) =>
      AppConstants.emailAdmin.contains(_normalkan(email));

  /// Tentukan peran akhir.
  ///
  /// - Email admin → selalu [UserRole.admin] (mengabaikan cache & Firestore).
  /// - Email biasa → pakai peran yang sudah ada (pilihan saat daftar, cache,
  ///   atau hasil pembacaan Firestore). Ini mempertahankan promosi manual
  ///   lewat Console dan tidak menurunkan admin menjadi pelanggan.
  static UserRole tentukan(String? email, UserRole peranSaatIni) =>
      adalahEmailAdmin(email) ? UserRole.admin : peranSaatIni;
}
