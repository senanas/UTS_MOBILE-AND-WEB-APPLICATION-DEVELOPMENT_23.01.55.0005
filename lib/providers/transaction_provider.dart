import 'dart:async';

import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../services/layanan_chronostore.dart';
import '../services/layanan_firestore.dart';

/// State management transaksi — Minggu 10: koleksi `transactions` di Firestore.
///
/// Halaman daftar memakai `StreamBuilder` langsung dari layanan, sedangkan
/// provider ini menyimpan cache untuk keperluan lain (ringkasan, form) serta
/// menjadi tempat operasi tulis yang dipanggil UI.
class TransactionProvider extends ChangeNotifier {
  final LayananChronoStore _layanan;
  StreamSubscription<List<Transaction>>? _subscription;

  List<Transaction> _all = [];
  bool _loaded = false;

  TransactionProvider({LayananChronoStore? layanan})
      : _layanan = layanan ?? LayananFirestore() {
    _subscription = _layanan.streamSemuaTransaksi().listen((list) {
      _all = list;
      _loaded = true;
      notifyListeners();
    });
  }

  bool get isLoading => !_loaded;
  List<Transaction> get all => List.unmodifiable(_all);

  List<Transaction> getByUser(String userId) =>
      _all.where((t) => t.userId == userId).toList();

  /// Menyimpan pesanan ke Firestore. Aturan bisnis (cegah pesanan ganda dan
  /// cek stok) dijalankan di dalam layanan; exception diteruskan ke form
  /// supaya bisa ditampilkan sebagai SnackBar tanpa menutup halaman.
  Future<void> create({
    required String watchId,
    required String watchName,
    required int quantity,
    required int unitPrice,
    required int totalPrice,
    required int ongkir,
    required String customerName,
    required String userId,
    String email = '',
    String phone = '',
    String address = '',
    String city = '',
    String postalCode = '',
    String notes = '',
  }) {
    return _layanan.tambahTransaksi(
      uid: userId,
      namaPelanggan: customerName,
      watchId: watchId,
      watchName: watchName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      ongkir: ongkir,
      emailPelanggan: email,
      teleponPelanggan: phone,
      alamatPengiriman: address,
      kota: city,
      kodePos: postalCode,
      catatan: notes,
    );
  }

  Future<void> updateStatus(String id, TransactionStatus status) =>
      _layanan.ubahStatusTransaksi(id, status);

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
