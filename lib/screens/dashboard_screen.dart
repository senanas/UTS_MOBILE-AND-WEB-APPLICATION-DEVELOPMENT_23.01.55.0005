import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/user_account.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_provider.dart';
import '../providers/service_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/watch_card.dart';
import 'watch_form_screen.dart';
import 'transaction_screen.dart';

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
    final user = auth.currentUser!;

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
          onSelected: (value) {
            if (value == 'logout') {
              auth.logout();
            } else if (value == 'transactions') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TransactionScreen()),
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'transactions', child: Text('Transaksi')),
            const PopupMenuDivider(),
            const PopupMenuItem(value: 'logout', child: Text('Keluar')),
          ],
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.account_circle, color: AppColors.textHint),
          ),
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat datang, ${user.name}',
              style: const TextStyle(
                fontSize: AppSizes.subtitle,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.role == UserRole.admin
                  ? 'Ringkasan toko jam tangan Anda'
                  : 'Jelajahi koleksi jam tangan kami',
              style: const TextStyle(
                fontSize: AppSizes.caption,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            // Admin: kartu ringkasan
            if (user.role == UserRole.admin) ...[
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: AppSizes.spacingSm,
                mainAxisSpacing: AppSizes.spacingSm,
                childAspectRatio: 1.3,
                children: [
                  _SummaryCard(
                    icon: Icons.watch,
                    label: 'Total Jam',
                    value: '${watchProv.totalWatches}',
                    color: const Color(0xFFE6F1FB),
                    iconColor: const Color(0xFF185FA5),
                  ),
                  _SummaryCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Total Stok',
                    value: '${watchProv.totalStock}',
                    color: const Color(0xFFE1F5EE),
                    iconColor: const Color(0xFF0F6E56),
                  ),
                  _SummaryCard(
                    icon: Icons.shield_outlined,
                    label: 'Garansi Aktif',
                    value: '${watchProv.activeWarrantyCount}',
                    color: const Color(0xFFFAEEDA),
                    iconColor: const Color(0xFF854F0B),
                  ),
                  _SummaryCard(
                    icon: Icons.warning_amber,
                    label: 'Stok Habis',
                    value: '${watchProv.outOfStockCount}',
                    color: const Color(0xFFFCEBEB),
                    iconColor: const Color(0xFF791F1F),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const WatchFormScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text(AppConstants.btnAddWatch),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingSm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TransactionScreen()),
                        );
                      },
                      icon: const Icon(Icons.receipt_long_outlined, size: 20),
                      label: const Text('Transaksi'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMd),
              if (serviceProv.upcomingService.isNotEmpty) ...[
                const Text(
                  'Pengingat servis terdekat',
                  style: TextStyle(
                    fontSize: AppSizes.subtitle,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                ...serviceProv.upcomingService.take(3).map((s) {
                  final watch = watchProv.getById(s.watchId);
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.build_outlined, color: AppColors.warning),
                      title: Text(watch?.name ?? 'Jam tangan'),
                      subtitle: Text(
                        '${s.serviceType.label} - '
                        'Servis berikutnya: ${_fmtDate(s.nextServiceDate!)}',
                      ),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textHint),
                      onTap: () => onNavTap(2),
                    ),
                  );
                }),
                const SizedBox(height: AppSizes.spacingSm),
                TextButton(
                  onPressed: () => onNavTap(2),
                  child: const Text('Lihat semua pengingat'),
                ),
              ],
            ],
            // Pelanggan: katalog singkat + transaksi
            if (user.role == UserRole.customer) ...[
              const Text(
                'Jam tangan tersedia',
                style: TextStyle(
                  fontSize: AppSizes.subtitle,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              ...watchProv.watches.take(3).map((w) => WatchCard(
                    watch: w,
                    onTap: () {
                      onNavTap(1);
                    },
                  )),
              const SizedBox(height: AppSizes.spacingSm),
              TextButton(
                onPressed: () => onNavTap(1),
                child: const Text('Lihat semua jam tangan'),
              ),
              const SizedBox(height: AppSizes.spacingLg),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionScreen()),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 20),
                label: const Text('Transaksi saya'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmtDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color iconColor;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: iconColor),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: AppSizes.title,
              fontWeight: FontWeight.w500,
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
