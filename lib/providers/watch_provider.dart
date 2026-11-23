import 'dart:async';

import 'package:flutter/material.dart';

import '../models/watch.dart';
import '../services/layanan_chronostore.dart';
import '../services/layanan_firestore.dart';

/// State management jam tangan — Minggu 10: sumber data Cloud Firestore.
///
/// Provider berlangganan `streamDaftarJam()` lalu menyimpan hasilnya di cache.
/// Getter lama (all / getById / search) tetap sinkron supaya halaman lama tidak
/// perlu diubah, tetapi isinya kini real-time dan bertahan setelah refresh.
class WatchProvider extends ChangeNotifier {
  final LayananChronoStore _layanan;
  StreamSubscription<List<Watch>>? _subscription;

  List<Watch> _watches = [];
  bool _loaded = false;
  String? _error;
  String _searchQuery = '';
  WatchType? _filterType;

  WatchProvider({LayananChronoStore? layanan})
      : _layanan = layanan ?? LayananFirestore() {
    _subscription = _layanan.streamDaftarJam().listen(
      (list) {
        _watches = list;
        _loaded = true;
        _error = null;
        notifyListeners();
      },
      onError: (Object error) {
        _loaded = true;
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  bool get isLoading => !_loaded;
  String? get error => _error;

  List<Watch> get all => List.unmodifiable(_watches);

  List<Watch> get watches {
    var result = _searchQuery.isEmpty
        ? List<Watch>.from(_watches)
        : _watches.where((w) {
            final q = _searchQuery.toLowerCase();
            return w.name.toLowerCase().contains(q) ||
                w.brand.toLowerCase().contains(q) ||
                w.model.toLowerCase().contains(q) ||
                w.serialNumber.toLowerCase().contains(q);
          }).toList();
    if (_filterType != null) {
      result = result.where((w) => w.movementType == _filterType).toList();
    }
    return result;
  }

  String get searchQuery => _searchQuery;
  WatchType? get filterType => _filterType;

  int get totalWatches => _watches.length;
  int get totalStock => _watches.fold(0, (sum, w) => sum + w.stock);
  int get outOfStockCount => _watches.where((w) => w.isOutOfStock).length;
  int get activeWarrantyCount => _watches.where((w) {
        final status = w.warrantyStatus;
        return status == WarrantyStatus.active ||
            status == WarrantyStatus.expiringSoon;
      }).length;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilterType(WatchType? type) {
    _filterType = type;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _filterType = null;
    notifyListeners();
  }

  Watch? getById(String id) {
    for (final watch in _watches) {
      if (watch.id == id) return watch;
    }
    return null;
  }

  bool isSerialNumberTaken(String serialNumber, {String? excludeId}) {
    return _watches.any(
      (w) =>
          w.serialNumber.toLowerCase() == serialNumber.toLowerCase() &&
          w.id != excludeId,
    );
  }

  // Create / Update / Delete diteruskan ke Firestore. Stream mengirim data
  // terbaru dan memicu notifyListeners() dengan sendirinya.
  Future<Watch> add(Watch watch) => _layanan.tambahJam(watch);
  Future<void> update(Watch watch) => _layanan.ubahJam(watch);
  Future<void> delete(String id) => _layanan.hapusJam(id);

  void refresh() => notifyListeners();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
