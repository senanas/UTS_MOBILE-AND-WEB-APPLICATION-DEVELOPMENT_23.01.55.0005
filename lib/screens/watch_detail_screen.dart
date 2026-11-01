import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/status_badge.dart';
import 'watch_form_screen.dart';
import 'service_history_screen.dart';
import 'transaction_form_screen.dart';

class WatchDetailScreen extends StatelessWidget {
  final String watchId;

  const WatchDetailScreen({super.key, required this.watchId});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final watchProv = context.watch<WatchProvider>();
    final watch = watchProv.getById(watchId);

    if (watch == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final isAdmin = auth.isAdmin;

    return Scaffold(
      appBar: AppBar(
        title: Text(watch.name),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WatchFormScreen(watch: watch),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: watch.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      child: Image.network(
                        watch.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.watch,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.watch,
                      size: 64,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            // Status badges
            Wrap(
              spacing: AppSizes.spacingSm,
              runSpacing: AppSizes.spacingSm,
              children: [
                StatusBadge.stock(watch.stock),
                StatusBadge.warranty(watch.warrantyStatus),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.tintPurple,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Text(
                    watch.movementType.label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onTintPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),
            // Nama & harga
            Text(
              watch.name,
              style: const TextStyle(
                fontSize: AppSizes.title,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppDateUtils.formatCurrency(watch.price),
              style: const TextStyle(
                fontSize: AppSizes.subtitle,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            // Spesifikasi
            const Text(
              'Spesifikasi',
              style: TextStyle(
                fontSize: AppSizes.subtitle,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            _SpecRow(label: 'Merek', value: watch.brand),
            _SpecRow(label: 'Model', value: watch.model),
            _SpecRow(label: 'Tipe Mesin', value: watch.movementType.label),
            _SpecRow(label: 'Nomor Seri', value: watch.serialNumber),
            _SpecRow(label: 'Stok', value: '${watch.stock} unit'),
            if (watch.warrantyStart != null && watch.warrantyEnd != null) ...[
              const SizedBox(height: AppSizes.spacingLg),
              const Text(
                'Garansi',
                style: TextStyle(
                  fontSize: AppSizes.subtitle,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              _SpecRow(label: 'Mulai', value: AppDateUtils.formatDate(watch.warrantyStart!)),
              _SpecRow(label: 'Berakhir', value: AppDateUtils.formatDate(watch.warrantyEnd!)),
            ],
            const SizedBox(height: AppSizes.spacingXl),
            // Tombol aksi
            if (isAdmin)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceHistoryScreen(watchId: watch.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.build_outlined, size: 20),
                  label: const Text(AppConstants.btnRecordService),
                ),
              ),
            if (!isAdmin && !watch.isOutOfStock)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionFormScreen(watch: watch),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                  label: const Text(AppConstants.btnOrder),
                ),
              ),
            if (!isAdmin && watch.isOutOfStock)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.block, size: 20),
                  label: const Text('Stok Habis'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppSizes.caption,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: AppSizes.caption,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
