import '../models/transaction.dart';
import '../utils/id_generator.dart';
import 'mock_data.dart';

/// Repository transaksi (fase lokal).
/// Saat Firebase siap, ganti implementasi ini dengan Cloud Firestore.
class TransactionRepository {
  final List<Transaction> _transactions = List.from(MockData.transactions);

  /// Ambil semua transaksi (admin).
  List<Transaction> getAll() {
    return List.unmodifiable(_transactions);
  }

  /// Ambil transaksi milik satu pelanggan.
  List<Transaction> getByUser(String userId) {
    return _transactions.where((t) => t.userId == userId).toList()
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  /// Ambil semua, diurutkan terbaru di atas.
  List<Transaction> getAllSorted() {
    final list = List<Transaction>.from(_transactions);
    list.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return list;
  }

  /// Tambah transaksi baru.
  Transaction add(Transaction transaction) {
    final newTransaction = Transaction(
      id: IdGenerator.generate('t'),
      watchId: transaction.watchId,
      watchName: transaction.watchName,
      quantity: transaction.quantity,
      unitPrice: transaction.unitPrice,
      totalPrice: transaction.totalPrice,
      transactionDate: transaction.transactionDate,
      customerName: transaction.customerName,
      userId: transaction.userId,
      status: transaction.status,
    );
    _transactions.add(newTransaction);
    return newTransaction;
  }

  /// Update status transaksi.
  Transaction? updateStatus(String id, TransactionStatus status) {
    final idx = _transactions.indexWhere((t) => t.id == id);
    if (idx == -1) return null;
    _transactions[idx] = _transactions[idx].copyWith(status: status);
    return _transactions[idx];
  }
}
