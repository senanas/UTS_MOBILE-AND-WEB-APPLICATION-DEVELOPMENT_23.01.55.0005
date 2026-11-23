import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/constants.dart';
import '../app/theme.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/layanan_chronostore.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

/// Daftar transaksi — Minggu 10: `StreamBuilder` + `.snapshots()` Firestore.
///
/// Tiga keadaan ditangani: waiting (loading), hasError (Rules / koneksi), dan
/// data (kosong atau terisi). Pelanggan hanya melihat transaksinya sendiri
/// (`where('id_pengguna', isEqualTo: uid)`); Admin melihat semuanya.
class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Stream<List<Transaction>>? _stream;
  LayananChronoStore? _layanan;
  String? _streamKey;

  void _siapkanStream() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final key = '${auth.isAdmin}|${user.id}';
    if (key == _streamKey) return; // jangan langganan ulang tiap rebuild
    _streamKey = key;
    _layanan = context.read<LayananChronoStore>();
    _stream = auth.isAdmin
        ? _layanan!.streamSemuaTransaksi()
        : _layanan!.streamTransaksiSaya(user.id);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _siapkanStream();
  }

  Future<void> _ubahStatus(String id, TransactionStatus status) async {
    try {
      await _layanan?.ubahStatusTransaksi(id, status);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengubah status. Periksa Security Rules.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _siapkanStream();
    final auth = context.watch<AuthProvider>();
    final stream = _stream;

    return Scaffold(
      appBar: AppBar(
        title: Text(auth.isAdmin ? 'Transaksi' : 'Transaksi Saya'),
      ),
      body: stream == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Transaction>>(
              stream: stream,
              builder: (context, snapshot) {
                // 1. Menunggu data pertama datang dari Firestore.
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                // 2. Rules belum dipublish / database belum dibuat.
                if (snapshot.hasError) {
                  return EmptyState(
                    icon: Icons.cloud_off,
                    message: 'Gagal memuat data dari Cloud Firestore.\n'
                        'Periksa Rules (request.auth != null) dan koneksi.',
                  );
                }

                final daftar = snapshot.data ?? const <Transaction>[];
                // 3. Data kosong.
                if (daftar.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: AppConstants.emptyTransactions,
                  );
                }

                // 4. Data terisi — sudah terurut terbaru di sisi Dart.
                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.screenPadding),
                  itemCount: daftar.length,
                  itemBuilder: (context, index) {
                    final tx = daftar[index];
                    return Card(
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.spacingMd,
                        ),
                        title: Text(tx.watchName),
                        subtitle: Text(
                          '${AppDateUtils.formatDate(tx.transactionDate)} - '
                          '${tx.customerName}'
                          '${tx.shippingCity.isNotEmpty ? ' • ${tx.shippingCity}' : ''}',
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
                              textColor:
                                  tx.status == TransactionStatus.completed
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
                                _DetailRow(
                                    label: 'Jam Tangan', value: tx.watchName),
                                _DetailRow(
                                    label: 'Jumlah',
                                    value: '${tx.quantity} unit'),
                                _DetailRow(
                                    label: 'Harga Satuan',
                                    value: AppDateUtils.formatCurrency(
                                        tx.unitPrice)),
                                _DetailRow(
                                    label: 'Total',
                                    value: AppDateUtils.formatCurrency(
                                        tx.totalPrice)),
                                _DetailRow(
                                    label: 'Pemesan', value: tx.customerName),
                                if (tx.customerEmail.isNotEmpty)
                                  _DetailRow(
                                      label: 'Email',
                                      value: tx.customerEmail),
                                if (tx.customerPhone.isNotEmpty)
                                  _DetailRow(
                                      label: 'Telepon',
                                      value: tx.customerPhone),
                                if (tx.alamatLengkap.isNotEmpty)
                                  _DetailRow(
                                      label: 'Alamat',
                                      value: tx.alamatLengkap),
                                if (tx.shippingCost > 0)
                                  _DetailRow(
                                      label: 'Ongkir',
                                      value: AppDateUtils.formatCurrency(
                                          tx.shippingCost)),
                                if (tx.notes.isNotEmpty)
                                  _DetailRow(
                                      label: 'Catatan', value: tx.notes),
                                _DetailRow(
                                    label: 'Tanggal',
                                    value: AppDateUtils.formatDate(
                                        tx.transactionDate)),
                                if (auth.isAdmin &&
                                    tx.status == TransactionStatus.pending) ...[
                                  const SizedBox(height: AppSizes.spacingSm),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _ubahStatus(tx.id,
                                              TransactionStatus.completed),
                                          child: const Text('Selesaikan'),
                                        ),
                                      ),
                                      const SizedBox(width: AppSizes.spacingSm),
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () => _ubahStatus(tx.id,
                                              TransactionStatus.cancelled),
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
              style:
                  const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
