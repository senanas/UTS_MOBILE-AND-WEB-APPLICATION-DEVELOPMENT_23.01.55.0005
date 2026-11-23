/// Status transaksi.
enum TransactionStatus {
  pending,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'Menunggu';
      case TransactionStatus.completed:
        return 'Selesai';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

/// Model transaksi/pesanan.
///
/// Selain data produk, menyimpan data checkout pelanggan (nama, email,
/// telepon, alamat pengiriman, dan catatan) supaya bisa ditampilkan ulang
/// pada halaman Transaksi. Field baru bersifat opsional agar transaksi lama
/// di Firestore tetap terbaca (backward compatible).
class Transaction {
  final String id;
  final String watchId;
  final String watchName;
  final int quantity;
  final int unitPrice;
  final int totalPrice;
  final DateTime transactionDate;
  final String customerName;
  final String userId;
  final TransactionStatus status;

  /// Waktu dokumen dibuat di Firestore (`dibuat_pada`, serverTimestamp).
  /// Dipakai untuk mengurutkan transaksi terbaru di sisi Dart.
  /// Null untuk data lama / data dari penyimpanan lokal.
  final DateTime? createdAt;

  // ----- Data checkout -----
  final String customerEmail;
  final String customerPhone;
  final String shippingAddress;
  final String shippingCity;
  final String postalCode;
  final String notes;

  /// Ongkos kirim yang dipilih saat checkout.
  final int shippingCost;

  /// True bila pesanan hanya tersimpan di perangkat karena Firestore menolak
  /// tulis (Rules belum publish / offline). Dipakai badge di halaman riwayat.
  final bool tersimpanLokal;

  Transaction({
    required this.id,
    required this.watchId,
    required this.watchName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.transactionDate,
    required this.customerName,
    required this.userId,
    required this.status,
    this.createdAt,
    this.customerEmail = '',
    this.customerPhone = '',
    this.shippingAddress = '',
    this.shippingCity = '',
    this.postalCode = '',
    this.notes = '',
    this.shippingCost = 0,
    this.tersimpanLokal = false,
  });

  /// Alamat lengkap satu baris untuk ditampilkan di UI.
  String get alamatLengkap {
    final bagian = <String>[
      shippingAddress,
      if (shippingCity.isNotEmpty) shippingCity,
      if (postalCode.isNotEmpty) postalCode,
    ];
    return bagian.where((s) => s.trim().isNotEmpty).join(', ');
  }

  Transaction copyWith({
    String? id,
    String? watchId,
    String? watchName,
    int? quantity,
    int? unitPrice,
    int? totalPrice,
    DateTime? transactionDate,
    String? customerName,
    String? userId,
    TransactionStatus? status,
    DateTime? createdAt,
    String? customerEmail,
    String? customerPhone,
    String? shippingAddress,
    String? shippingCity,
    String? postalCode,
    String? notes,
    int? shippingCost,
    bool? tersimpanLokal,
  }) {
    return Transaction(
      id: id ?? this.id,
      watchId: watchId ?? this.watchId,
      watchName: watchName ?? this.watchName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      transactionDate: transactionDate ?? this.transactionDate,
      customerName: customerName ?? this.customerName,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      shippingCity: shippingCity ?? this.shippingCity,
      postalCode: postalCode ?? this.postalCode,
      notes: notes ?? this.notes,
      shippingCost: shippingCost ?? this.shippingCost,
      tersimpanLokal: tersimpanLokal ?? this.tersimpanLokal,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'watchId': watchId,
      'watchName': watchName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'transactionDate': transactionDate.toIso8601String(),
      'customerName': customerName,
      'userId': userId,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'shippingAddress': shippingAddress,
      'shippingCity': shippingCity,
      'postalCode': postalCode,
      'notes': notes,
      'shippingCost': shippingCost,
      'tersimpanLokal': tersimpanLokal,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'] as String,
      watchId: map['watchId'] as String,
      watchName: map['watchName'] as String,
      quantity: map['quantity'] as int,
      unitPrice: map['unitPrice'] as int,
      totalPrice: map['totalPrice'] as int,
      transactionDate: DateTime.parse(map['transactionDate'] as String),
      customerName: map['customerName'] as String,
      userId: map['userId'] as String,
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => TransactionStatus.pending,
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String)
          : null,
      customerEmail: map['customerEmail'] as String? ?? '',
      customerPhone: map['customerPhone'] as String? ?? '',
      shippingAddress: map['shippingAddress'] as String? ?? '',
      shippingCity: map['shippingCity'] as String? ?? '',
      postalCode: map['postalCode'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      shippingCost: (map['shippingCost'] as num?)?.toInt() ?? 0,
      tersimpanLokal: map['tersimpanLokal'] as bool? ?? false,
    );
  }
}
