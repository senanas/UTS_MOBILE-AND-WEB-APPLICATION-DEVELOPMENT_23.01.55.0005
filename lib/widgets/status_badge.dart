import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/watch.dart';

/// Badge status untuk garansi, stok, dan servis.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
  });

  factory StatusBadge.warranty(WarrantyStatus status) {
    Color bg;
    Color text;
    switch (status) {
      case WarrantyStatus.active:
        bg = const Color(0xFFE1F5EE);
        text = const Color(0xFF085041);
      case WarrantyStatus.expiringSoon:
        bg = const Color(0xFFFAEEDA);
        text = const Color(0xFF854F0B);
      case WarrantyStatus.expired:
        bg = const Color(0xFFFCEBEB);
        text = const Color(0xFF791F1F);
      case WarrantyStatus.none:
        bg = const Color(0xFFF1EFE8);
        text = const Color(0xFF666666);
    }
    return StatusBadge(label: status.label, color: bg, textColor: text);
  }

  factory StatusBadge.stock(int stock) {
    if (stock <= 0) {
      return const StatusBadge(
        label: 'Stok Habis',
        color: Color(0xFFFCEBEB),
        textColor: Color(0xFF791F1F),
      );
    } else if (stock <= 3) {
      return const StatusBadge(
        label: 'Stok Menipis',
        color: Color(0xFFFAEEDA),
        textColor: Color(0xFF854F0B),
      );
    }
    return const StatusBadge(
      label: 'Tersedia',
      color: Color(0xFFE1F5EE),
      textColor: Color(0xFF085041),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.textPrimary,
        ),
      ),
    );
  }
}
