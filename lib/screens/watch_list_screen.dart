import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/theme.dart';
import '../models/watch.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/product_thumbnail.dart';
import 'transaction_form_screen.dart';
import 'watch_detail_screen.dart';
import 'watch_form_screen.dart';

/// Katalog jam tangan ChronoStore.
///
/// Versi ini menampilkan produk dalam grid responsif dengan thumbnail premium
/// ([ProductThumbnail]), informasi harga/stok yang jelas, serta tombol aksi
/// yang berbeda untuk admin dan pelanggan.
class WatchListScreen extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavTap;

  const WatchListScreen({
    super.key,
    required this.navIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final watchProv = context.watch<WatchProvider>();
    final isAdmin = auth.isAdmin;
    final watches = watchProv.watches;
    final isLoading = watchProv.isLoading;

    return AppScaffold(
      title: isAdmin ? AppConstants.navWatchList : 'Katalog Jam Tangan',
      currentIndex: navIndex,
      onNavTap: onNavTap,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WatchFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Jam'),
            )
          : null,
      body: Column(
        children: [
          _CatalogHeader(
            isAdmin: isAdmin,
            total: watches.length,
            query: watchProv.searchQuery,
            onQueryChanged: watchProv.setSearchQuery,
            filterType: watchProv.filterType,
            onFilterChanged: watchProv.setFilterType,
          ),
          Expanded(
            child: isLoading && watches.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : watchProv.error != null && watches.isEmpty
                    ? const EmptyState(
                        icon: Icons.cloud_off,
                        message:
                            'Gagal memuat jam tangan dari Cloud Firestore.\n'
                            'Periksa Rules (request.auth != null) dan koneksi.',
                      )
                    : watches.isEmpty
                        ? EmptyState(
                            icon: Icons.watch_off_outlined,
                            message: watchProv.searchQuery.isNotEmpty
                                ? 'Tidak ada jam tangan yang cocok dengan '
                                    '"${watchProv.searchQuery}"'
                                : AppConstants.emptyWatches,
                            actionLabel:
                                isAdmin ? AppConstants.btnAddWatch : null,
                            onAction: isAdmin
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const WatchFormScreen(),
                                      ),
                                    )
                                : null,
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth;
                              final cols = width >= 1200
                                  ? 4
                                  : width >= 860
                                      ? 3
                                      : width >= 560
                                          ? 2
                                          : 1;
                              return GridView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  AppSizes.screenPadding,
                                  AppSizes.spacingSm,
                                  AppSizes.screenPadding,
                                  AppSizes.spacingXl,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: cols,
                                  crossAxisSpacing: AppSizes.spacingMd,
                                  mainAxisSpacing: AppSizes.spacingMd,
                                  childAspectRatio: cols == 1
                                      ? 1.5
                                      : cols == 2
                                          ? 0.92
                                          : 0.82,
                                ),
                                itemCount: watches.length,
                                itemBuilder: (context, index) {
                                  final watch = watches[index];
                                  return _CatalogCard(
                                    watch: watch,
                                    isAdmin: isAdmin,
                                    onDetail: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WatchDetailScreen(
                                            watchId: watch.id),
                                      ),
                                    ),
                                    onBuy: watch.isOutOfStock
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    TransactionFormScreen(
                                                        watch: watch),
                                              ),
                                            ),
                                    onEdit: isAdmin
                                        ? () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => WatchFormScreen(
                                                    watch: watch),
                                              ),
                                            )
                                        : null,
                                    onDelete: isAdmin
                                        ? () => _confirmDelete(
                                            context, watchProv, watch)
                                        : null,
                                  );
                                },
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WatchProvider prov,
    Watch watch,
  ) async {
    final hapus = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jam tangan?'),
        content: Text('Yakin ingin menghapus "${watch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppConstants.btnCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (hapus != true || !context.mounted) return;

    try {
      await prov.delete(watch.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${watch.name} dihapus dari Firestore'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus. Periksa Security Rules.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// ============================================================ HEADER
class _CatalogHeader extends StatelessWidget {
  final bool isAdmin;
  final int total;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final WatchType? filterType;
  final ValueChanged<WatchType?> onFilterChanged;

  const _CatalogHeader({
    required this.isAdmin,
    required this.total,
    required this.query,
    required this.onQueryChanged,
    required this.filterType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPadding,
        AppSizes.spacingMd,
        AppSizes.screenPadding,
        AppSizes.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.primaryDark),
                ),
                child: const Icon(Icons.watch,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdmin ? 'Data Jam Tangan' : 'Koleksi Jam Tangan',
                      style: const TextStyle(
                        fontSize: AppSizes.subtitle,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$total jam tangan tersedia di Firestore',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AppColors.tintAmber
                              : AppColors.tintBlue,
                          borderRadius:
                              BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.primaryDark),
                        ),
                        child: Text(
                          isAdmin
                              ? 'ADMIN — kelola produk'
                              : 'PELANGGAN — beli produk',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isAdmin
                                ? AppColors.onTintAmber
                                : AppColors.onTintBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (query.isNotEmpty || filterType != null)
                TextButton.icon(
                  onPressed: () {
                    onQueryChanged('');
                    onFilterChanged(null);
                  },
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingMd),
          TextField(
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Cari nama atau brand jam tangan...',
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      color: AppColors.textSecondary,
                      onPressed: () => onQueryChanged(''),
                    ),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _FilterChip(
                  label: 'Semua',
                  selected: filterType == null,
                  onTap: () => onFilterChanged(null),
                ),
                ...WatchType.values.map(
                  (type) => _FilterChip(
                    label: type.label,
                    selected: filterType == type,
                    onTap: () => onFilterChanged(type),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.spacingSm),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primaryLight,
        checkmarkColor: AppColors.primary,
        side: BorderSide(
          color: selected ? AppColors.primaryDark : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontSize: 12,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ============================================================ PRODUCT CARD
class _CatalogCard extends StatelessWidget {
  final Watch watch;
  final bool isAdmin;
  final VoidCallback onDetail;
  final VoidCallback? onBuy;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CatalogCard({
    required this.watch,
    required this.isAdmin,
    required this.onDetail,
    this.onBuy,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: ProductThumbnail(
                      watch: watch,
                      height: double.infinity,
                    ),
                  ),
                  if (isAdmin)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: PopupMenuButton<String>(
                        icon: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusMd),
                          ),
                          child: const Icon(Icons.more_vert,
                              color: Colors.white, size: 18),
                        ),
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                              value: 'delete', child: Text('Hapus')),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watch.brand.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    watch.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppSizes.caption,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    watch.model,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingXs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          AppDateUtils.formatCurrency(watch.price),
                          style: const TextStyle(
                            fontSize: AppSizes.caption,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        watch.isOutOfStock
                            ? 'Stok habis'
                            : 'Stok ${watch.stock}',
                        style: TextStyle(
                          fontSize: 11,
                          color: watch.isOutOfStock
                              ? AppColors.onTintRed
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    // Admin fokus mengelola (tombol ini membuka form edit);
                    // pelanggan langsung memesan. Admin tetap bisa memesan
                    // lewat halaman detail produk.
                    child: isAdmin && onEdit != null
                        ? ElevatedButton.icon(
                            onPressed: onEdit,
                            icon: const Icon(Icons.edit_outlined, size: 15),
                            label: const Text('Kelola Produk',
                                style: TextStyle(fontSize: 12)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : onBuy != null
                            ? ElevatedButton.icon(
                                onPressed: onBuy,
                                icon: const Icon(Icons.shopping_cart_outlined,
                                    size: 15),
                                label: const Text('Beli Sekarang',
                                    style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                ),
                              )
                            : OutlinedButton.icon(
                                onPressed: onDetail,
                                icon: const Icon(Icons.visibility_outlined,
                                    size: 15),
                                label: const Text('Lihat Detail',
                                    style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 34),
                                ),
                              ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
