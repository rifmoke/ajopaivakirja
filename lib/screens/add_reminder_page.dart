import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/reminder.dart';
import '../config/theme.dart';

class AddReminderPage extends StatefulWidget {
  final Reminder? reminder;

  const AddReminderPage({super.key, this.reminder});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetMileageController;
  late TextEditingController _notifyDaysBeforeController;
  late TextEditingController _notifyMileageBeforeController;

  ReminderType _selectedType = ReminderType.service;
  ReminderTrigger _selectedTrigger = ReminderTrigger.date;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.reminder?.title ?? '');
    _descriptionController = TextEditingController(text: widget.reminder?.description ?? '');
    _targetMileageController = TextEditingController(
      text: widget.reminder?.targetMileage?.toString() ?? '',
    );
    _notifyDaysBeforeController = TextEditingController(
      text: widget.reminder?.notifyDaysBefore?.toString() ?? '7',
    );
    _notifyMileageBeforeController = TextEditingController(
      text: widget.reminder?.notifyMileageBefore?.toString() ?? '500',
    );

    if (widget.reminder != null) {
      _selectedType = widget.reminder!.type;
      _selectedTrigger = widget.reminder!.trigger;
      _selectedDate = widget.reminder!.targetDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetMileageController.dispose();
    _notifyDaysBeforeController.dispose();
    _notifyMileageBeforeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      locale: const Locale('fi', 'FI'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_formKey.currentState!.validate()) {
      final vehicleProvider = context.read<VehicleProvider>();
      final selectedVehicle = vehicleProvider.selectedVehicle;

      if (selectedVehicle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Valitse ensin auto')),
        );
        return;
      }

      // Validate based on trigger type
      if (_selectedTrigger == ReminderTrigger.date || _selectedTrigger == ReminderTrigger.both) {
        if (_selectedDate == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Valitse päivämäärä')),
          );
          return;
        }
      }

      if (_selectedTrigger == ReminderTrigger.mileage || _selectedTrigger == ReminderTrigger.both) {
        if (_targetMileageController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anna kilometrimäärä')),
          );
          return;
        }
      }

      final reminder = Reminder(
        id: widget.reminder?.id,
        vehicleId: selectedVehicle.id!,
        type: _selectedType,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        trigger: _selectedTrigger,
        targetDate: (_selectedTrigger == ReminderTrigger.date || _selectedTrigger == ReminderTrigger.both)
            ? _selectedDate
            : null,
        targetMileage: (_selectedTrigger == ReminderTrigger.mileage || _selectedTrigger == ReminderTrigger.both)
            ? int.tryParse(_targetMileageController.text)
            : null,
        notifyDaysBefore: _notifyDaysBeforeController.text.isEmpty
            ? null
            : int.tryParse(_notifyDaysBeforeController.text),
        notifyMileageBefore: _notifyMileageBeforeController.text.isEmpty
            ? null
            : int.tryParse(_notifyMileageBeforeController.text),
      );

      final reminderProvider = context.read<ReminderProvider>();
      if (widget.reminder == null) {
        await reminderProvider.addReminder(reminder);
      } else {
        await reminderProvider.updateReminder(reminder);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _deleteReminder() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista muistutus?'),
        content: const Text('Haluatko varmasti poistaa tämän muistutuksen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Peruuta'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Poista'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.reminder?.id != null) {
      final reminderProvider = context.read<ReminderProvider>();
      await reminderProvider.deleteReminder(widget.reminder!.id!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder == null ? 'Lisää muistutus' : 'Muokkaa muistutusta'),
        actions: [
          if (widget.reminder != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteReminder,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type selection
              const Text(
                'Tyyppi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ReminderType.values.map((type) {
                  return ChoiceChip(
                    label: Text(Reminder.getTypeLabel(type)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                          if (_titleController.text.isEmpty) {
                            _titleController.text = Reminder.getTypeLabel(type);
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Otsikko *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Anna otsikko';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Kuvaus',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Trigger type
              const Text(
                'Muistutuksen laukaisu',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SegmentedButton<ReminderTrigger>(
                segments: [
                  ButtonSegment(
                    value: ReminderTrigger.date,
                    label: Text(Reminder.getTriggerLabel(ReminderTrigger.date)),
                    icon: const Icon(Icons.calendar_today),
                  ),
                  ButtonSegment(
                    value: ReminderTrigger.mileage,
                    label: Text(Reminder.getTriggerLabel(ReminderTrigger.mileage)),
                    icon: const Icon(Icons.speed),
                  ),
                  ButtonSegment(
                    value: ReminderTrigger.both,
                    label: Text(Reminder.getTriggerLabel(ReminderTrigger.both)),
                    icon: const Icon(Icons.merge_type),
                  ),
                ],
                selected: {_selectedTrigger},
                onSelectionChanged: (Set<ReminderTrigger> selected) {
                  setState(() {
                    _selectedTrigger = selected.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Date fields
              if (_selectedTrigger == ReminderTrigger.date || _selectedTrigger == ReminderTrigger.both) ...[
                const Text(
                  'Päivämäärä',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Valitse päivämäärä'
                        : DateFormat('dd.MM.yyyy').format(_selectedDate!),
                  ),
                  leading: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notifyDaysBeforeController,
                  decoration: const InputDecoration(
                    labelText: 'Ilmoita päiviä ennen',
                    border: OutlineInputBorder(),
                    suffixText: 'päivää',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
              ],

              // Mileage fields
              if (_selectedTrigger == ReminderTrigger.mileage || _selectedTrigger == ReminderTrigger.both) ...[
                const Text(
                  'Kilometrit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _targetMileageController,
                  decoration: const InputDecoration(
                    labelText: 'Tavoite kilometrimäärä',
                    border: OutlineInputBorder(),
                    suffixText: 'km',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notifyMileageBeforeController,
                  decoration: const InputDecoration(
                    labelText: 'Ilmoita kilometrejä ennen',
                    border: OutlineInputBorder(),
                    suffixText: 'km',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.reminder == null ? 'Lisää muistutus' : 'Tallenna muutokset',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
