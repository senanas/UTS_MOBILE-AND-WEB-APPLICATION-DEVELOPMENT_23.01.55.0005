import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../models/transaction.dart';
import '../utils/date_utils.dart';
import 'riwayat_transaksi_screen.dart';

/// Halaman konfirmasi setelah checkout berhasil.
///
/// Menampilkan pesan "Transaksi Berhasil" besar, nomor pesanan, detail produk,
/// data pemesan & alamat pengiriman, rincian pembayaran, serta tombol untuk
/// melihat riwayat transaksi atau kembali berbelanja.
class CheckoutSuccessScreen extends StatelessWidget {
  final Transaction transaksi;

  const CheckoutSuccessScreen({
    super.key,
    required this.transaksi,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _kembaliKeBeranda(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaksi Berhasil'),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSizes.spacingLg),
              // Ilustrasi sukses dengan aksen emas ChronoStore
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.22),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.tintGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.success, width: 2),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingLg),
              const Text(
                'Transaksi Berhasil!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppSizes.title,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              Text(
                transaksi.tersimpanLokal
                    ? 'Pesanan berhasil dibuat dan tersimpan di perangkat.\n'
                        'Catatan: Firestore belum mengizinkan tulis — '
                        'publish Security Rules agar tersinkron.'
                    : 'Terima kasih! Pesanan Anda telah tersimpan di '
                        'Cloud Firestore dan siap diproses.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppSizes.caption,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),

              // Nomor pesanan + tanggal
              Card(
                color: AppColors.surfaceAlt,
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.cardPadding),
                  child: Column(
                    children: [
                      _InfoBaris(
                        label: 'No. Pesanan',
                        value: transaksi.id,
                      ),
                      const SizedBox(height: AppSizes.spacingSm),
                      _InfoBaris(
                        label: 'Tanggal',
                        value: AppDateUtils.formatDate(
                            transaksi.transactionDate),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),

              // Detail produk
              _CardJudul(icon: Icons.shopping_bag_outlined, judul: 'Produk'),
              _InfoBaris(
                label: 'Jam Tangan',
                value: transaksi.watchName,
              ),
              _InfoBaris(
                label: 'Jumlah',
                value: '${transaksi.quantity} unit',
              ),
              _InfoBaris(
                label: 'Harga Satuan',
                value: AppDateUtils.formatCurrency(transaksi.unitPrice),
              ),
              const SizedBox(height: AppSizes.spacingMd),

              // Data pemesan & alamat
              _CardJudul(icon: Icons.person_outline, judul: 'Data Pemesan'),
              _InfoBaris(label: 'Nama', value: transaksi.customerName),
              if (transaksi.customerEmail.isNotEmpty)
                _InfoBaris(label: 'Email', value: transaksi.customerEmail),
              if (transaksi.customerPhone.isNotEmpty)
                _InfoBaris(label: 'Telepon', value: transaksi.customerPhone),
              if (transaksi.alamatLengkap.isNotEmpty)
                _InfoBaris(label: 'Alamat', value: transaksi.alamatLengkap),
              if (transaksi.notes.isNotEmpty)
                _InfoBaris(label: 'Catatan', value: transaksi.notes),
              const SizedBox(height: AppSizes.spacingMd),

              // Rincian pembayaran
              _CardJudul(icon: Icons.receipt_outlined, judul: 'Pembayaran'),
              _InfoBaris(
                label: 'Subtotal',
                value: AppDateUtils.formatCurrency(
                    transaksi.unitPrice * transaksi.quantity),
              ),
              _InfoBaris(
                label: 'Ongkir',
                value: transaksi.shippingCost == 0
                    ? 'Gratis'
                    : AppDateUtils.formatCurrency(transaksi.shippingCost),
              ),
              _InfoBaris(
                label: 'Total',
                value: AppDateUtils.formatCurrency(transaksi.totalPrice),
                tebal: true,
              ),
              const SizedBox(height: AppSizes.spacingSm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.spacingMd),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.tintAmber, AppColors.surfaceAlt],
                  ),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.primaryDark),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TOTAL PEMBAYARAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatCurrency(transaksi.totalPrice),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.spacingMd,
                  vertical: AppSizes.spacingSm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tintGreen,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.verified_outlined,
                        size: 16, color: AppColors.onTintGreen),
                    SizedBox(width: AppSizes.spacingSm),
                    Text(
                      'Status: Pesanan Diterima',
                      style: TextStyle(
                        color: AppColors.onTintGreen,
                        fontSize: AppSizes.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.spacingXl),

              // Tombol aksi
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RiwayatTransaksiScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history, size: 20),
                label: const Text('Lihat Riwayat Transaksi'),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              OutlinedButton.icon(
                onPressed: () => _kembaliKeBeranda(context),
                icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                label: const Text('Belanja Lagi'),
              ),
              const SizedBox(height: AppSizes.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  void _kembaliKeBeranda(BuildContext context) {
    // Kembali sampai halaman utama (MainShell) lalu pindah ke tab Riwayat.
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}

class _CardJudul extends StatelessWidget {
  final IconData icon;
  final String judul;

  const _CardJudul({required this.icon, required this.judul});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: AppSizes.spacingSm),
          Text(
            judul,
            style: const TextStyle(
              fontSize: AppSizes.caption,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBaris extends StatelessWidget {
  final String label;
  final String value;
  final bool tebal;

  const _InfoBaris({
    required this.label,
    required this.value,
    this.tebal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              style: TextStyle(
                fontSize: AppSizes.caption,
                fontWeight: tebal ? FontWeight.w700 : FontWeight.w500,
                color: tebal ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
