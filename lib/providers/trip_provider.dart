import 'package:flutter/foundation.dart';
import '../models/trip.dart';
import '../services/database_helper.dart';

class TripProvider with ChangeNotifier {
  List<Trip> _trips = [];
  bool _isLoading = false;

  List<Trip> get trips => _trips;
  bool get isLoading => _isLoading;

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = await DatabaseHelper.instance.getAllTrips();
    } catch (e) {
      print('Error loading trips: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTrip(Trip trip) async {
    try {
      final id = await DatabaseHelper.instance.insertTrip(trip);
      await loadTrips();
    } catch (e) {
      print('Error adding trip: $e');
    }
  }

  Future<void> updateTrip(Trip trip) async {
    try {
      await DatabaseHelper.instance.updateTrip(trip);
      await loadTrips();
    } catch (e) {
      print('Error updating trip: $e');
    }
  }

  Future<void> deleteTrip(int id) async {
    try {
      await DatabaseHelper.instance.deleteTrip(id);
      await loadTrips();
    } catch (e) {
      print('Error deleting trip: $e');
    }
  }

  Future<void> deleteAllTrips() async {
    try {
      await DatabaseHelper.instance.deleteAllTrips();
      await loadTrips();
    } catch (e) {
      print('Error deleting all trips: $e');
    }
  }

  // Statistics
  int get totalKilometers {
    return _trips.fold(0, (sum, trip) => sum + trip.distance);
  }

  int get monthKilometers {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);
    
    return _trips
        .where((trip) => trip.date.isAfter(monthStart) && trip.date.isBefore(monthEnd))
        .fold(0, (sum, trip) => sum + trip.distance);
  }

  int get workKilometers {
    return _trips
        .where((trip) => trip.tripType == 'work')
        .fold(0, (sum, trip) => sum + trip.distance);
  }

  int get privateKilometers {
    return _trips
        .where((trip) => trip.tripType == 'private')
        .fold(0, (sum, trip) => sum + trip.distance);
  }

  List<Trip> get recentTrips {
    return _trips.take(5).toList();
  }

  Map<DateTime, int> getWeeklyKilometers() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    
    Map<DateTime, int> weeklyData = {};
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayKm = _trips
          .where((trip) => trip.date.isAfter(dayStart) && trip.date.isBefore(dayEnd))
          .fold(0, (sum, trip) => sum + trip.distance);
      
      weeklyData[dayStart] = dayKm;
    }
    
    return weeklyData;
  }
}
