import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/watch.dart';
import '../providers/watch_provider.dart';
import '../providers/service_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';
import 'watch_detail_screen.dart';
import 'service_history_screen.dart';

class ReminderScreen extends StatelessWidget {
  final int navIndex;
  final ValueChanged<int> onNavTap;

  const ReminderScreen({
    super.key,
    required this.navIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final watchProv = context.watch<WatchProvider>();
    final serviceProv = context.watch<ServiceProvider>();

    final watches = watchProv.all;
    final upcomingServices = serviceProv.upcomingService;

    // Garansi mendekati jatuh tempo atau sudah lewat
    final warrantyReminders = watches
        .where((w) {
          final status = w.warrantyStatus;
          return status == WarrantyStatus.expiringSoon || status == WarrantyStatus.expired;
        })
        .toList()
      ..sort((a, b) {
        final aDate = a.warrantyEnd!;
        final bDate = b.warrantyEnd!;
        return aDate.compareTo(bDate);
      });

    final isEmpty = warrantyReminders.isEmpty && upcomingServices.isEmpty;

    return AppScaffold(
      title: AppConstants.navReminder,
      currentIndex: navIndex,
      onNavTap: onNavTap,
      body: isEmpty
          ? EmptyState(
              icon: Icons.notifications_none,
              message: AppConstants.emptyReminders,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              children: [
                if (warrantyReminders.isNotEmpty) ...[
                  const Text(
                    'Garansi',
                    style: TextStyle(
                      fontSize: AppSizes.subtitle,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  ...warrantyReminders.map((w) => Card(
                        child: ListTile(
                          leading: const Icon(Icons.shield_outlined, color: AppColors.warning),
                          title: Text(w.name),
                          subtitle: Text(
                            w.warrantyEnd != null
                                ? 'Berakhir: ${AppDateUtils.formatDate(w.warrantyEnd!)} '
                                    '(${AppDateUtils.relativeLabel(w.warrantyEnd!)})'
                                : 'Tanpa garansi',
                          ),
                          trailing: StatusBadge.warranty(w.warrantyStatus),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => WatchDetailScreen(watchId: w.id),
                              ),
                            );
                          },
                        ),
                      )),
                ],
                if (upcomingServices.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.spacingLg),
                  const Text(
                    'Servis terjadwal',
                    style: TextStyle(
                      fontSize: AppSizes.subtitle,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.spacingSm),
                  ...upcomingServices.map((s) {
                    final watch = watchProv.getById(s.watchId);
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.build_outlined, color: AppColors.warning),
                        title: Text(watch?.name ?? 'Jam tangan'),
                        subtitle: Text(
                          '${s.serviceType.label} - '
                          'Jatuh tempo: ${AppDateUtils.formatDate(s.nextServiceDate!)} '
                          '(${AppDateUtils.relativeLabel(s.nextServiceDate!)})',
                        ),
                        trailing: StatusBadge(
                          label: AppDateUtils.relativeLabel(s.nextServiceDate!),
                          color: AppColors.tintAmber,
                          textColor: AppColors.onTintAmber,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceHistoryScreen(watchId: s.watchId),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
