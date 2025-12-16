import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/trip_provider.dart';
import '../models/reminder.dart';
import '../config/theme.dart';
import 'add_reminder_page.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final reminderProvider = context.watch<ReminderProvider>();
    final tripProvider = context.watch<TripProvider>();
    
    final selectedVehicle = vehicleProvider.selectedVehicle;
    if (selectedVehicle == null) {
      return const Scaffold(
        body: Center(child: Text('Valitse ensin auto')),
      );
    }

    final reminders = reminderProvider.getRemindersForVehicle(selectedVehicle.id!);
    final currentMileage = tripProvider.totalKilometers;
    final activeReminders = reminderProvider.getActiveReminders(selectedVehicle.id!, currentMileage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Muistutukset'),
      ),
      body: reminders.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activeReminders.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Aktiiviset muistutukset', activeReminders.length),
                    const SizedBox(height: 8),
                    ...activeReminders.map((r) => _buildReminderCard(context, r, currentMileage, true)),
                    const SizedBox(height: 24),
                  ],
                  _buildSectionTitle(context, 'Kaikki muistutukset', reminders.length),
                  const SizedBox(height: 8),
                  ...reminders.map((r) => _buildReminderCard(context, r, currentMileage, false)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminderPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Lisää muistutus'),
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
              Icons.notifications_none,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Ei muistutuksia',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Lisää muistutuksia katsastuksista, huolloista ja muista tärkeistä asioista',
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

  Widget _buildSectionTitle(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderCard(BuildContext context, Reminder reminder, int currentMileage, bool isActive) {
    final now = DateTime.now();
    bool isOverdue = false;
    String statusText = '';
    Color statusColor = Colors.grey;

    if (reminder.trigger == ReminderTrigger.date || reminder.trigger == ReminderTrigger.both) {
      if (reminder.targetDate != null) {
        final daysRemaining = reminder.targetDate!.difference(now).inDays;
        if (daysRemaining < 0) {
          isOverdue = true;
          statusText = 'Myöhässä ${-daysRemaining} päivää';
          statusColor = Colors.red;
        } else if (daysRemaining <= (reminder.notifyDaysBefore ?? 0)) {
          statusText = '$daysRemaining päivää jäljellä';
          statusColor = Colors.orange;
        }
      }
    }

    if (reminder.trigger == ReminderTrigger.mileage || reminder.trigger == ReminderTrigger.both) {
      if (reminder.targetMileage != null) {
        final kmRemaining = reminder.targetMileage! - currentMileage;
        if (kmRemaining < 0) {
          isOverdue = true;
          if (statusText.isEmpty) {
            statusText = 'Ylitetty ${-kmRemaining} km';
            statusColor = Colors.red;
          }
        } else if (kmRemaining <= (reminder.notifyMileageBefore ?? 0)) {
          if (statusText.isEmpty) {
            statusText = '$kmRemaining km jäljellä';
            statusColor = Colors.orange;
          }
        }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isActive ? Colors.orange[50] : null,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddReminderPage(reminder: reminder)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTypeColor(reminder.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getTypeIcon(reminder.type),
                      color: _getTypeColor(reminder.type),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reminder.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          Reminder.getTypeLabel(reminder.type),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isActive)
                    Icon(Icons.notification_important, color: statusColor, size: 28),
                ],
              ),
              if (reminder.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  reminder.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              const SizedBox(height: 12),
              if (reminder.targetDate != null)
                _buildInfoRow(
                  Icons.calendar_today,
                  'Päivämäärä: ${DateFormat('dd.MM.yyyy').format(reminder.targetDate!)}',
                ),
              if (reminder.targetMileage != null)
                _buildInfoRow(
                  Icons.speed,
                  'Kilometrit: ${reminder.targetMileage} km',
                ),
              if (statusText.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isOverdue ? Icons.warning : Icons.info,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(ReminderType type) {
    switch (type) {
      case ReminderType.inspection:
        return Colors.blue;
      case ReminderType.service:
        return Colors.orange;
      case ReminderType.insurance:
        return Colors.green;
      case ReminderType.tax:
        return Colors.purple;
      case ReminderType.tireChange:
        return Colors.brown;
      case ReminderType.other:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.inspection:
        return Icons.verified;
      case ReminderType.service:
        return Icons.build;
      case ReminderType.insurance:
        return Icons.shield;
      case ReminderType.tax:
        return Icons.payment;
      case ReminderType.tireChange:
        return Icons.tire_repair;
      case ReminderType.other:
        return Icons.notifications;
    }
  }
}
