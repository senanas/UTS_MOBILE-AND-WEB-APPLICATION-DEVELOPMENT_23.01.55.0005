import '../models/watch.dart';
import '../utils/id_generator.dart';
import 'mock_data.dart';

/// Repository jam tangan (fase lokal).
/// Saat Firebase siap, ganti implementasi ini dengan Cloud Firestore.
class WatchRepository {
  final List<Watch> _watches = List.from(MockData.watches);

  /// Ambil semua jam tangan.
  List<Watch> getAll() {
    return List.unmodifiable(_watches);
  }

  /// Ambil satu jam tangan berdasarkan ID.
  Watch? getById(String id) {
    try {
      return _watches.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Cari berdasarkan teks (nama, merek, model, nomor seri).
  List<Watch> search(String query) {
    if (query.isEmpty) return getAll();
    final q = query.toLowerCase();
    return _watches.where((w) {
      return w.name.toLowerCase().contains(q) ||
          w.brand.toLowerCase().contains(q) ||
          w.model.toLowerCase().contains(q) ||
          w.serialNumber.toLowerCase().contains(q);
    }).toList();
  }

  /// Cek apakah nomor seri sudah dipakai.
  bool isSerialNumberTaken(String serialNumber, {String? excludeId}) {
    return _watches.any(
      (w) => w.serialNumber.toLowerCase() == serialNumber.toLowerCase() && w.id != excludeId,
    );
  }

  /// Tambah jam tangan baru.
  Watch add(Watch watch) {
    final newWatch = Watch(
      id: IdGenerator.generate('w'),
      name: watch.name,
      brand: watch.brand,
      model: watch.model,
      movementType: watch.movementType,
      price: watch.price,
      stock: watch.stock,
      serialNumber: watch.serialNumber,
      imageUrl: watch.imageUrl,
      warrantyStart: watch.warrantyStart,
      warrantyEnd: watch.warrantyEnd,
      createdAt: DateTime.now(),
    );
    _watches.add(newWatch);
    return newWatch;
  }

  /// Update jam tangan.
  Watch? update(Watch watch) {
    final idx = _watches.indexWhere((w) => w.id == watch.id);
    if (idx == -1) return null;
    _watches[idx] = watch;
    return watch;
  }

  /// Hapus jam tangan.
  bool delete(String id) {
    final idx = _watches.indexWhere((w) => w.id == id);
    if (idx == -1) return false;
    _watches.removeAt(idx);
    return true;
  }

  /// Kurangi stok (dipanggil saat transaksi).
  bool reduceStock(String watchId, int quantity) {
    final idx = _watches.indexWhere((w) => w.id == watchId);
    if (idx == -1) return false;
    final w = _watches[idx];
    if (w.stock < quantity) return false;
    _watches[idx] = w.copyWith(stock: w.stock - quantity);
    return true;
  }

  /// Ringkasan untuk dashboard.
  int get totalWatches => _watches.length;
  int get totalStock => _watches.fold(0, (sum, w) => sum + w.stock);
  int get activeWarranty => _watches.where((w) {
    final status = w.warrantyStatus;
    return status == WarrantyStatus.active || status == WarrantyStatus.expiringSoon;
  }).length;
  int get outOfStock => _watches.where((w) => w.isOutOfStock).length;
}
