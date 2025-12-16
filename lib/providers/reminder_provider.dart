import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/database_helper.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  List<Reminder> getRemindersForVehicle(int vehicleId) {
    return _reminders.where((r) => r.vehicleId == vehicleId && !r.isCompleted).toList();
  }

  List<Reminder> getActiveReminders(int vehicleId, int currentMileage) {
    final now = DateTime.now();
    return _reminders.where((r) {
      if (r.vehicleId != vehicleId || r.isCompleted) return false;

      bool shouldNotify = false;

      // Check date-based trigger
      if ((r.trigger == ReminderTrigger.date || r.trigger == ReminderTrigger.both) &&
          r.targetDate != null &&
          r.notifyDaysBefore != null) {
        final notifyDate = r.targetDate!.subtract(Duration(days: r.notifyDaysBefore!));
        if (now.isAfter(notifyDate)) {
          shouldNotify = true;
        }
      }

      // Check mileage-based trigger
      if ((r.trigger == ReminderTrigger.mileage || r.trigger == ReminderTrigger.both) &&
          r.targetMileage != null &&
          r.notifyMileageBefore != null) {
        final notifyMileage = r.targetMileage! - r.notifyMileageBefore!;
        if (currentMileage >= notifyMileage) {
          shouldNotify = true;
        }
      }

      return shouldNotify;
    }).toList();
  }

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await DatabaseHelper.instance.getAllReminders();
    } catch (e) {
      print('Error loading reminders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      await DatabaseHelper.instance.insertReminder(reminder);
      await loadReminders();
    } catch (e) {
      print('Error adding reminder: $e');
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await DatabaseHelper.instance.updateReminder(reminder);
      await loadReminders();
    } catch (e) {
      print('Error updating reminder: $e');
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await DatabaseHelper.instance.deleteReminder(id);
      await loadReminders();
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  Future<void> completeReminder(int id) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == id);
      final completed = reminder.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await updateReminder(completed);
    } catch (e) {
      print('Error completing reminder: $e');
    }
  }
}
