import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/watch.dart';
import '../providers/watch_provider.dart';
import '../services/validation_service.dart';

class WatchFormScreen extends StatefulWidget {
  final Watch? watch;

  const WatchFormScreen({super.key, this.watch});

  @override
  State<WatchFormScreen> createState() => _WatchFormScreenState();
}

class _WatchFormScreenState extends State<WatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _serialController = TextEditingController();
  WatchType _selectedType = WatchType.quartz;
  DateTime? _warrantyStart;
  DateTime? _warrantyEnd;
  bool get _isEdit => widget.watch != null;

  @override
  void initState() {
    super.initState();
    if (widget.watch != null) {
      final w = widget.watch!;
      _nameController.text = w.name;
      _brandController.text = w.brand;
      _modelController.text = w.model;
      _priceController.text = w.price.toString();
      _stockController.text = w.stock.toString();
      _serialController.text = w.serialNumber;
      _selectedType = w.movementType;
      _warrantyStart = w.warrantyStart;
      _warrantyEnd = w.warrantyEnd;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _serialController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final watchProv = context.read<WatchProvider>();

    final watch = Watch(
      id: widget.watch?.id ?? '',
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      movementType: _selectedType,
      price: int.parse(_priceController.text.trim()),
      stock: int.parse(_stockController.text.trim()),
      serialNumber: _serialController.text.trim(),
      imageUrl: widget.watch?.imageUrl,
      warrantyStart: _warrantyStart,
      warrantyEnd: _warrantyEnd,
      createdAt: widget.watch?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      watchProv.update(watch.copyWith(id: widget.watch!.id));
    } else {
      watchProv.add(watch);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEdit ? 'Jam tangan diperbarui' : 'Jam tangan ditambahkan'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _warrantyStart = picked;
        } else {
          _warrantyEnd = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchProv = context.read<WatchProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Jam Tangan' : 'Tambah Jam Tangan')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nama Jam Tangan',
                    prefixIcon: Icon(Icons.watch),
                  ),
                  validator: (v) {
                    final result = ValidationService.validateRequired(v, 'Nama');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                TextFormField(
                  controller: _brandController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Merek',
                    prefixIcon: Icon(Icons.branding_watermark),
                  ),
                  validator: (v) {
                    final result = ValidationService.validateRequired(v, 'Merek');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                TextFormField(
                  controller: _modelController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Model',
                    prefixIcon: Icon(Icons.tag),
                  ),
                  validator: (v) {
                    final result = ValidationService.validateRequired(v, 'Model');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                // Tipe mesin
                const Text(
                  'Tipe Mesin',
                  style: TextStyle(
                    fontSize: AppSizes.caption,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                SegmentedButton<WatchType>(
                  segments: WatchType.values
                      .map((type) => ButtonSegment(
                            value: type,
                            label: Text(type.label),
                          ))
                      .toList(),
                  selected: {_selectedType},
                  onSelectionChanged: (set) {
                    setState(() => _selectedType = set.first);
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Harga (Rp)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  validator: (v) {
                    final result = ValidationService.validatePrice(v);
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                TextFormField(
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Stok',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (v) {
                    final result = ValidationService.validateNonNegativeInt(v, 'Stok');
                    return result.isValid ? null : result.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                TextFormField(
                  controller: _serialController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Nomor Seri',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  validator: (v) {
                    final result = ValidationService.validateRequired(v, 'Nomor seri');
                    if (!result.isValid) return result.error;
                    final isTaken = watchProv.isSerialNumberTaken(
                      v!.trim(),
                      excludeId: widget.watch?.id,
                    );
                    final serialResult = ValidationService.validateSerialNumber(
                      v,
                      isTaken: isTaken,
                    );
                    return serialResult.isValid ? null : serialResult.error;
                  },
                ),
                const SizedBox(height: AppSizes.spacingLg),
                // Garansi (opsional)
                const Text(
                  'Masa Garansi (opsional)',
                  style: TextStyle(
                    fontSize: AppSizes.subtitle,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(context, true),
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          _warrantyStart != null
                              ? '${_warrantyStart!.day}/${_warrantyStart!.month}/${_warrantyStart!.year}'
                              : 'Tanggal Mulai',
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.spacingSm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDate(context, false),
                        icon: const Icon(Icons.event_available, size: 18),
                        label: Text(
                          _warrantyEnd != null
                              ? '${_warrantyEnd!.day}/${_warrantyEnd!.month}/${_warrantyEnd!.year}'
                              : 'Tanggal Berakhir',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.spacingXl),
                ElevatedButton(
                  onPressed: _submit,
                  child: const Text(AppConstants.btnSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
