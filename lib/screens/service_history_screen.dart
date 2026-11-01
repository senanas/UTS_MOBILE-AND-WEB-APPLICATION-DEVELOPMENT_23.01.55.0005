import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/theme.dart';
import '../app/constants.dart';
import '../models/service_record.dart';
import '../providers/watch_provider.dart';
import '../providers/service_provider.dart';
import '../utils/date_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/status_badge.dart';

class ServiceHistoryScreen extends StatefulWidget {
  final String watchId;

  const ServiceHistoryScreen({super.key, required this.watchId});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  bool _showForm = false;
  final _descController = TextEditingController();
  final _costController = TextEditingController();
  ServiceType _selectedType = ServiceType.routine;
  DateTime _selectedDate = DateTime.now();
  DateTime? _nextServiceDate;

  @override
  void dispose() {
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isServiceDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isServiceDate) {
          _selectedDate = picked;
        } else {
          _nextServiceDate = picked;
        }
      });
    }
  }

  void _saveService() {
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deskripsi wajib diisi'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final serviceProv = context.read<ServiceProvider>();
    int? cost;
    if (_costController.text.trim().isNotEmpty) {
      cost = int.tryParse(_costController.text.trim());
    }

    serviceProv.add(ServiceRecord(
      id: '',
      watchId: widget.watchId,
      serviceDate: _selectedDate,
      serviceType: _selectedType,
      description: _descController.text.trim(),
      cost: cost,
      nextServiceDate: _nextServiceDate,
    ));

    _descController.clear();
    _costController.clear();
    setState(() {
      _showForm = false;
      _selectedType = ServiceType.routine;
      _selectedDate = DateTime.now();
      _nextServiceDate = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Servis dicatat'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final watchProv = context.watch<WatchProvider>();
    final serviceProv = context.watch<ServiceProvider>();
    final watch = watchProv.getById(widget.watchId);
    final services = serviceProv.getByWatch(widget.watchId);

    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Servis - ${watch?.name ?? "Jam"}')),
      body: Column(
        children: [
          if (_showForm) _buildForm(),
          Expanded(
            child: services.isEmpty
                ? EmptyState(
                    icon: Icons.history,
                    message: AppConstants.emptyServices,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.screenPadding),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final s = services[index];
                      return Card(
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.spacingMd,
                            vertical: 0,
                          ),
                          title: Text(s.serviceType.label),
                          subtitle: Text(AppDateUtils.formatDate(s.serviceDate)),
                          trailing: StatusBadge(
                            label: AppDateUtils.relativeLabel(s.serviceDate),
                            color: const Color(0xFFF1EFE8),
                            textColor: AppColors.textSecondary,
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
                                  Text(s.description),
                                  if (s.cost != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Biaya: ${AppDateUtils.formatCurrency(s.cost!)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                  if (s.nextServiceDate != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Servis berikutnya: ${AppDateUtils.formatDate(s.nextServiceDate!)}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                      ),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() => _showForm = !_showForm),
        icon: Icon(_showForm ? Icons.close : Icons.add),
        label: Text(_showForm ? 'Tutup' : AppConstants.btnRecordService),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(true),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.spacingSm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(false),
                  icon: const Icon(Icons.event, size: 18),
                  label: Text(
                    _nextServiceDate != null
                        ? '${_nextServiceDate!.day}/${_nextServiceDate!.month}/${_nextServiceDate!.year}'
                        : 'Servis Berikutnya',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.spacingSm),
          SegmentedButton<ServiceType>(
            segments: ServiceType.values
                .map((type) => ButtonSegment(
                      value: type,
                      label: Text(type.label.split(' ').last),
                    ))
                .toList(),
            selected: {_selectedType},
            onSelectionChanged: (set) => setState(() => _selectedType = set.first),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          TextField(
            controller: _descController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              hintText: 'Jenis perawatan yang dilakukan...',
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          TextField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Biaya (opsional)',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
          ),
          const SizedBox(height: AppSizes.spacingSm),
          ElevatedButton(
            onPressed: _saveService,
            child: const Text(AppConstants.btnSave),
          ),
        ],
      ),
    );
  }
}
