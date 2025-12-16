import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';
import 'dart:io';
import '../providers/trip_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/subscription_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/reminder_provider.dart';
import '../models/trip.dart';
import '../models/expense.dart';
import '../config/theme.dart';
import 'subscription_page.dart';
import 'reminders_page.dart';
import 'add_vehicle_page.dart';
import 'vehicle_selector_page.dart';
import 'feedback_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asetukset'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThemeToggle(context),
            const SizedBox(height: 20),
            _buildVehicleManagement(context),
            const SizedBox(height: 20),
            _buildRemindersSection(context),
            const SizedBox(height: 20),
            _buildFeedbackSection(context),
            const SizedBox(height: 20),
            _buildPremiumBanner(context),
            const SizedBox(height: 20),
            _buildStatistics(context),
            const SizedBox(height: 20),
            _buildTripsBackup(context),
            const SizedBox(height: 20),
            _buildExpensesBackup(context),
            const SizedBox(height: 20),
            _buildAppInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Card(
      color: subscriptionProvider.isPremium ? AppTheme.primaryRed : AppTheme.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.star,
                color: subscriptionProvider.isPremium ? Colors.white : AppTheme.primaryRed,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscriptionProvider.isPremium ? 'Premium-jäsen' : 'Päivitä Premium-jäseneksi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: subscriptionProvider.isPremium ? Colors.white : AppTheme.textDark,
                      ),
                    ),
                    Text(
                      subscriptionProvider.isPremium 
                          ? 'Kiitos tuestasi!' 
                          : 'Ilmainen 30 päivän kokeilu',
                      style: TextStyle(
                        fontSize: 14,
                        color: subscriptionProvider.isPremium 
                            ? Colors.white.withOpacity(0.9) 
                            : AppTheme.mediumGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: subscriptionProvider.isPremium ? Colors.white : AppTheme.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Card(
      child: SwitchListTile(
        title: const Text(
          'Tumma tila',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('Käytä tummaa teemaa'),
        secondary: Icon(
          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          size: 32,
        ),
        value: themeProvider.isDarkMode,
        onChanged: (value) {
          themeProvider.toggleTheme();
        },
      ),
    );
  }

  Widget _buildVehicleManagement(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();
    final selectedVehicle = vehicleProvider.selectedVehicle;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Autot',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            if (selectedVehicle != null) ...[
              ListTile(
                leading: const Icon(Icons.directions_car, size: 32),
                title: Text(
                  selectedVehicle.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: selectedVehicle.licensePlate != null 
                    ? Text(selectedVehicle.licensePlate!)
                    : null,
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const Divider(),
            ],
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VehicleSelectorPage(isInitialSetup: false),
                        ),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Vaihda autoa'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddVehiclePage()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Lisää auto'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemindersSection(BuildContext context) {
    final reminderProvider = context.watch<ReminderProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();
    final tripProvider = context.watch<TripProvider>();
    
    final selectedVehicle = vehicleProvider.selectedVehicle;
    final activeReminders = selectedVehicle != null
        ? reminderProvider.getActiveReminders(
            selectedVehicle.id!,
            tripProvider.totalKilometers,
          )
        : <dynamic>[];

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RemindersPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  const Icon(Icons.notifications, size: 32),
                  if (activeReminders.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          activeReminders.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Muistutukset',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      activeReminders.isEmpty
                          ? 'Ei aktiivisia muistutuksia'
                          : '${activeReminders.length} aktiivista muistutusta',
                      style: TextStyle(
                        color: activeReminders.isEmpty ? AppTheme.mediumGray : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.mediumGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackPage()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.feedback,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anna palautetta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Kerro meille mielipiteesi sovelluksesta',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: AppTheme.mediumGray),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tilastot',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _StatRow(
              label: 'Työmatkat',
              value: '${tripProvider.trips.where((t) => t.tripType == "work").length}',
            ),
            _StatRow(
              label: 'Yksityismatkat',
              value: '${tripProvider.trips.where((t) => t.tripType == "private").length}',
            ),
            const Divider(),
            _StatRow(
              label: 'Kulut yhteensä',
              value: '${expenseProvider.expenses.length}',
            ),
            _StatRow(
              label: 'Kokonaissumma',
              value: '${expenseProvider.totalExpenses.toStringAsFixed(2)} €',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsBackup(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MATKAT - Varmuuskopiointi',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _BackupButton(
              icon: Icons.upload_file,
              label: 'Vie CSV',
              onPressed: () => _exportTripsCSV(context),
            ),
            _BackupButton(
              icon: Icons.download,
              label: 'Tuo CSV',
              onPressed: () => _importTripsCSV(context),
            ),
            _BackupButton(
              icon: Icons.save,
              label: 'Luo varmuuskopio',
              onPressed: () => _createTripsBackup(context),
            ),
            _BackupButton(
              icon: Icons.restore,
              label: 'Palauta varmuuskopio',
              onPressed: () => _restoreTripsBackup(context),
            ),
            const Divider(),
            _BackupButton(
              icon: Icons.delete_forever,
              label: 'Poista kaikki matkatiedot',
              onPressed: () => _deleteAllTrips(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesBackup(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'KULUT - Varmuuskopiointi',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            _BackupButton(
              icon: Icons.upload_file,
              label: 'Vie CSV',
              onPressed: () => _exportExpensesCSV(context),
            ),
            _BackupButton(
              icon: Icons.download,
              label: 'Tuo CSV',
              onPressed: () => _importExpensesCSV(context),
            ),
            _BackupButton(
              icon: Icons.save,
              label: 'Luo varmuuskopio (sis. kuitit)',
              onPressed: () => _createExpensesBackup(context),
            ),
            _BackupButton(
              icon: Icons.restore,
              label: 'Palauta varmuuskopio',
              onPressed: () => _restoreExpensesBackup(context),
            ),
            const Divider(),
            _BackupButton(
              icon: Icons.delete_forever,
              label: 'Poista kaikki kulutiedot ja kuitit',
              onPressed: () => _deleteAllExpenses(context),
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ohjetiedot',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),
            const _StatRow(label: 'Versio', value: '1.0.0'),
            const SizedBox(height: 8),
            const Text(
              'Ajopäiväkirja-sovellus ajokilometrien ja autokulujen seurantaan.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // CSV Export/Import for Trips
  Future<void> _exportTripsCSV(BuildContext context) async {
    try {
      final tripProvider = context.read<TripProvider>();
      final trips = tripProvider.trips;

      if (trips.isEmpty) {
        _showMessage(context, 'Ei matkoja vietäväksi');
        return;
      }

      List<List<dynamic>> rows = [
        ['Päivämäärä', 'Tyyppi', 'Alku km', 'Loppu km', 'Lähtöosoite', 
         'Kohdeosoite', 'Lähtö lat', 'Lähtö lon', 'Kohde lat', 'Kohde lon', 'Lisätiedot']
      ];

      for (var trip in trips) {
        rows.add([
          trip.date.toIso8601String(),
          trip.tripType,
          trip.startOdometer,
          trip.endOdometer,
          trip.startAddress ?? '',
          trip.endAddress ?? '',
          trip.startLat ?? '',
          trip.startLon ?? '',
          trip.endLat ?? '',
          trip.endLon ?? '',
          trip.notes ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/matkat_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Matkat CSV');
      _showMessage(context, 'CSV viety onnistuneesti');
    } catch (e) {
      _showMessage(context, 'Virhe viennissä: $e');
    }
  }

  Future<void> _importTripsCSV(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      
      if (rows.isEmpty) {
        _showMessage(context, 'Tyhjä CSV-tiedosto');
        return;
      }

      // Skip header row
      final tripProvider = context.read<TripProvider>();
      int imported = 0;
      
      for (var i = 1; i < rows.length; i++) {
        try {
          final trip = Trip.fromCsvRow(rows[i]);
          await tripProvider.addTrip(trip);
          imported++;
        } catch (e) {
          print('Error importing row $i: $e');
        }
      }

      _showMessage(context, 'Tuotu $imported matkaa');
    } catch (e) {
      _showMessage(context, 'Virhe tuonnissa: $e');
    }
  }

  Future<void> _createTripsBackup(BuildContext context) async {
    try {
      final tripProvider = context.read<TripProvider>();
      final trips = tripProvider.trips;

      if (trips.isEmpty) {
        _showMessage(context, 'Ei matkoja varmuuskopioitavaksi');
        return;
      }

      List<List<dynamic>> rows = [
        ['Päivämäärä', 'Tyyppi', 'Alku km', 'Loppu km', 'Lähtöosoite', 
         'Kohdeosoite', 'Lähtö lat', 'Lähtö lon', 'Kohde lat', 'Kohde lon', 'Lisätiedot']
      ];

      for (var trip in trips) {
        rows.add([
          trip.date.toIso8601String(),
          trip.tripType,
          trip.startOdometer,
          trip.endOdometer,
          trip.startAddress ?? '',
          trip.endAddress ?? '',
          trip.startLat ?? '',
          trip.startLon ?? '',
          trip.endLat ?? '',
          trip.endLon ?? '',
          trip.notes ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/matkat_backup_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Matkat varmuuskopio');
      _showMessage(context, 'Varmuuskopio luotu');
    } catch (e) {
      _showMessage(context, 'Virhe: $e');
    }
  }

  Future<void> _restoreTripsBackup(BuildContext context) async {
    await _importTripsCSV(context);
  }

  Future<void> _deleteAllTrips(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista kaikki matkat'),
        content: const Text('Haluatko varmasti poistaa kaikki matkatiedot? Tätä toimintoa ei voi perua.'),
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

    if (confirm == true) {
      await context.read<TripProvider>().deleteAllTrips();
      if (context.mounted) {
        _showMessage(context, 'Kaikki matkat poistettu');
      }
    }
  }

  // CSV Export/Import for Expenses
  Future<void> _exportExpensesCSV(BuildContext context) async {
    try {
      final expenseProvider = context.read<ExpenseProvider>();
      final expenses = expenseProvider.expenses;

      if (expenses.isEmpty) {
        _showMessage(context, 'Ei kuluja vietäväksi');
        return;
      }

      List<List<dynamic>> rows = [
        ['Päivämäärä', 'Kategoria', 'Summa', 'Yritys', 'Litrat', 
         'Hinta/litra', 'Kuitti', 'Lisätiedot']
      ];

      for (var expense in expenses) {
        rows.add([
          expense.date.toIso8601String(),
          expense.category,
          expense.amount,
          expense.company ?? '',
          expense.liters ?? '',
          expense.pricePerLiter ?? '',
          expense.receiptPath ?? '',
          expense.notes ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/kulut_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(file.path)], text: 'Kulut CSV');
      _showMessage(context, 'CSV viety onnistuneesti');
    } catch (e) {
      _showMessage(context, 'Virhe viennissä: $e');
    }
  }

  Future<void> _importExpensesCSV(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();
      
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      
      if (rows.isEmpty) {
        _showMessage(context, 'Tyhjä CSV-tiedosto');
        return;
      }

      final expenseProvider = context.read<ExpenseProvider>();
      int imported = 0;
      
      for (var i = 1; i < rows.length; i++) {
        try {
          final expense = Expense.fromCsvRow(rows[i]);
          await expenseProvider.addExpense(expense);
          imported++;
        } catch (e) {
          print('Error importing row $i: $e');
        }
      }

      _showMessage(context, 'Tuotu $imported kulua');
    } catch (e) {
      _showMessage(context, 'Virhe tuonnissa: $e');
    }
  }

  Future<void> _createExpensesBackup(BuildContext context) async {
    try {
      final expenseProvider = context.read<ExpenseProvider>();
      final expenses = expenseProvider.expenses;

      if (expenses.isEmpty) {
        _showMessage(context, 'Ei kuluja varmuuskopioitavaksi');
        return;
      }

      // Create archive
      final archive = Archive();

      // Add CSV
      List<List<dynamic>> rows = [
        ['Päivämäärä', 'Kategoria', 'Summa', 'Yritys', 'Litrat', 
         'Hinta/litra', 'Kuitti', 'Lisätiedot']
      ];

      for (var expense in expenses) {
        rows.add([
          expense.date.toIso8601String(),
          expense.category,
          expense.amount,
          expense.company ?? '',
          expense.liters ?? '',
          expense.pricePerLiter ?? '',
          expense.receiptPath ?? '',
          expense.notes ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);
      archive.addFile(ArchiveFile('expenses.csv', csv.length, csv.codeUnits));

      // Add receipts
      for (var expense in expenses) {
        if (expense.receiptPath != null) {
          final receiptFile = File(expense.receiptPath!);
          if (await receiptFile.exists()) {
            final bytes = await receiptFile.readAsBytes();
            final fileName = expense.receiptPath!.split('/').last;
            archive.addFile(ArchiveFile('receipts/$fileName', bytes.length, bytes));
          }
        }
      }

      // Encode archive
      final zipData = ZipEncoder().encode(archive);
      
      if (zipData != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/kulut_backup_${DateTime.now().millisecondsSinceEpoch}.zip');
        await file.writeAsBytes(zipData);

        await Share.shareXFiles([XFile(file.path)], text: 'Kulut varmuuskopio');
        _showMessage(context, 'Varmuuskopio luotu (sisältää kuitit)');
      }
    } catch (e) {
      _showMessage(context, 'Virhe: $e');
    }
  }

  Future<void> _restoreExpensesBackup(BuildContext context) async {
    // For simplicity, just import CSV
    await _importExpensesCSV(context);
  }

  Future<void> _deleteAllExpenses(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Poista kaikki kulut'),
        content: const Text('Haluatko varmasti poistaa kaikki kulutiedot ja kuitit? Tätä toimintoa ei voi perua.'),
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

    if (confirm == true) {
      // Delete receipts
      final expenseProvider = context.read<ExpenseProvider>();
      final expenses = expenseProvider.expenses;
      
      for (var expense in expenses) {
        if (expense.receiptPath != null) {
          try {
            final file = File(expense.receiptPath!);
            if (await file.exists()) {
              await file.delete();
            }
          } catch (e) {
            print('Error deleting receipt: $e');
          }
        }
      }

      await expenseProvider.deleteAllExpenses();
      
      if (context.mounted) {
        _showMessage(context, 'Kaikki kulut ja kuitit poistettu');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _BackupButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;

  const _BackupButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: isDestructive ? Colors.red : null),
          label: Text(
            label,
            style: TextStyle(color: isDestructive ? Colors.red : null),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDestructive ? Colors.red : AppTheme.mediumGray,
            ),
          ),
        ),
      ),
    );
  }
}
