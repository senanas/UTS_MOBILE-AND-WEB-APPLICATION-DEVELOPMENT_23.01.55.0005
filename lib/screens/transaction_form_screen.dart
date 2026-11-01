import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../models/watch.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/date_utils.dart';

class TransactionFormScreen extends StatefulWidget {
  final Watch watch;

  const TransactionFormScreen({super.key, required this.watch});

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  int _quantity = 1;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController.text = auth.currentUser?.name ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  int get _totalPrice => widget.watch.price * _quantity;

  void _submit() {
    final auth = context.read<AuthProvider>();
    final txProv = context.read<TransactionProvider>();

    final success = txProv.create(
      watchId: widget.watch.id,
      watchName: widget.watch.name,
      quantity: _quantity,
      unitPrice: widget.watch.price,
      customerName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : auth.currentUser!.name,
      userId: auth.currentUser!.id,
    );

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dibuat'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok tidak mencukupi'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info jam tangan
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.cardPadding),
                child: Row(
                  children: [
                    const Icon(Icons.watch, color: AppColors.primary, size: 32),
                    const SizedBox(width: AppSizes.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.watch.name,
                            style: const TextStyle(
                              fontSize: AppSizes.body,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            AppDateUtils.formatCurrency(widget.watch.price),
                            style: const TextStyle(
                              fontSize: AppSizes.caption,
                              color: AppColors.primary,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSizes.spacingLg),
            // Nama pelanggan
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pemesan',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSizes.spacingMd),
            // Quantity
            const Text(
              'Jumlah',
              style: TextStyle(
                fontSize: AppSizes.caption,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.spacingSm),
            Row(
              children: [
                IconButton(
                  onPressed: _quantity > 1
                      ? () => setState(() => _quantity--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  width: 60,
                  alignment: Alignment.center,
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: AppSizes.subtitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _quantity < widget.watch.stock
                      ? () => setState(() => _quantity++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.spacingLg),
            // Total
            Container(
              padding: const EdgeInsets.all(AppSizes.cardPadding),
              decoration: BoxDecoration(
                color: const Color(0xFFFAEEDA),
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Harga',
                    style: TextStyle(
                      fontSize: AppSizes.body,
                      color: Color(0xFF854F0B),
                    ),
                  ),
                  Text(
                    AppDateUtils.formatCurrency(_totalPrice),
                    style: const TextStyle(
                      fontSize: AppSizes.title,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF854F0B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.spacingXl),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Buat Pesanan'),
            ),
          ],
        ),
      ),
    );
  }
}
