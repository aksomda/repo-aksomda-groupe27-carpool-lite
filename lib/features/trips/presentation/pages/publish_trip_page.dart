import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/trip.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../data/datasources/trips_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../controllers/trip_controller.dart';

import '../../domain/usecases/search_trips.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/cancel_trip.dart';

class PublishTripPage extends StatefulWidget {
  const PublishTripPage({super.key});

  @override
  State<PublishTripPage> createState() => _PublishTripPageState();
}

class _PublishTripPageState extends State<PublishTripPage> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _universityController = TextEditingController();
  final _seatsController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  late final TripController _controller;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;
    final remoteDataSource = TripsRemoteDataSource(firestore);
    final repository = TripRepositoryImpl(remoteDataSource);

    _controller = TripController(
      publishTrip: PublishTrip(repository),
      searchTrips: SearchTrips(repository),
      getTripHistory: GetTripHistory(repository),
      cancelTrip: CancelTrip(repository),
    );
  }

  @override
  void dispose() {
    _departureController.dispose();
    _universityController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _publish() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date et une heure.')));
      return;
    }

    final departureDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final trip = Trip(
      id: '',
      driverId: 'CURRENT_USER_ID',
      departureLocation: const GeoPoint(12.3714, -1.5197),
      departureLabel: _departureController.text.trim(),
      universityId: _universityController.text.trim(),
      departureDateTime: departureDateTime,
      availableSeats: int.parse(_seatsController.text),
      pricePerSeat: double.parse(_priceController.text),
      status: TripStatus.available,
    );

    await _controller.publish(trip);

    if (!mounted) return;

    if (_controller.errorMessage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trajet publié avec succès !')));

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Publier un trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _departureController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de départ',
                  hintText: 'Ex : Patte d’Oie',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir le lieu de départ.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  labelText: 'Université',
                  hintText: 'Ex : Université Joseph KI-ZERBO',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez saisir l’université.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Choisir une date'
                      : '${_selectedDate!.day}/'
                            '${_selectedDate!.month}/'
                            '${_selectedDate!.year}',
                ),
                leading: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),

              ListTile(
                title: Text(
                  _selectedTime == null ? 'Choisir une heure' : _selectedTime!.format(context),
                ),
                leading: const Icon(Icons.access_time),
                onTap: _selectTime,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nombre de places',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final seats = int.tryParse(value ?? '');

                  if (seats == null || seats <= 0) {
                    return 'Entrez un nombre de places valide.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Prix par place',
                  suffixText: 'FCFA',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final price = double.tryParse(value ?? '');

                  if (price == null || price < 0) {
                    return 'Entrez un prix valide.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              ListenableBuilder(
                listenable: _controller,
                builder: (context, child) {
                  return FilledButton(
                    onPressed: _controller.isLoading ? null : _publish,

                    child: _controller.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Publier le trajet'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            context.go('/trips/publish');
          } else if (index == 1) {
            context.go('/trips/search');
          } else if (index == 2) {
            context.go('/trips/history');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publier'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }
}
