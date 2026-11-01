import 'package:flutter/material.dart';
import '../models/watch.dart';
import '../repositories/watch_repository.dart';

/// State management untuk jam tangan.
class WatchProvider extends ChangeNotifier {
  final WatchRepository _repo = WatchRepository();

  String _searchQuery = '';
  WatchType? _filterType;

  List<Watch> get watches {
    var result = _repo.search(_searchQuery);
    if (_filterType != null) {
      result = result.where((w) => w.movementType == _filterType).toList();
    }
    return result;
  }

  List<Watch> get all => _repo.getAll();

  String get searchQuery => _searchQuery;
  WatchType? get filterType => _filterType;

  int get totalWatches => _repo.totalWatches;
  int get totalStock => _repo.totalStock;
  int get outOfStockCount => _repo.outOfStock;

  int get activeWarrantyCount {
    return _repo.getAll().where((w) {
      final s = w.warrantyStatus;
      return s == WarrantyStatus.active || s == WarrantyStatus.expiringSoon;
    }).length;
  }

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

  Watch? getById(String id) => _repo.getById(id);

  bool isSerialNumberTaken(String serialNumber, {String? excludeId}) {
    return _repo.isSerialNumberTaken(serialNumber, excludeId: excludeId);
  }

  void add(Watch watch) {
    _repo.add(watch);
    notifyListeners();
  }

  void update(Watch watch) {
    _repo.update(watch);
    notifyListeners();
  }

  bool delete(String id) {
    final result = _repo.delete(id);
    if (result) notifyListeners();
    return result;
  }

  /// Refresh (jika perlu untuk reload dari sumber data).
  void refresh() {
    notifyListeners();
  }
}
