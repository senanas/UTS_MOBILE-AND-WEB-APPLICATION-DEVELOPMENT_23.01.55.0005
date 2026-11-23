import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

/// Penyimpanan cadangan untuk pesanan yang gagal ditulis ke Firestore
/// (misalnya Security Rules belum di-publish / koneksi putus).
///
/// Tujuannya: checkout tetap selesai dan pesanan tetap bisa dilihat di
/// halaman Riwayat Transaksi. Begitu Rules benar, pesanan berikutnya
/// kembali tersimpan langsung di Cloud Firestore.
class TransaksiLokal {
  static const _key = 'chronostore_transaksi_lokal';

  /// Simpan satu transaksi ke daftar lokal.
  static Future<void> simpan(Transaction tx) async {
    final daftar = await bacaSemua();
    daftar.add(tx);
    await _tulis(daftar);
  }

  /// Baca semua transaksi lokal, terbaru lebih dulu.
  static Future<List<Transaction>> bacaSemua() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    final daftar = <Transaction>[];
    for (final item in raw) {
      try {
        daftar.add(Transaction.fromMap(jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // Lewati entri rusak supaya seluruh daftar tetap terbaca.
      }
    }
    daftar.sort((a, b) => (b.createdAt ?? b.transactionDate)
        .compareTo(a.createdAt ?? a.transactionDate));
    return daftar;
  }

  /// Hapus semua transaksi lokal (dipakai setelah sinkron ke Firestore).
  static Future<void> hapusSemua() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<void> _tulis(List<Transaction> daftar) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      daftar.map((tx) => jsonEncode(tx.toMap())).toList(),
    );
  }
}
