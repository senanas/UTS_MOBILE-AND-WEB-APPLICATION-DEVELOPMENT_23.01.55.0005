import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class TransactionScreen extends StatelessWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final txProv = context.watch<TransactionProvider>();

    final transactions = auth.isAdmin
        ? txProv.all
        : txProv.getByUser(auth.currentUser!.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: transactions.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_outlined,
              message: AppConstants.emptyTransactions,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.screenPadding),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.spacingMd,
                    ),
                    title: Text(tx.watchName),
                    subtitle: Text(
                      '${AppDateUtils.formatDate(tx.transactionDate)} - '
                      '${tx.customerName}',
                    ),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppDateUtils.formatCurrency(tx.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                            fontSize: AppSizes.caption,
                          ),
                        ),
                        const SizedBox(height: 2),
                        StatusBadge(
                          label: tx.status.label,
                          color: tx.status == TransactionStatus.completed
                              ? AppColors.tintGreen
                              : tx.status == TransactionStatus.pending
                                  ? AppColors.tintAmber
                                  : AppColors.tintRed,
                          textColor: tx.status == TransactionStatus.completed
                              ? AppColors.onTintGreen
                              : tx.status == TransactionStatus.pending
                                  ? AppColors.onTintAmber
                                  : AppColors.onTintRed,
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.spacingMd,
                          0,
                          AppSizes.spacingMd,
                          AppSizes.spacingMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DetailRow(label: 'Jam Tangan', value: tx.watchName),
                            _DetailRow(label: 'Jumlah', value: '${tx.quantity} unit'),
                            _DetailRow(label: 'Harga Satuan', value: AppDateUtils.formatCurrency(tx.unitPrice)),
                            _DetailRow(label: 'Total', value: AppDateUtils.formatCurrency(tx.totalPrice)),
                            _DetailRow(label: 'Pemesan', value: tx.customerName),
                            _DetailRow(label: 'Tanggal', value: AppDateUtils.formatDate(tx.transactionDate)),
                            if (auth.isAdmin && tx.status == TransactionStatus.pending) ...[
                              const SizedBox(height: AppSizes.spacingSm),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        txProv.updateStatus(tx.id, TransactionStatus.completed);
                                      },
                                      child: const Text('Selesaikan'),
                                    ),
                                  ),
                                  const SizedBox(width: AppSizes.spacingSm),
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        txProv.updateStatus(tx.id, TransactionStatus.cancelled);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                      ),
                                      child: const Text('Batalkan'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
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
