/// Tipe mesin jam tangan.
enum WatchType {
  automatic,
  quartz,
  solar;

  String get label {
    switch (this) {
      case WatchType.automatic:
        return 'Automatic';
      case WatchType.quartz:
        return 'Quartz';
      case WatchType.solar:
        return 'Solar';
    }
  }
}

/// Status garansi.
enum WarrantyStatus {
  active,
  expiringSoon,
  expired,
  none;

  String get label {
    switch (this) {
      case WarrantyStatus.active:
        return 'Garansi Aktif';
      case WarrantyStatus.expiringSoon:
        return 'Garansi Akan Berakhir';
      case WarrantyStatus.expired:
        return 'Garansi Berakhir';
      case WarrantyStatus.none:
        return 'Tanpa Garansi';
    }
  }
}

/// Model jam tangan.
class Watch {
  final String id;
  final String name;
  final String brand;
  final String model;
  final WatchType movementType;
  final int price;
  final int stock;
  final String serialNumber;
  final String? imageUrl;
  final DateTime? warrantyStart;
  final DateTime? warrantyEnd;
  final DateTime createdAt;

  Watch({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.movementType,
    required this.price,
    required this.stock,
    required this.serialNumber,
    this.imageUrl,
    this.warrantyStart,
    this.warrantyEnd,
    required this.createdAt,
  });

  Watch copyWith({
    String? id,
    String? name,
    String? brand,
    String? model,
    WatchType? movementType,
    int? price,
    int? stock,
    String? serialNumber,
    String? imageUrl,
    DateTime? warrantyStart,
    DateTime? warrantyEnd,
    DateTime? createdAt,
  }) {
    return Watch(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      movementType: movementType ?? this.movementType,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      serialNumber: serialNumber ?? this.serialNumber,
      imageUrl: imageUrl ?? this.imageUrl,
      warrantyStart: warrantyStart ?? this.warrantyStart,
      warrantyEnd: warrantyEnd ?? this.warrantyEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Hitung status garansi berdasarkan tanggal saat ini.
  WarrantyStatus get warrantyStatus {
    if (warrantyEnd == null) return WarrantyStatus.none;
    final now = DateTime.now();
    if (now.isAfter(warrantyEnd!)) return WarrantyStatus.expired;
    final diff = warrantyEnd!.difference(now).inDays;
    if (diff <= 7) return WarrantyStatus.expiringSoon;
    return WarrantyStatus.active;
  }

  /// Apakah stok habis?
  bool get isOutOfStock => stock <= 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'model': model,
      'movementType': movementType.name,
      'price': price,
      'stock': stock,
      'serialNumber': serialNumber,
      'imageUrl': imageUrl,
      'warrantyStart': warrantyStart?.toIso8601String(),
      'warrantyEnd': warrantyEnd?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Watch.fromMap(Map<String, dynamic> map) {
    return Watch(
      id: map['id'] as String,
      name: map['name'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      movementType: WatchType.values.firstWhere(
        (e) => e.name == map['movementType'],
        orElse: () => WatchType.quartz,
      ),
      price: map['price'] as int,
      stock: map['stock'] as int,
      serialNumber: map['serialNumber'] as String,
      imageUrl: map['imageUrl'] as String?,
      warrantyStart: map['warrantyStart'] != null
          ? DateTime.parse(map['warrantyStart'] as String)
          : null,
      warrantyEnd: map['warrantyEnd'] != null
          ? DateTime.parse(map['warrantyEnd'] as String)
          : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
