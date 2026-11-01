import 'package:flutter/material.dart';
import '../models/service_record.dart';
import '../repositories/service_repository.dart';

/// State management untuk riwayat servis.
class ServiceProvider extends ChangeNotifier {
  final ServiceRepository _repo = ServiceRepository();

  List<ServiceRecord> get all => _repo.getAll();

  List<ServiceRecord> getByWatch(String watchId) {
    return _repo.getByWatch(watchId);
  }

  List<ServiceRecord> get upcomingService {
    return _repo.getUpcomingService();
  }

  void add(ServiceRecord service) {
    _repo.add(service);
    notifyListeners();
  }

  bool delete(String id) {
    final result = _repo.delete(id);
    if (result) notifyListeners();
    return result;
  }
}
