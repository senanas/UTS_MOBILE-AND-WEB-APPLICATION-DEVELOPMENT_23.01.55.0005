import '../models/service_record.dart';
import '../utils/id_generator.dart';
import 'mock_data.dart';

/// Repository riwayat servis (fase lokal).
/// Saat Firebase siap, ganti implementasi ini dengan Cloud Firestore.
class ServiceRepository {
  final List<ServiceRecord> _services = List.from(MockData.services);

  /// Ambil semua servis.
  List<ServiceRecord> getAll() {
    return List.unmodifiable(_services);
  }

  /// Ambil servis untuk satu jam tangan.
  List<ServiceRecord> getByWatch(String watchId) {
    return _services
        .where((s) => s.watchId == watchId)
        .toList()
      ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
  }

  /// Tambah catatan servis.
  ServiceRecord add(ServiceRecord service) {
    final newService = ServiceRecord(
      id: IdGenerator.generate('s'),
      watchId: service.watchId,
      serviceDate: service.serviceDate,
      serviceType: service.serviceType,
      description: service.description,
      cost: service.cost,
      nextServiceDate: service.nextServiceDate,
    );
    _services.add(newService);
    return newService;
  }

  /// Hapus catatan servis.
  bool delete(String id) {
    final idx = _services.indexWhere((s) => s.id == id);
    if (idx == -1) return false;
    _services.removeAt(idx);
    return true;
  }

  /// Ambil servis yang nextServiceDate mendekati jatuh tempo (≤ 7 hari).
  List<ServiceRecord> getUpcomingService({int days = 7}) {
    final now = DateTime.now();
    return _services.where((s) {
      if (s.nextServiceDate == null) return false;
      final diff = s.nextServiceDate!.difference(now).inDays;
      return diff >= 0 && diff <= days;
    }).toList()
      ..sort((a, b) {
        final aDate = a.nextServiceDate!;
        final bDate = b.nextServiceDate!;
        return aDate.compareTo(bDate);
      });
  }
}
