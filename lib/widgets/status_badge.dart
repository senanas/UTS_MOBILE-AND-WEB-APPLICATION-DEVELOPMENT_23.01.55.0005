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
        bg = AppColors.tintGreen;
        text = AppColors.onTintGreen;
      case WarrantyStatus.expiringSoon:
        bg = AppColors.tintAmber;
        text = AppColors.onTintAmber;
      case WarrantyStatus.expired:
        bg = AppColors.tintRed;
        text = AppColors.onTintRed;
      case WarrantyStatus.none:
        bg = AppColors.tintNeutral;
        text = AppColors.textSecondary;
    }
    return StatusBadge(label: status.label, color: bg, textColor: text);
  }

  factory StatusBadge.stock(int stock) {
    if (stock <= 0) {
      return const StatusBadge(
        label: 'Stok Habis',
        color: AppColors.tintRed,
        textColor: AppColors.onTintRed,
      );
    } else if (stock <= 3) {
      return const StatusBadge(
        label: 'Stok Menipis',
        color: AppColors.tintAmber,
        textColor: AppColors.onTintAmber,
      );
    }
    return const StatusBadge(
      label: 'Tersedia',
      color: AppColors.tintGreen,
      textColor: AppColors.onTintGreen,
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
