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
  });

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
    );
  }
}
