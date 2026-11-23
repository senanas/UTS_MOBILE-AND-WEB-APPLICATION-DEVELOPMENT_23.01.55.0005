import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../app/constants.dart';
import '../models/user_account.dart';
import '../models/watch.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_provider.dart';
import '../providers/service_provider.dart';
import '../services/layanan_chronostore.dart';
import '../utils/date_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/product_thumbnail.dart';
import 'watch_form_screen.dart';
import 'transaction_form_screen.dart';
import 'riwayat_transaksi_screen.dart';

class DashboardScreen extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavTap;

  const DashboardScreen({
    super.key,
    required this.navIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final watchProv = context.watch<WatchProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final layanan = context.read<LayananChronoStore>();
    final user = auth.currentUser!;
    final lebar = MediaQuery.of(context).size.width;
    final isWide = lebar >= 600;

    return AppScaffold(
      title: AppConstants.appName,
      currentIndex: navIndex,
      onNavTap: onNavTap,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSizes.spacingSm),
          child: Center(
            child: Text(
              '${user.name} (${user.role.label})',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'logout') {
              await auth.logout();
              return;
            }
            if (value == 'transactions') {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const RiwayatTransaksiScreen()),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'transactions',
                child: Row(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Transaksi'),
                  ],
                )),
            const PopupMenuDivider(),
            const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Keluar'),
                  ],
                )),
          ],
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HERO BANNER =====
            _HeroBanner(isAdmin: user.role == UserRole.admin, isWide: isWide),

            Padding(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sapaan
                  StreamBuilder<UserAccount?>(
                    stream: layanan.streamProfil(user.id),
                    initialData: user,
                    builder: (context, snapshot) {
                      final nama = snapshot.data?.name ?? user.name;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, $nama 👋',
                            style: const TextStyle(
                              fontSize: AppSizes.title,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.role == UserRole.admin
                                ? 'Kelola toko dan pantau penjualan Anda hari ini.'
                                : 'Temukan jam tangan impian Anda di koleksi terbaru kami.',
                            style: const TextStyle(
                              fontSize: AppSizes.caption,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSizes.spacingLg),

                  // ===== ADMIN CONTENT =====
                  if (user.role == UserRole.admin) ...[
                    _SectionTitle(
                        icon: Icons.bar_chart, title: 'Ringkasan Toko'),
                    const SizedBox(height: AppSizes.spacingSm),
                    GridView.count(
                      crossAxisCount: isWide ? 4 : 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: AppSizes.spacingMd,
                      mainAxisSpacing: AppSizes.spacingMd,
                      childAspectRatio: isWide ? 1.3 : 1.15,
                      children: [
                        _SummaryCard(
                          icon: Icons.watch,
                          label: 'Total Jam',
                          value: '${watchProv.totalWatches}',
                          iconColor: AppColors.onTintBlue,
                          tint: AppColors.tintBlue,
                        ),
                        _SummaryCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Total Stok',
                          value: '${watchProv.totalStock}',
                          iconColor: AppColors.onTintGreen,
                          tint: AppColors.tintGreen,
                        ),
                        _SummaryCard(
                          icon: Icons.shield_outlined,
                          label: 'Garansi Aktif',
                          value: '${watchProv.activeWarrantyCount}',
                          iconColor: AppColors.onTintAmber,
                          tint: AppColors.tintAmber,
                        ),
                        _SummaryCard(
                          icon: Icons.warning_amber,
                          label: 'Stok Habis',
                          value: '${watchProv.outOfStockCount}',
                          iconColor: AppColors.onTintRed,
                          tint: AppColors.tintRed,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const WatchFormScreen()),
                            ),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text(AppConstants.btnAddWatch),
                          ),
                        ),
                        const SizedBox(width: AppSizes.spacingSm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      const RiwayatTransaksiScreen()),
                            ),
                            icon: const Icon(Icons.receipt_long_outlined,
                                size: 20),
                            label: const Text('Transaksi'),
                          ),
                        ),
                      ],
                    ),
                    if (serviceProv.upcomingService.isNotEmpty) ...[
                      const SizedBox(height: AppSizes.spacingLg),
                      _SectionTitle(
                          icon: Icons.build_outlined,
                          title: 'Pengingat servis terdekat'),
                      const SizedBox(height: AppSizes.spacingSm),
                      ...serviceProv.upcomingService.take(3).map((s) {
                        final watch = watchProv.getById(s.watchId);
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.tintAmber,
                              child: Icon(Icons.build_outlined,
                                  color: AppColors.warning, size: 18),
                            ),
                            title: Text(watch?.name ?? 'Jam tangan'),
                            subtitle: Text(
                              '${s.serviceType.label} • Servis berikutnya: '
                              '${AppDateUtils.formatDate(s.nextServiceDate!)}',
                            ),
                            onTap: () => onNavTap(2),
                          ),
                        );
                      }),
                    ],
                  ],

                  // ===== CUSTOMER CONTENT =====
                  if (user.role == UserRole.customer) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const _SectionTitle(
                            icon: Icons.auto_awesome,
                            title: 'Pilihan Terbaik Untukmu'),
                        TextButton(
                          onPressed: () => onNavTap(1),
                          child: const Text('Lihat semua'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.spacingSm),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cols = constraints.maxWidth >= 900
                            ? 3
                            : constraints.maxWidth >= 600
                                ? 2
                                : 1;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: cols,
                            crossAxisSpacing: AppSizes.spacingMd,
                            mainAxisSpacing: AppSizes.spacingMd,
                            childAspectRatio: cols == 1 ? 1.45 : 1.05,
                          ),
                          itemCount:
                              watchProv.watches.take(6).length,
                          itemBuilder: (context, index) {
                            final w = watchProv.watches.toList()[index];
                            return _ProductCard(
                              watch: w,
                              onTap: () => onNavTap(1),
                              onBuy: !w.isOutOfStock
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              TransactionFormScreen(watch: w),
                                        ),
                                      )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: AppSizes.spacingLg),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RiwayatTransaksiScreen()),
                        ),
                        icon: const Icon(Icons.history, size: 20),
                        label: const Text('Lihat Riwayat Transaksi Saya'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSizes.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================ HERO BANNER
class _HeroBanner extends StatelessWidget {
  final bool isAdmin;
  final bool isWide;

  const _HeroBanner({required this.isAdmin, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.screenPadding,
        vertical: isWide ? AppSizes.spacingXl : AppSizes.spacingLg,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2113),
            Color(0xFF151515),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: AppColors.primaryDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4)),
                  ),
                  child: const Text(
                    '⌚ CHRONOSTORE — TIMEPIECES & STYLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                Text(
                  isAdmin
                      ? 'Kelola Koleksi Jam Tangan Anda'
                      : 'Waktu Berhenti, Gaya Tetap Abadi',
                  style: TextStyle(
                    fontSize: isWide ? 32 : 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  isAdmin
                      ? 'Pantau stok, garansi, dan transaksi dalam satu tempat.'
                      : 'Temukan jam tangan berkualitas dengan harga terbaik. '
                          'Gratis ongkir untuk beberapa wilayah.',
                  style: const TextStyle(
                    fontSize: AppSizes.caption,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: AppSizes.spacingXl),
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.watch,
                size: 100,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================ SECTION TITLE
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppSizes.spacingSm),
        Text(
          title,
          style: const TextStyle(
            fontSize: AppSizes.subtitle,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ============================================================ PRODUCT CARD
class _ProductCard extends StatelessWidget {
  final Watch watch;
  final VoidCallback onTap;
  final VoidCallback? onBuy;

  const _ProductCard({
    required this.watch,
    required this.onTap,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProductThumbnail(watch: watch, height: 110),
            Padding(
              padding: const EdgeInsets.all(AppSizes.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    watch.brand,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppDateUtils.formatCurrency(watch.price),
                    style: const TextStyle(
                      fontSize: AppSizes.caption,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  if (onBuy != null) ...[
                    const SizedBox(height: AppSizes.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      height: 32,
                      child: ElevatedButton.icon(
                        onPressed: onBuy,
                        icon: const Icon(Icons.shopping_cart_outlined,
                            size: 14),
                        label: const Text('Beli',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================ SUMMARY CARD
class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color tint;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 26, color: iconColor),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.title,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
