import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../config/theme.dart';

class AddVehiclePage extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehiclePage({super.key, this.vehicle});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _licensePlateController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _colorController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _licensePlateController = TextEditingController(text: widget.vehicle?.licensePlate ?? '');
    _brandController = TextEditingController(text: widget.vehicle?.brand ?? '');
    _modelController = TextEditingController(text: widget.vehicle?.model ?? '');
    _yearController = TextEditingController(text: widget.vehicle?.year?.toString() ?? '');
    _colorController = TextEditingController(text: widget.vehicle?.color ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _licensePlateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicle() async {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id,
        name: _nameController.text,
        licensePlate: _licensePlateController.text.isEmpty ? null : _licensePlateController.text,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        model: _modelController.text.isEmpty ? null : _modelController.text,
        year: _yearController.text.isEmpty ? null : int.tryParse(_yearController.text),
        color: _colorController.text.isEmpty ? null : _colorController.text,
      );

      final vehicleProvider = context.read<VehicleProvider>();
      if (widget.vehicle == null) {
        await vehicleProvider.addVehicle(vehicle);
      } else {
        await vehicleProvider.updateVehicle(vehicle);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Lisää auto' : 'Muokkaa autoa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nimi *',
                  hintText: 'Esim. Työauto, Perheauto',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Anna autolle nimi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _licensePlateController,
                decoration: const InputDecoration(
                  labelText: 'Rekisteritunnus',
                  hintText: 'ABC-123',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(
                  labelText: 'Merkki',
                  hintText: 'Esim. Toyota, Volkswagen',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Malli',
                  hintText: 'Esim. Corolla, Golf',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(
                  labelText: 'Vuosimalli',
                  hintText: '2020',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'Väri',
                  hintText: 'Esim. Musta, Valkoinen',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  widget.vehicle == null ? 'Lisää auto' : 'Tallenna muutokset',
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
