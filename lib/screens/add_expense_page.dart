import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../providers/vehicle_provider.dart';
import '../config/theme.dart';

class AddExpensePage extends StatefulWidget {
  final Expense? expense;

  const AddExpensePage({super.key, this.expense});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = ExpenseCategory.fuel;
  final _amountController = TextEditingController();
  final _companyController = TextEditingController();
  final _litersController = TextEditingController();
  final _pricePerLiterController = TextEditingController();
  final _notesController = TextEditingController();
  String? _receiptPath;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _selectedDate = widget.expense!.date;
      _selectedCategory = widget.expense!.category;
      _amountController.text = widget.expense!.amount.toString();
      _companyController.text = widget.expense!.company ?? '';
      _litersController.text = widget.expense!.liters?.toString() ?? '';
      _pricePerLiterController.text = widget.expense!.pricePerLiter?.toString() ?? '';
      _notesController.text = widget.expense!.notes ?? '';
      _receiptPath = widget.expense!.receiptPath;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _companyController.dispose();
    _litersController.dispose();
    _pricePerLiterController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickReceipt() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valitse kuva'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ota kuva'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Valitse galleriasta'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        // Copy to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final receiptsDir = Directory('${appDir.path}/receipts');
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }

        final fileName = '${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final newPath = '${receiptsDir.path}/$fileName';
        
        await File(pickedFile.path).copy(newPath);

        setState(() {
          _receiptPath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Virhe kuvan valinnassa: $e')),
        );
      }
    }
  }

  void _calculatePricePerLiter() {
    final amount = double.tryParse(_amountController.text);
    final liters = double.tryParse(_litersController.text);
    
    if (amount != null && liters != null && liters > 0) {
      final pricePerLiter = amount / liters;
      _pricePerLiterController.text = pricePerLiter.toStringAsFixed(3);
    }
  }

  void _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      final vehicleProvider = context.read<VehicleProvider>();
      final selectedVehicle = vehicleProvider.selectedVehicle;
      
      final expense = Expense(
        id: widget.expense?.id,
        date: _selectedDate,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        company: _companyController.text.isNotEmpty ? _companyController.text : null,
        liters: _litersController.text.isNotEmpty ? double.parse(_litersController.text) : null,
        pricePerLiter: _pricePerLiterController.text.isNotEmpty 
            ? double.parse(_pricePerLiterController.text) 
            : null,
        receiptPath: _receiptPath,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        vehicleId: selectedVehicle?.id,
      );

      if (widget.expense == null) {
        await context.read<ExpenseProvider>().addExpense(expense);
      } else {
        await context.read<ExpenseProvider>().updateExpense(expense);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.expense == null ? 'Kulu tallennettu!' : 'Kulu päivitetty!')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    final isFuel = _selectedCategory == ExpenseCategory.fuel;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Lisää kulu' : 'Muokkaa kulua'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date selector
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today, color: AppTheme.primaryRed),
                  title: const Text('Päivämäärä'),
                  trailing: Text(
                    dateFormat.format(_selectedDate),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Category selector
              Text(
                'Kategoria',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ExpenseCategory.all.map((category) {
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryRed,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textMedium,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Summa (€)',
                  prefixIcon: Icon(Icons.euro),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pakollinen';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Virheellinen summa';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (isFuel) _calculatePricePerLiter();
                },
              ),
              const SizedBox(height: 16),

              // Company
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Yritys (valinnainen)',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),

              // Fuel-specific fields
              if (isFuel) ...[
                TextFormField(
                  controller: _litersController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Litramäärä',
                    prefixIcon: Icon(Icons.local_gas_station),
                  ),
                  onChanged: (value) => _calculatePricePerLiter(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _pricePerLiterController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Hinta/litra (€)',
                    prefixIcon: Icon(Icons.euro),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),
              ],

              // Receipt
              Text(
                'Kuitti',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              if (_receiptPath != null) ...[
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_receiptPath!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            _receiptPath = null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickReceipt,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(_receiptPath == null ? 'Lisää kuitti' : 'Vaihda kuitti'),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                'Lisätiedot',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Vapaaehtoinen lisätieto...',
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveExpense,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(widget.expense == null ? 'Tallenna kulu' : 'Päivitä kulu'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
