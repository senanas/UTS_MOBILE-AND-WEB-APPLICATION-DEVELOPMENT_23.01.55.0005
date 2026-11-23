import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/transaction.dart';
import '../models/user_account.dart';
import '../models/watch.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/firestore_error.dart';
import '../services/layanan_chronostore.dart';
import '../services/transaksi_lokal.dart';
import '../services/validation_service.dart';
import '../utils/date_utils.dart';
import '../widgets/product_thumbnail.dart';
import 'checkout_success_screen.dart';
import 'riwayat_transaksi_screen.dart';

/// Halaman checkout: memesan jam tangan dengan data pelanggan lengkap
/// (nama, email, telepon, alamat pengiriman) dan rincian harga.
class TransactionFormScreen extends StatefulWidget {
  final Watch watch;

  const TransactionFormScreen({super.key, required this.watch});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _nameKey = GlobalKey<FormFieldState<String>>();
  final _emailKey = GlobalKey<FormFieldState<String>>();
  final _phoneKey = GlobalKey<FormFieldState<String>>();
  final _addressKey = GlobalKey<FormFieldState<String>>();
  final _cityKey = GlobalKey<FormFieldState<String>>();
  final _postalKey = GlobalKey<FormFieldState<String>>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalController = TextEditingController();
  final _notesController = TextEditingController();

  int _quantity = 1;
  int _ongkir = 15000;
  bool _isSaving = false;

  // Pilihan pengiriman: (label, biaya, ikon)
  static const _opsiPengiriman = [
    ('Reguler (2-3 hari)', 15000, Icons.local_shipping_outlined),
    ('Ekspres (1 hari)', 30000, Icons.flash_on_outlined),
    ('Ambil di toko', 0, Icons.storefront_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final UserAccount? user = context.read<AuthProvider>().currentUser;
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _subtotal => widget.watch.price * _quantity;
  int get _total => _subtotal + _ongkir;

  Future<void> _submit() async {
    if (_isSaving) return;
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      _tampilkanErrorValidasi();
      return;
    }

    final auth = context.read<AuthProvider>();
    final txProv = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final user = auth.currentUser;

    if (user == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sesi login habis. Silakan masuk kembali.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    // Objek pesanan dipakai bersama untuk cadangan lokal & halaman sukses.
    final pesanan = Transaction(
      id: 'lokal_${now.microsecondsSinceEpoch}',
      watchId: widget.watch.id,
      watchName: widget.watch.name,
      quantity: _quantity,
      unitPrice: widget.watch.price,
      totalPrice: _total,
      transactionDate: now,
      customerName: _nameController.text.trim(),
      customerEmail: _emailController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      shippingAddress: _addressController.text.trim(),
      shippingCity: _cityController.text.trim(),
      postalCode: _postalController.text.trim(),
      notes: _notesController.text.trim(),
      shippingCost: _ongkir,
      userId: user.id,
      status: TransactionStatus.completed,
      createdAt: now,
    );

    // Status diubah tepat sekali di bawah, berhasil atau gagal, supaya tombol
    // tidak pernah macet dalam keadaan "Memproses...".
    var berhasil = false;
    var tersimpanLokal = false;
    Object? galat;

    try {
      // 1. Coba tulis ke Cloud Firestore (sumber utama, Minggu 10).
      //    Timeout mencegah tombol disable selamanya bila jaringan menggantung.
      await txProv
          .create(
        watchId: widget.watch.id,
        watchName: widget.watch.name,
        quantity: _quantity,
        unitPrice: widget.watch.price,
        totalPrice: _total,
        ongkir: _ongkir,
        customerName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        postalCode: _postalController.text.trim(),
        notes: _notesController.text.trim(),
        userId: user.id,
      )
          .timeout(
        const Duration(seconds: 20),
        onTimeout: () =>
            throw const FormatException('Firestore tidak merespons (timeout)'),
      );
      berhasil = true;
    } on FirebaseException catch (e) {
      // 2. Rules belum publish / offline → simpan cadangan di perangkat supaya
      //    checkout tetap selesai dan pesanan tetap muncul di riwayat.
      if (e.code == 'permission-denied' || e.code == 'unavailable') {
        debugPrint('Firestore menolak tulis (${e.code}); simpan lokal.');
        try {
          await TransaksiLokal.simpan(
            pesanan.copyWith(tersimpanLokal: true),
          );
          tersimpanLokal = true;
          berhasil = true;
        } catch (e2) {
          galat = e2;
        }
      } else {
        debugPrint('Gagal menyimpan transaksi: $e');
        galat = e;
      }
    } on TransaksiBentrokException catch (e) {
      galat = e;
    } on StokTidakCukupException catch (e) {
      galat = e;
    } catch (e) {
      // Error tak terduga juga dicadangkan lokal agar checkout tidak gagal.
      debugPrint('Gagal menyimpan transaksi: $e');
      try {
        await TransaksiLokal.simpan(
          pesanan.copyWith(tersimpanLokal: true),
        );
        tersimpanLokal = true;
        berhasil = true;
      } catch (e2) {
        galat = e2;
      }
    }

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (!berhasil) {
      final pesan = galat is FirebaseException
          ? FirestoreError.pesan(galat)
          : 'Gagal menyimpan pesanan: ${galat ?? 'kesalahan tidak diketahui'}';
      messenger.showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
      return;
    }

    // Buka halaman konfirmasi "Transaksi Berhasil" dengan detail pesanan.
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutSuccessScreen(
          transaksi: pesanan.copyWith(tersimpanLokal: tersimpanLokal),
        ),
      ),
    );
  }

  /// Beri tahu user field mana yang belum valid, lalu gulir ke field tersebut.
  /// Tanpa ini, error muncul di atas layar sehingga tombol terasa "mati".
  void _tampilkanErrorValidasi() {
    if (!mounted) return;
    for (final key in [
      _nameKey,
      _emailKey,
      _phoneKey,
      _addressKey,
      _cityKey,
      _postalKey,
    ]) {
      if (key.currentState?.hasError ?? false) {
        final ctx = key.currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            alignment: 0.25,
          );
        }
        break;
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lengkapi field yang bertanda merah sebelum memesan.'),
        backgroundColor: AppColors.error,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Riwayat Transaksi',
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const RiwayatTransaksiScreen(),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppSizes.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionTitle(Icons.shopping_bag_outlined, 'Produk Pesanan'),
              _buildProductCard(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildSectionTitle(Icons.person_outline, 'Data Pemesan'),
              _buildTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                icon: Icons.person_outline,
                fieldKey: _nameKey,
                validator: (v) => _valid(v, ValidationService.validateName(v)),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email_outlined,
                fieldKey: _emailKey,
                keyboardType: TextInputType.emailAddress,
                validator: (v) => _valid(v, ValidationService.validateEmail(v)),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              _buildTextField(
                controller: _phoneController,
                label: 'Nomor Telepon',
                icon: Icons.phone_outlined,
                fieldKey: _phoneKey,
                keyboardType: TextInputType.phone,
                validator: (v) => _valid(
                  v,
                  ValidationService.validateRequired(v, 'Nomor telepon'),
                ),
              ),
              const SizedBox(height: AppSizes.spacingLg),

              _buildSectionTitle(
                  Icons.location_on_outlined, 'Alamat Pengiriman'),
              _buildTextField(
                controller: _addressController,
                label: 'Alamat Lengkap (Jalan, No. Rumah)',
                icon: Icons.home_outlined,
                fieldKey: _addressKey,
                maxLines: 2,
                validator: (v) => _valid(
                  v,
                  ValidationService.validateRequired(v, 'Alamat'),
                ),
              ),
              const SizedBox(height: AppSizes.spacingMd),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'Kota',
                      icon: Icons.location_city_outlined,
                      fieldKey: _cityKey,
                      validator: (v) => _valid(
                        v,
                        ValidationService.validateRequired(v, 'Kota'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.spacingMd),
                  Expanded(
                    child: _buildTextField(
                      controller: _postalController,
                      label: 'Kode Pos',
                      icon: Icons.markunread_mailbox_outlined,
                      fieldKey: _postalKey,
                      keyboardType: TextInputType.number,
                      validator: (v) => _valid(
                        v,
                        ValidationService.validateRequired(v, 'Kode pos'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.spacingMd),
              _buildTextField(
                controller: _notesController,
                label: 'Catatan (opsional)',
                icon: Icons.note_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: AppSizes.spacingLg),

              _buildSectionTitle(Icons.numbers, 'Jumlah'),
              _buildQuantityRow(),
              const SizedBox(height: AppSizes.spacingLg),

              _buildSectionTitle(
                  Icons.local_shipping_outlined, 'Metode Pengiriman'),
              Column(
                children: _opsiPengiriman.map((opsi) {
                  final selected = _ongkir == opsi.$2;
                  return InkWell(
                    onTap: () => setState(() => _ongkir = opsi.$2),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.spacingMd,
                        vertical: AppSizes.spacingSm,
                      ),
                      margin: const EdgeInsets.only(bottom: AppSizes.spacingSm),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border.all(
                          color:
                              selected ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(opsi.$3, color: AppColors.primary, size: 20),
                          const SizedBox(width: AppSizes.spacingSm),
                          Expanded(
                            child: Text(
                              opsi.$1,
                              style: const TextStyle(
                                fontSize: AppSizes.caption,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            opsi.$2 == 0
                                ? 'Gratis'
                                : AppDateUtils.formatCurrency(opsi.$2),
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                              fontSize: AppSizes.caption,
                            ),
                          ),
                          const SizedBox(width: AppSizes.spacingSm),
                          Icon(
                            selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.spacingLg),

              _buildRingkasanHarga(),
              const SizedBox(height: AppSizes.spacingXl),

              ElevatedButton.icon(
                onPressed: _isSaving ? null : _submit,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.buttonPrimaryText,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isSaving ? 'Memproses...' : 'Buat Pesanan',
                ),
              ),
              const SizedBox(height: AppSizes.spacingSm),
              OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RiwayatTransaksiScreen(),
                  ),
                ),
                icon: const Icon(Icons.history, size: 20),
                label: const Text('Lihat Riwayat Transaksi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _valid(String? value, ValidationResult result) =>
      result.isValid ? null : result.error;

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.spacingSm),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.primaryDark),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: AppSizes.spacingSm),
          Text(
            title,
            style: const TextStyle(
              fontSize: AppSizes.body,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          SizedBox(
            width: 108,
            height: 108,
            child: ProductThumbnail(
              watch: widget.watch,
              height: 108,
              showStockBadge: false,
            ),
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSizes.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.watch.name,
                    style: const TextStyle(
                      fontSize: AppSizes.body,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.watch.brand} • ${widget.watch.model}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppDateUtils.formatCurrency(widget.watch.price),
                    style: const TextStyle(
                      fontSize: AppSizes.caption,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Stok: ${widget.watch.stock} unit',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    GlobalKey<FormFieldState<String>>? fieldKey,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      key: fieldKey,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
    );
  }

  Widget _buildQuantityRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed:
                _quantity > 1 ? () => setState(() => _quantity--) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          Text(
            '$_quantity',
            style: const TextStyle(
              fontSize: AppSizes.subtitle,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: _quantity < widget.watch.stock
                ? () => setState(() => _quantity++)
                : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanHarga() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.tintAmber,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.primaryDark),
      ),
      child: Column(
        children: [
          _barisHarga('Subtotal ($_quantity x ${AppDateUtils.formatCurrency(widget.watch.price)})',
              AppDateUtils.formatCurrency(_subtotal)),
          const SizedBox(height: AppSizes.spacingSm),
          _barisHarga('Ongkos Kirim',
              _ongkir == 0 ? 'Gratis' : AppDateUtils.formatCurrency(_ongkir)),
          const Divider(color: AppColors.primaryDark),
          _barisHarga('Total Pembayaran', AppDateUtils.formatCurrency(_total),
              bold: true),
        ],
      ),
    );
  }

  Widget _barisHarga(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: bold ? AppSizes.body : AppSizes.caption,
              color: AppColors.onTintAmber,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? AppSizes.subtitle : AppSizes.caption,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            color: AppColors.onTintAmber,
          ),
        ),
      ],
    );
  }
}
