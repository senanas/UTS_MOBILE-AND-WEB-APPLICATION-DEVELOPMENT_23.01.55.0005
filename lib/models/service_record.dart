/// Jenis servis jam tangan.
enum ServiceType {
  routine,
  minor,
  major;

  String get label {
    switch (this) {
      case ServiceType.routine:
        return 'Servis Ringan';
      case ServiceType.minor:
        return 'Servis Berkala';
      case ServiceType.major:
        return 'Servis Besar';
    }
  }
}

/// Model catatan riwayat servis.
class ServiceRecord {
  final String id;
  final String watchId;
  final DateTime serviceDate;
  final ServiceType serviceType;
  final String description;
  final int? cost;
  final DateTime? nextServiceDate;

  ServiceRecord({
    required this.id,
    required this.watchId,
    required this.serviceDate,
    required this.serviceType,
    required this.description,
    this.cost,
    this.nextServiceDate,
  });

  ServiceRecord copyWith({
    String? id,
    String? watchId,
    DateTime? serviceDate,
    ServiceType? serviceType,
    String? description,
    int? cost,
    DateTime? nextServiceDate,
  }) {
    return ServiceRecord(
      id: id ?? this.id,
      watchId: watchId ?? this.watchId,
      serviceDate: serviceDate ?? this.serviceDate,
      serviceType: serviceType ?? this.serviceType,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      nextServiceDate: nextServiceDate ?? this.nextServiceDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'watchId': watchId,
      'serviceDate': serviceDate.toIso8601String(),
      'serviceType': serviceType.name,
      'description': description,
      'cost': cost,
      'nextServiceDate': nextServiceDate?.toIso8601String(),
    };
  }

  factory ServiceRecord.fromMap(Map<String, dynamic> map) {
    return ServiceRecord(
      id: map['id'] as String,
      watchId: map['watchId'] as String,
      serviceDate: DateTime.parse(map['serviceDate'] as String),
      serviceType: ServiceType.values.firstWhere(
        (e) => e.name == map['serviceType'],
        orElse: () => ServiceType.routine,
      ),
      description: map['description'] as String,
      cost: map['cost'] as int?,
      nextServiceDate: map['nextServiceDate'] != null
          ? DateTime.parse(map['nextServiceDate'] as String)
          : null,
    );
  }
}
