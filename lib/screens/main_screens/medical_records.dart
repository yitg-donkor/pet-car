import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pet_care/models/medical_record.dart';
import 'package:pet_care/models/pet.dart';
import 'package:pet_care/providers/auth_providers.dart';
import 'package:pet_care/providers/offline_providers.dart';

class MedicalRecordsScreen extends ConsumerStatefulWidget {
  const MedicalRecordsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MedicalRecordsScreen> createState() =>
      _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends ConsumerState<MedicalRecordsScreen> {
  String? selectedPetId;
  String selectedFilter = 'all'; // all, vaccination, checkup, medication, etc.

  @override
  Widget build(BuildContext context) {
    final petsAsync = ref.watch(petsOfflineProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Medical Records',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _manualSync,
            icon: const Icon(Icons.sync, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pet Selector & Filter
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Pet Dropdown
                petsAsync.when(
                  data: (pets) {
                    if (pets.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'No pets available. Add a pet first.',
                        ),
                      );
                    }

                    // Set initial pet if not selected
                    if (selectedPetId == null && pets.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            selectedPetId = pets.first.id;
                          });
                        }
                      });
                    }

                    return DropdownButtonFormField<String>(
                      value: selectedPetId,
                      decoration: InputDecoration(
                        labelText: 'Select Pet',
                        prefixIcon: const Icon(Icons.pets),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      items:
                          pets.map((pet) {
                            return DropdownMenuItem(
                              value: pet.id,
                              child: Text(pet.name),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedPetId = value;
                        });
                      },
                    );
                  },
                  loading:
                      () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Error: $e'),
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      _buildFilterChip('Vaccination', 'vaccination'),
                      _buildFilterChip('Checkup', 'checkup'),
                      _buildFilterChip('Medication', 'medication'),
                      _buildFilterChip('Surgery', 'surgery'),
                      _buildFilterChip('Grooming', 'grooming'),
                      _buildFilterChip('Other', 'other'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Records List
          Expanded(
            child:
                selectedPetId == null
                    ? _buildEmptyState('Select a pet to view records')
                    : _buildRecordsList(selectedPetId!),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedPetId != null ? () => _showAddRecordDialog() : null,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedFilter = value;
          });
        },
        selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
        checkmarkColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildRecordsList(String petId) {
    final recordsAsync = ref.watch(petMedicalRecordsOfflineProvider(petId));

    return recordsAsync.when(
      data: (records) {
        // Apply filter
        final filteredRecords =
            selectedFilter == 'all'
                ? records
                : records.where((r) => r.recordType == selectedFilter).toList();

        if (filteredRecords.isEmpty) {
          return _buildEmptyState(
            selectedFilter == 'all'
                ? 'No medical records yet'
                : 'No ${selectedFilter} records',
          );
        }

        return RefreshIndicator(
          onRefresh: _manualSync,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecords.length,
            itemBuilder: (context, index) {
              final record = filteredRecords[index];
              return _buildRecordCard(record);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final icon = _getIconForRecordType(record.recordType);
    final color = _getColorForRecordType(record.recordType);

    return Dismissible(
      key: Key(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _showDeleteConfirmDialog(record);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: InkWell(
          onTap: () => _showRecordDetailsDialog(record),
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatRecordType(record.recordType),
                            style: TextStyle(
                              fontSize: 14,
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditRecordDialog(record),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                if (record.description != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    record.description!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      _formatDate(record.date),
                    ),
                    if (record.veterinarian != null)
                      _buildInfoChip(
                        Icons.medical_services,
                        record.veterinarian!,
                      ),
                    if (record.cost != null)
                      _buildInfoChip(
                        Icons.attach_money,
                        '\$${record.cost!.toStringAsFixed(2)}',
                      ),
                    if (record.nextDueDate != null)
                      _buildInfoChip(
                        Icons.event,
                        'Next: ${_formatDate(record.nextDueDate!)}',
                        color: Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color ?? Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: color ?? Colors.grey[700]),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (selectedPetId != null)
            ElevatedButton.icon(
              onPressed: _showAddRecordDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Record'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getIconForRecordType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Icons.vaccines;
      case 'checkup':
        return Icons.health_and_safety;
      case 'medication':
        return Icons.medication;
      case 'surgery':
        return Icons.local_hospital;
      case 'grooming':
        return Icons.content_cut;
      default:
        return Icons.medical_services;
    }
  }

  Color _getColorForRecordType(String type) {
    switch (type.toLowerCase()) {
      case 'vaccination':
        return Colors.blue;
      case 'checkup':
        return const Color(0xFF4CAF50);
      case 'medication':
        return Colors.orange;
      case 'surgery':
        return Colors.red;
      case 'grooming':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatRecordType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _manualSync() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.fullSync(user.id);

      if (selectedPetId != null) {
        ref.invalidate(petMedicalRecordsOfflineProvider(selectedPetId!));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sync completed!')));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    }
  }

  Future<bool> _showDeleteConfirmDialog(MedicalRecord record) async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('Delete Record?'),
            content: Text('Are you sure you want to delete "${record.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (result == true) {
      await _deleteRecord(record.id);
    }

    return false; // Don't dismiss the card, we handle it manually
  }

  Future<void> _deleteRecord(String recordId) async {
    try {
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      await medicalRecordDB.deleteRecord(recordId);

      final syncService = ref.read(unifiedSyncServiceProvider);
      if (await syncService.hasInternetConnection()) {
        try {
          await syncService.supabase
              .from('medical_records')
              .delete()
              .eq('id', recordId);
        } catch (e) {
          print('Error deleting from Supabase: $e');
        }
      }

      if (selectedPetId != null) {
        ref.invalidate(petMedicalRecordsOfflineProvider(selectedPetId!));
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record deleted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddRecordDialog() {
    if (selectedPetId == null) return;

    showDialog(
      context: context,
      builder:
          (context) => _MedicalRecordFormDialog(
            petId: selectedPetId!,
            onSave: (record) async {
              await _saveRecord(record);
            },
          ),
    );
  }

  void _showEditRecordDialog(MedicalRecord record) {
    showDialog(
      context: context,
      builder:
          (context) => _MedicalRecordFormDialog(
            petId: record.petId,
            existingRecord: record,
            onSave: (updatedRecord) async {
              await _updateRecord(updatedRecord);
            },
          ),
    );
  }

  void _showRecordDetailsDialog(MedicalRecord record) {
    showDialog(
      context: context,
      builder: (context) => _RecordDetailsDialog(record: record),
    );
  }

  Future<void> _saveRecord(MedicalRecord record) async {
    try {
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);
      await medicalRecordDB.createMedicalRecord(record);

      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.syncMedicalRecordsToSupabase();

      if (selectedPetId != null) {
        ref.invalidate(petMedicalRecordsOfflineProvider(selectedPetId!));
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record saved!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRecord(MedicalRecord record) async {
    try {
      final medicalRecordDB = ref.read(medicalRecordLocalDBProvider);

      // Delete old and create new (since there's no update method in your DB)
      await medicalRecordDB.deleteRecord(record.id);
      await medicalRecordDB.createMedicalRecord(record);

      final syncService = ref.read(unifiedSyncServiceProvider);
      await syncService.syncMedicalRecordsToSupabase();

      if (selectedPetId != null) {
        ref.invalidate(petMedicalRecordsOfflineProvider(selectedPetId!));
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Record updated!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// ============================================
// MEDICAL RECORD FORM DIALOG
// ============================================
class _MedicalRecordFormDialog extends StatefulWidget {
  final String petId;
  final MedicalRecord? existingRecord;
  final Function(MedicalRecord) onSave;

  const _MedicalRecordFormDialog({
    required this.petId,
    this.existingRecord,
    required this.onSave,
  });

  @override
  State<_MedicalRecordFormDialog> createState() =>
      _MedicalRecordFormDialogState();
}

class _MedicalRecordFormDialogState extends State<_MedicalRecordFormDialog> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController veterinarianController;
  late TextEditingController costController;
  late String selectedRecordType;
  late DateTime selectedDate;
  DateTime? nextDueDate;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRecord;

    titleController = TextEditingController(text: existing?.title ?? '');
    descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    veterinarianController = TextEditingController(
      text: existing?.veterinarian ?? '',
    );
    costController = TextEditingController(
      text: existing?.cost != null ? existing!.cost.toString() : '',
    );
    selectedRecordType = existing?.recordType ?? 'other';
    selectedDate = existing?.date ?? DateTime.now();
    nextDueDate = existing?.nextDueDate;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    veterinarianController.dispose();
    costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        widget.existingRecord == null
            ? 'Add Medical Record'
            : 'Edit Medical Record',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRecordType,
              decoration: InputDecoration(
                labelText: 'Record Type *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'vaccination',
                  child: Text('Vaccination'),
                ),
                DropdownMenuItem(value: 'checkup', child: Text('Checkup')),
                DropdownMenuItem(
                  value: 'medication',
                  child: Text('Medication'),
                ),
                DropdownMenuItem(value: 'surgery', child: Text('Surgery')),
                DropdownMenuItem(value: 'grooming', child: Text('Grooming')),
                DropdownMenuItem(value: 'other', child: Text('Other')),
              ],
              onChanged: (value) {
                setState(() => selectedRecordType = value ?? 'other');
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => selectedDate = date);
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: veterinarianController,
              decoration: InputDecoration(
                labelText: 'Veterinarian',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: costController,
              decoration: InputDecoration(
                labelText: 'Cost',
                prefixText: '\$ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Next Due Date',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: const Icon(Icons.event),
              ),
              readOnly: true,
              controller: TextEditingController(
                text:
                    nextDueDate != null
                        ? '${nextDueDate!.day}/${nextDueDate!.month}/${nextDueDate!.year}'
                        : '',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: nextDueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (date != null) {
                  setState(() => nextDueDate = date);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveRecord,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(widget.existingRecord == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }

  void _saveRecord() {
    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }

    final record = MedicalRecord(
      id: widget.existingRecord?.id ?? '',
      petId: widget.petId,
      recordType: selectedRecordType,
      title: titleController.text,
      description:
          descriptionController.text.isEmpty
              ? null
              : descriptionController.text,
      date: selectedDate,
      veterinarian:
          veterinarianController.text.isEmpty
              ? null
              : veterinarianController.text,
      cost:
          costController.text.isEmpty
              ? null
              : double.tryParse(costController.text),
      nextDueDate: nextDueDate,
    );

    widget.onSave(record);
    Navigator.pop(context);
  }
}

// ============================================
// RECORD DETAILS DIALOG
// ============================================
class _RecordDetailsDialog extends StatelessWidget {
  final MedicalRecord record;

  const _RecordDetailsDialog({required this.record});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(record.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Type', _formatRecordType(record.recordType)),
            _buildDetailRow('Date', _formatDate(record.date)),
            if (record.description != null)
              _buildDetailRow('Description', record.description!),
            if (record.veterinarian != null)
              _buildDetailRow('Veterinarian', record.veterinarian!),
            if (record.cost != null)
              _buildDetailRow('Cost', '\$${record.cost!.toStringAsFixed(2)}'),
            if (record.nextDueDate != null)
              _buildDetailRow('Next Due', _formatDate(record.nextDueDate!)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  String _formatRecordType(String type) {
    return type[0].toUpperCase() + type.substring(1);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
