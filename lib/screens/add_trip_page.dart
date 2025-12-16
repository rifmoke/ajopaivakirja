import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../providers/trip_provider.dart';
import '../providers/vehicle_provider.dart';
import '../providers/subscription_provider.dart';
import '../config/theme.dart';
import '../screens/subscription_page.dart';

class AddTripPage extends StatefulWidget {
  const AddTripPage({super.key});

  @override
  State<AddTripPage> createState() => _AddTripPageState();
}

class _AddTripPageState extends State<AddTripPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _tripType = 'work';
  final _startOdometerController = TextEditingController();
  final _endOdometerController = TextEditingController();
  final _startAddressController = TextEditingController();
  final _endAddressController = TextEditingController();
  final _notesController = TextEditingController();
  
  double? _startLat;
  double? _startLon;
  double? _endLat;
  double? _endLon;
  
  bool _isLoadingLocation = false;

  @override
  void dispose() {
    _startOdometerController.dispose();
    _endOdometerController.dispose();
    _startAddressController.dispose();
    _endAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation(bool isStart) async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sijaintilupa evätty')),
            );
          }
          return;
        }
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final address = '${place.street}, ${place.locality}';
        
        setState(() {
          if (isStart) {
            _startAddressController.text = address;
            _startLat = position.latitude;
            _startLon = position.longitude;
          } else {
            _endAddressController.text = address;
            _endLat = position.latitude;
            _endLon = position.longitude;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Virhe sijaintia haettaessa: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
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

  void _saveTrip() async {
    if (_formKey.currentState!.validate()) {
      // Tarkista Premium-tilaus
      final subscriptionProvider = context.read<SubscriptionProvider>();
      
      if (!subscriptionProvider.isPremium) {
        // Näytä dialogi Premium-tilauksen vaatimisesta
        if (mounted) {
          final result = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Premium-tilaus vaaditaan'),
                content: const Text(
                  'Ilmainen kokeilujakso on päättynyt.\n\n'
                  'Matkojen kirjaus vaatii Premium-tilauksen. '
                  'Voit kuitenkin tallentaa ja viedä olemassa olevat tietosi.\n\n'
                  'Haluatko tilata Premium-jäsenyyden?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Peruuta'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryRed,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Näytä Premium'),
                  ),
                ],
              );
            },
          );
          
          if (result == true && mounted) {
            // Siirry Premium-sivulle
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SubscriptionPage()),
            );
          }
        }
        return;
      }
      
      final vehicleProvider = context.read<VehicleProvider>();
      final selectedVehicle = vehicleProvider.selectedVehicle;
      
      final trip = Trip(
        date: _selectedDate,
        tripType: _tripType,
        startOdometer: int.parse(_startOdometerController.text),
        endOdometer: int.parse(_endOdometerController.text),
        startAddress: _startAddressController.text.isNotEmpty 
            ? _startAddressController.text 
            : null,
        endAddress: _endAddressController.text.isNotEmpty 
            ? _endAddressController.text 
            : null,
        startLat: _startLat,
        startLon: _startLon,
        endLat: _endLat,
        endLon: _endLon,
        notes: _notesController.text.isNotEmpty 
            ? _notesController.text 
            : null,
        vehicleId: selectedVehicle?.id,
      );

      await context.read<TripProvider>().addTrip(trip);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Matka tallennettu!')),
        );
        
        // Clear form
        _startOdometerController.clear();
        _endOdometerController.clear();
        _startAddressController.clear();
        _endAddressController.clear();
        _notesController.clear();
        setState(() {
          _selectedDate = DateTime.now();
          _tripType = 'work';
          _startLat = null;
          _startLon = null;
          _endLat = null;
          _endLon = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirjaa matka'),
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

              // Trip type
              Text(
                'Matkatyyppi',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'work',
                    label: Text('Työajo'),
                    icon: Icon(Icons.work),
                  ),
                  ButtonSegment(
                    value: 'private',
                    label: Text('Yksityisajo'),
                    icon: Icon(Icons.home),
                  ),
                ],
                selected: {_tripType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _tripType = newSelection.first;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return _tripType == 'work' 
                          ? AppTheme.primaryRed 
                          : AppTheme.mediumGray;
                    }
                    return Colors.white;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white;
                    }
                    return AppTheme.textMedium;
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Odometer readings
              Text(
                'Matkamittarilukema',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startOdometerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Alku (km)',
                        prefixIcon: Icon(Icons.play_arrow),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pakollinen';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Virheellinen';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _endOdometerController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Loppu (km)',
                        prefixIcon: Icon(Icons.stop),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pakollinen';
                        }
                        final end = int.tryParse(value);
                        final start = int.tryParse(_startOdometerController.text);
                        if (end == null) {
                          return 'Virheellinen';
                        }
                        if (start != null && end <= start) {
                          return 'Pienempi kuin alku';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              
              // Distance calculation
              if (_startOdometerController.text.isNotEmpty && 
                  _endOdometerController.text.isNotEmpty)
                Builder(
                  builder: (context) {
                    final start = int.tryParse(_startOdometerController.text);
                    final end = int.tryParse(_endOdometerController.text);
                    if (start != null && end != null && end > start) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Matka: ${end - start} km',
                          style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              const SizedBox(height: 24),

              // Addresses
              Text(
                'Osoitteet',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _startAddressController,
                decoration: InputDecoration(
                  labelText: 'Lähtöosoite',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: _isLoadingLocation 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, color: AppTheme.primaryRed),
                    onPressed: _isLoadingLocation 
                        ? null 
                        : () => _getCurrentLocation(true),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _endAddressController,
                decoration: InputDecoration(
                  labelText: 'Kohdeosoite',
                  prefixIcon: const Icon(Icons.location_on),
                  suffixIcon: IconButton(
                    icon: _isLoadingLocation 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location, color: AppTheme.primaryRed),
                    onPressed: _isLoadingLocation 
                        ? null 
                        : () => _getCurrentLocation(false),
                  ),
                ),
              ),
              const SizedBox(height: 24),

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
                  onPressed: _saveTrip,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Tallenna matka'),
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
