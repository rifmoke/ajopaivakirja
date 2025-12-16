import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../models/vehicle.dart';
import '../config/theme.dart';
import 'add_vehicle_page.dart';

class VehicleSelectorPage extends StatelessWidget {
  final bool isInitialSetup;

  const VehicleSelectorPage({super.key, this.isInitialSetup = false});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final vehicles = vehicleProvider.vehicles;

    return Scaffold(
      appBar: AppBar(
        title: Text(isInitialSetup ? 'Valitse auto' : 'Vaihda autoa'),
        automaticallyImplyLeading: !isInitialSetup,
      ),
      body: vehicles.isEmpty
          ? _buildEmptyState(context)
          : _buildVehicleList(context, vehicles, vehicleProvider),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddVehiclePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Lisää auto'),
        backgroundColor: AppTheme.primaryRed,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Ei autoja',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Aloita lisäämällä ensimmäinen autosi',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList(
    BuildContext context,
    List<Vehicle> vehicles,
    VehicleProvider vehicleProvider,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = vehicles[index];
        final isSelected = vehicleProvider.selectedVehicle?.id == vehicle.id;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              await vehicleProvider.selectVehicle(vehicle);
              if (context.mounted) {
                if (isInitialSetup) {
                  // Navigate to main app
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('Ladataan...')))),
                  );
                } else {
                  Navigator.pop(context);
                }
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected ? AppTheme.primaryRed : Colors.grey[300],
                    child: Icon(
                      Icons.directions_car,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (vehicle.licensePlate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            vehicle.licensePlate!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (vehicle.brand != null || vehicle.model != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[600],
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.primaryRed,
                      size: 32,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
