import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/transaction.dart';
import '../providers/auth_provider.dart';
import '../services/layanan_chronostore.dart';
import '../services/transaksi_lokal.dart';
import '../utils/date_utils.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

/// Halaman Riwayat Transaksi.
///
/// Menampilkan pesanan dari Cloud Firestore (real-time) DIGABUNGKAN dengan
/// pesanan cadangan di perangkat (bila Firestore menolak tulis). Detail
/// checkout — nama, email, telepon, alamat, ongkir, catatan — ditampilkan
/// lengkap pada setiap kartu.
class RiwayatTransaksiScreen extends StatefulWidget {
  /// Diisi saat halaman dipakai sebagai tab navigasi utama.
  final int? navIndex;
  final ValueChanged<int>? onNavTap;

  const RiwayatTransaksiScreen({
    super.key,
    this.navIndex,
    this.onNavTap,
  });

  @override
  State<RiwayatTransaksiScreen> createState() =>
      _RiwayatTransaksiScreenState();
}

class _RiwayatTransaksiScreenState extends State<RiwayatTransaksiScreen> {
  Stream<List<Transaction>>? _stream;
  LayananChronoStore? _layanan;
  String? _streamKey;
  List<Transaction> _lokal = const [];

  @override
  void initState() {
    super.initState();
    _muatLokal();
  }

  Future<void> _muatLokal() async {
    final daftar = await TransaksiLokal.bacaSemua();
    if (mounted) setState(() => _lokal = daftar);
  }

  void _siapkanStream() {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;
    if (user == null) return;

    final key = '${auth.isAdmin}|${user.id}';
    if (key == _streamKey) return;
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

  @override
  Widget build(BuildContext context) {
    _siapkanStream();
    final auth = context.watch<AuthProvider>();
    final stream = _stream;
    final body = stream == null
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<List<Transaction>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final dariFirestore = snapshot.data ?? const <Transaction>[];
                final uid = auth.currentUser?.id;
                final lokal = auth.isAdmin
                    ? _lokal
                    : _lokal.where((t) => t.userId == uid).toList();

                // Gabungkan, hindari duplikat berdasarkan id.
                final melihat = <String>{};
                final semua = <Transaction>[];
                for (final tx in [...dariFirestore, ...lokal]) {
                  if (melihat.add(tx.id)) semua.add(tx);
                }
                semua.sort((a, b) => (b.createdAt ?? b.transactionDate)
                    .compareTo(a.createdAt ?? a.transactionDate));

                if (semua.isEmpty) {
                  return EmptyState(
                    icon: Icons.receipt_long_outlined,
                    message: snapshot.hasError
                        ? 'Gagal memuat dari Cloud Firestore.\n'
                            'Periksa Rules (request.auth != null) dan koneksi.'
                        : 'Belum ada riwayat transaksi.\n'
                            'Pesan jam tangan untuk mulai berbelanja.',
                  );
                }

                return Column(
                  children: [
                    _RingkasanTransaksi(
                      jumlah: semua.length,
                      total: semua.fold<int>(
                        0, (sum, tx) => sum + tx.totalPrice),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSizes.screenPadding,
                          AppSizes.spacingSm,
                          AppSizes.screenPadding,
                          AppSizes.spacingXl,
                        ),
                        itemCount: semua.length,
                        itemBuilder: (context, index) =>
                            _TransaksiCard(tx: semua[index]),
                      ),
                    ),
                  ],
                );
              },
            );

    // Dipakai sebagai tab navigasi utama → tampilkan bottom nav / rail.
    if (widget.navIndex != null && widget.onNavTap != null) {
      return AppScaffold(
        title: 'Riwayat Transaksi',
        currentIndex: widget.navIndex!,
        onNavTap: widget.onNavTap!,
        body: body,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muatLokal,
          ),
        ],
      );
    }

    // Dipakai sebagai halaman yang di-push dari checkout.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _muatLokal,
          ),
        ],
      ),
      body: body,
    );
  }
}

// ============================================================ RINGKASAN
class _RingkasanTransaksi extends StatelessWidget {
  final int jumlah;
  final int total;

  const _RingkasanTransaksi({
    required this.jumlah,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSizes.screenPadding),
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tintAmber, AppColors.surfaceAlt],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  '$jumlah',
                  style: const TextStyle(
                    fontSize: AppSizes.title,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Total transaksi',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 56, color: AppColors.primaryDark),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.account_balance_wallet_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  AppDateUtils.formatCurrency(total),
                  style: const TextStyle(
                    fontSize: AppSizes.subtitle,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                const Text(
                  'Nilai pesanan',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _TransaksiCard extends StatelessWidget {
  final Transaction tx;

  const _TransaksiCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.spacingMd),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.spacingMd,
        ),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primaryLight, AppColors.tintAmber],
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.primaryDark),
          ),
          child: const Icon(Icons.watch,
              color: AppColors.primary, size: 20),
        ),
        title: Text(
          tx.watchName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${AppDateUtils.formatDate(tx.transactionDate)} • ${tx.customerName}'
          '${tx.shippingCity.isNotEmpty ? ' • ${tx.shippingCity}' : ''}',
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              AppDateUtils.formatCurrency(tx.totalPrice),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
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
                if (tx.tersimpanLokal)
                  Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
                    padding: const EdgeInsets.all(AppSizes.spacingSm),
                    decoration: BoxDecoration(
                      color: AppColors.tintAmber,
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.onTintAmber),
                        SizedBox(width: AppSizes.spacingSm),
                        Expanded(
                          child: Text(
                            'Tersimpan di perangkat (Firestore belum mengizinkan tulis)',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onTintAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const _Grup(label: 'PRODUK'),
                _DetailRow(label: 'Jam Tangan', value: tx.watchName),
                _DetailRow(label: 'Jumlah', value: '${tx.quantity} unit'),
                _DetailRow(label: 'Harga Satuan',
                    value: AppDateUtils.formatCurrency(tx.unitPrice)),
                _DetailRow(label: 'Ongkir',
                    value: tx.shippingCost == 0
                        ? 'Gratis'
                        : AppDateUtils.formatCurrency(tx.shippingCost)),
                _DetailRow(label: 'Total Pembayaran',
                    value: AppDateUtils.formatCurrency(tx.totalPrice)),
                const Divider(),
                const _Grup(label: 'DATA PEMESAN'),
                _DetailRow(label: 'Nama', value: tx.customerName),
                if (tx.customerEmail.isNotEmpty)
                  _DetailRow(label: 'Email', value: tx.customerEmail),
                if (tx.customerPhone.isNotEmpty)
                  _DetailRow(label: 'Telepon', value: tx.customerPhone),
                if (tx.alamatLengkap.isNotEmpty)
                  _DetailRow(label: 'Alamat', value: tx.alamatLengkap),
                if (tx.notes.isNotEmpty)
                  _DetailRow(label: 'Catatan', value: tx.notes),
                const Divider(),
                _DetailRow(label: 'Tanggal',
                    value: AppDateUtils.formatDate(tx.transactionDate)),
                _DetailRow(label: 'Status', value: tx.status.label),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Grup extends StatelessWidget {
  final String label;
  const _Grup({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary),
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
