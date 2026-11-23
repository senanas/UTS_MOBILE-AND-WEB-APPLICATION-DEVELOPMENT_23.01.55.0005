import '../models/transaction.dart';
import '../models/user_account.dart';
import '../models/watch.dart';

/// Dilempar ketika pengguna yang sama memesan jam yang sama di tanggal yang
/// sama. Ini padanan aturan "cegah jadwal bentrok" pada contoh RoomBook.
class TransaksiBentrokException implements Exception {
  final String pesan;
  const TransaksiBentrokException(this.pesan);

  @override
  String toString() => pesan;
}

/// Dilempar ketika stok jam tangan lebih kecil dari jumlah pesanan.
class StokTidakCukupException implements Exception {
  final String pesan;
  const StokTidakCukupException(this.pesan);

  @override
  String toString() => pesan;
}

/// Kontrak layanan data Minggu 10: 3 collection (users, watches, transactions).
///
/// UI tidak pernah memanggil `FirebaseFirestore.instance` secara langsung.
/// Dengan begini widget test cukup menyuntik [LayananMemori] dan tetap lulus
/// tanpa koneksi internet / tanpa `Firebase.initializeApp()`.
abstract class LayananChronoStore {
  /// Buat dokumen `users/{uid}` bila belum ada (saat daftar / masuk).
  /// Peran yang dipilih saat mendaftar ikut disimpan di sini, sehingga
  /// menggantikan penyimpanan lokal sementara dari Minggu 9.
  Future<void> simpanProfilSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
    UserRole? peran,
  });

  /// Baca `peran` dari dokumen pengguna; null bila dokumen belum ada.
  Future<UserRole?> bacaPeran(String uid);

  /// Perbarui field `peran` pada dokumen `users/{uid}`.
  /// Dipakai untuk memperbaiki akun lama yang peran-nya salah di Firestore.
  Future<void> perbaruiPeran(String uid, UserRole peran);

  /// Aliran real-time profil untuk sapaan di Beranda.
  Stream<UserAccount?> streamProfil(String uid);

  /// Isi koleksi `watches` sekali saja bila masih kosong (WriteBatch).
  Future<void> isiJamAwalJikaKosong();

  /// Aliran real-time daftar jam tangan (katalog & dropdown).
  Stream<List<Watch>> streamDaftarJam();

  Future<Watch> tambahJam(Watch watch);
  Future<void> ubahJam(Watch watch);
  Future<void> hapusJam(String id);

  /// Simpan transaksi baru + cek pesanan ganda + kurangi stok.
  /// `totalPrice` sudah termasuk `ongkir` (dihitung di form checkout).
  Future<void> tambahTransaksi({
    required String uid,
    required String namaPelanggan,
    required String watchId,
    required String watchName,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required int ongkir,
    String emailPelanggan = '',
    String teleponPelanggan = '',
    String alamatPengiriman = '',
    String kota = '',
    String kodePos = '',
    String catatan = '',
  });

  /// Hanya transaksi milik pengguna yang sedang login (isolasi antar akun).
  Stream<List<Transaction>> streamTransaksiSaya(String uid);

  /// Semua transaksi, dipakai tampilan Admin.
  Stream<List<Transaction>> streamSemuaTransaksi();

  Future<void> ubahStatusTransaksi(String id, TransactionStatus status);
}
