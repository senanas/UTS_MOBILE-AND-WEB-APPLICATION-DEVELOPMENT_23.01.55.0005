import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../repositories/watch_repository.dart';

/// State management untuk transaksi.
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();
  final WatchRepository _watchRepo = WatchRepository();

  List<Transaction> get all => _repo.getAllSorted();

  List<Transaction> getByUser(String userId) {
    return _repo.getByUser(userId);
  }

  /// Buat transaksi baru + kurangi stok jam tangan.
  /// Mengembalikan true jika berhasil.
  bool create({
    required String watchId,
    required String watchName,
    required int quantity,
    required int unitPrice,
    required String customerName,
    required String userId,
  }) {
    final watch = _watchRepo.getById(watchId);
    if (watch == null || watch.stock < quantity) {
      return false;
    }

    _repo.add(Transaction(
      id: '',
      watchId: watchId,
      watchName: watchName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: unitPrice * quantity,
      transactionDate: DateTime.now(),
      customerName: customerName,
      userId: userId,
      status: TransactionStatus.completed,
    ));

    _watchRepo.reduceStock(watchId, quantity);
    notifyListeners();
    return true;
  }

  /// Update status transaksi.
  void updateStatus(String id, TransactionStatus status) {
    _repo.updateStatus(id, status);
    notifyListeners();
  }
}
