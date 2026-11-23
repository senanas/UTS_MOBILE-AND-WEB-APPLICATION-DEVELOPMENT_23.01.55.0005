import '../models/watch.dart';
import '../repositories/mock_data.dart';

/// Master data awal jam tangan untuk koleksi `watches`.
///
/// Minggu 9 data ini masih hidup di memori aplikasi. Mulai Minggu 10 daftar ini
/// ditulis sekali saja ke Cloud Firestore lewat WriteBatch (auto-seed) ketika
/// koleksi `watches` masih kosong, lalu dibaca ulang dengan `.snapshots()`.
/// Menyimpannya di sini membuat `LayananFirestore` dan `LayananMemori` memakai
/// sumber data yang sama persis, sehingga hasil widget test dapat dipercaya.
final List<Watch> daftarJamAwal = List.unmodifiable(MockData.watches);

/// Kunci tanggal 'yyyy-MM-dd' untuk aturan bisnis "cegah pesanan ganda".
/// Padanan dari pengecekan `tanggal` + `jam_mulai` pada contoh RoomBook.
String formatTanggal(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
