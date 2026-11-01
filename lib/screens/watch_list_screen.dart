import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/watch.dart';
import '../providers/auth_provider.dart';
import '../providers/watch_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/watch_card.dart';
import '../widgets/empty_state.dart';
import 'watch_form_screen.dart';
import 'watch_detail_screen.dart';

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

    return AppScaffold(
      title: isAdmin ? AppConstants.navWatchList : 'Katalog',
      currentIndex: navIndex,
      onNavTap: onNavTap,
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WatchFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      body: Column(
        children: [
          // Search + filter bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari jam tangan...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) => watchProv.setSearchQuery(value),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: watchProv.filterType == null,
                        onTap: () => watchProv.setFilterType(null),
                      ),
                      ...WatchType.values.map((type) => _FilterChip(
                            label: type.label,
                            selected: watchProv.filterType == type,
                            onTap: () => watchProv.setFilterType(type),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List / grid
          Expanded(
            child: watches.isEmpty
                ? EmptyState(
                    icon: Icons.watch_off_outlined,
                    message: AppConstants.emptyWatches,
                    actionLabel: isAdmin ? AppConstants.btnAddWatch : null,
                    onAction: isAdmin
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const WatchFormScreen()),
                            )
                        : null,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.spacingLg,
                      left: AppSizes.screenPadding,
                      right: AppSizes.screenPadding,
                    ),
                    itemCount: watches.length,
                    itemBuilder: (context, index) {
                      final watch = watches[index];
                      return WatchCard(
                        watch: watch,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WatchDetailScreen(watchId: watch.id),
                            ),
                          );
                        },
                        onEdit: isAdmin
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => WatchFormScreen(watch: watch),
                                  ),
                                );
                              }
                            : null,
                        onDelete: isAdmin
                            ? () => _confirmDelete(context, watchProv, watch)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WatchProvider prov, Watch watch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus jam tangan?'),
        content: Text('Yakin ingin menghapus "${watch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(AppConstants.btnCancel),
          ),
          TextButton(
            onPressed: () {
              prov.delete(watch.id);
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${watch.name} dihapus'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Hapus'),
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
        labelStyle: TextStyle(
          color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          fontSize: 13,
          fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
        ),
      ),
    );
  }
}
