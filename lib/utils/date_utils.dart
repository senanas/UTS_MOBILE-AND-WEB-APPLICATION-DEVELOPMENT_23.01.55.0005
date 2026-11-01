import 'package:intl/intl.dart';

/// Utilitas format tanggal & angka.
class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String formatCurrency(int amount) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return format.format(amount);
  }

  /// Hitung jumlah hari sampai tanggal target.
  /// Negatif = sudah lewat.
  static int daysUntil(DateTime target) {
    final now = DateTime.now();
    final cleanNow = DateTime(now.year, now.month, now.day);
    final cleanTarget = DateTime(target.year, target.month, target.day);
    return cleanTarget.difference(cleanNow).inDays;
  }

  /// Label relatif: "3 hari lagi", "2 hari lalu", "Hari ini".
  static String relativeLabel(DateTime target) {
    final diff = daysUntil(target);
    if (diff == 0) return 'Hari ini';
    if (diff > 0) return '$diff hari lagi';
    return '${-diff} hari lalu';
  }
}
