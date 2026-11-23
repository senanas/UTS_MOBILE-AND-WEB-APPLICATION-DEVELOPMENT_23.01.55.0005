import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/watch.dart';

/// Gambar produk jam tangan yang menarik tanpa bergantung pada file aset.
///
/// Bila [Watch.imageUrl] tersedia, gambar jaringan dipakai. Jika tidak
/// (kasus data awal), tampilkan ilustrasi jam dengan gradasi emas khas
/// ChronoStore + pola lingkaran agar kartu tetap terlihat premium.
class ProductThumbnail extends StatelessWidget {
  final Watch watch;
  final double height;
  final bool showStockBadge;

  const ProductThumbnail({
    super.key,
    required this.watch,
    this.height = 140,
    this.showStockBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: watch.isOutOfStock
                ? [AppColors.surfaceAlt, AppColors.tintNeutral]
                : [AppColors.primaryLight, AppColors.surfaceAlt],
          ),
        ),
        child: Stack(
          children: [
            // Pola dekoratif lingkaran
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 18),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -40,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
            // Gambar atau ikon jam
            Center(
              child: watch.imageUrl != null
                  ? Image.network(
                      watch.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: height,
                      errorBuilder: (_, __, ___) => _buildIcon(),
                    )
                  : _buildIcon(),
            ),
            // Badge stok
            if (showStockBadge)
              Positioned(
                top: AppSizes.spacingSm,
                right: AppSizes.spacingSm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: watch.isOutOfStock
                        ? AppColors.tintRed
                        : AppColors.tintGreen,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    watch.isOutOfStock
                        ? 'HABIS'
                        : watch.stock <= 3
                            ? 'SISA ${watch.stock}'
                            : 'TERSEDIA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: watch.isOutOfStock
                          ? AppColors.onTintRed
                          : AppColors.onTintGreen,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.watch,
      size: height * 0.5,
      color: watch.isOutOfStock
          ? AppColors.textHint
          : AppColors.primary.withValues(alpha: 0.8),
    );
  }
}
