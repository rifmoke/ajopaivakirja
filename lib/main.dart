import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/trip_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/subscription_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/reminder_provider.dart';
import 'screens/home_page.dart';
import 'screens/add_trip_page.dart';
import 'screens/expenses_page.dart';
import 'screens/settings_page.dart';
import 'screens/history_page.dart';
import 'screens/vehicle_selector_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => TripProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Ajopäiväkirja',
            theme: themeProvider.theme,
            home: const AppInitializer(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await context.read<VehicleProvider>().loadVehicles();
    await context.read<ReminderProvider>().loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleProvider = context.watch<VehicleProvider>();

    if (vehicleProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show vehicle selector if no vehicle is selected
    if (vehicleProvider.selectedVehicle == null) {
      return const VehicleSelectorPage(isInitialSetup: true);
    }

    return const MainNavigator();
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const AddTripPage(),
    const ExpensesPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.primaryColor, width: 2),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Etusivu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle),
              label: 'Kirjaa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.euro),
              label: 'Kulut',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Asetukset',
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryPage()),
                );
              },
              backgroundColor: theme.primaryColor,
              child: const Icon(Icons.history),
            )
          : null,
    );
  }
}
