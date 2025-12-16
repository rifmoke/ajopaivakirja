import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vehicle.dart';
import '../services/database_helper.dart';

class VehicleProvider with ChangeNotifier {
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  bool _isLoading = false;

  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;

  Future<void> loadVehicles() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vehicles = await DatabaseHelper.instance.getAllVehicles();
      
      // Load selected vehicle from preferences
      final prefs = await SharedPreferences.getInstance();
      final selectedId = prefs.getInt('selectedVehicleId');
      
      if (selectedId != null) {
        _selectedVehicle = _vehicles.firstWhere(
          (v) => v.id == selectedId,
          orElse: () => _vehicles.isNotEmpty ? _vehicles.first : _vehicles.first,
        );
      } else if (_vehicles.isNotEmpty) {
        _selectedVehicle = _vehicles.first;
        await selectVehicle(_selectedVehicle!);
      }
    } catch (e) {
      print('Error loading vehicles: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle(Vehicle vehicle) async {
    try {
      final id = await DatabaseHelper.instance.insertVehicle(vehicle);
      await loadVehicles();
      
      // Auto-select if it's the first vehicle
      if (_vehicles.length == 1) {
        await selectVehicle(_vehicles.first);
      }
    } catch (e) {
      print('Error adding vehicle: $e');
    }
  }

  Future<void> updateVehicle(Vehicle vehicle) async {
    try {
      await DatabaseHelper.instance.updateVehicle(vehicle);
      await loadVehicles();
    } catch (e) {
      print('Error updating vehicle: $e');
    }
  }

  Future<void> deleteVehicle(int id) async {
    try {
      await DatabaseHelper.instance.deleteVehicle(id);
      await loadVehicles();
      
      // Select another vehicle if the deleted one was selected
      if (_selectedVehicle?.id == id && _vehicles.isNotEmpty) {
        await selectVehicle(_vehicles.first);
      } else if (_vehicles.isEmpty) {
        _selectedVehicle = null;
      }
    } catch (e) {
      print('Error deleting vehicle: $e');
    }
  }

  Future<void> selectVehicle(Vehicle vehicle) async {
    _selectedVehicle = vehicle;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedVehicleId', vehicle.id!);
    notifyListeners();
  }
}
