import 'package:firebase_core/firebase_core.dart';

/// Terjemahkan error Firestore ke pesan Indonesia yang bisa ditindaklanjuti.
///
/// SnackBar generik ("Gagal menyimpan...") menyembunyikan kode error asli,
/// sehingga sulit dibedakan antara Rules belum dipublish, index belum ada,
/// atau koneksi putus. Pemetaan ini menampilkan kode + saran perbaikan.
class FirestoreError {
  const FirestoreError._();

  static String pesan(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Akses ditolak (permission-denied). Buka Firebase Console → '
              'Firestore Database → Rules, pastikan '
              '"allow read, write: if request.auth != null;" lalu klik Publish.';
        case 'failed-precondition':
          return 'Query butuh composite index (failed-precondition). '
              'Hapus .orderBy() atau buat index di Firebase Console.';
        case 'unavailable':
          return 'Firestore tidak dapat dijangkau (unavailable). '
              'Periksa koneksi internet lalu coba lagi.';
        case 'deadline-exceeded':
          return 'Waktu tunggu Firestore habis. Periksa koneksi lalu coba lagi.';
        case 'not-found':
          return 'Dokumen jam tangan tidak ditemukan di Firestore. '
              'Lakukan hot restart agar data awal terisi.';
        case 'aborted':
          return 'Transaksi dibatalkan (aborted). Coba lagi beberapa saat.';
        case 'unauthenticated':
          return 'Sesi login habis. Silakan keluar lalu masuk kembali.';
        default:
          return 'Firestore [${error.code}]: ${error.message ?? "kesalahan tidak diketahui"}';
      }
    }
    return 'Gagal menyimpan: $error';
  }
}
