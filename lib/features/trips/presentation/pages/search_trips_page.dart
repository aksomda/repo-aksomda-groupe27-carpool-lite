import 'package:flutter/material.dart';

import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../domain/usecases/search_trips.dart';
import '../../data/datasources/trips_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/trip_controller.dart';
import 'package:go_router/go_router.dart';

class SearchTripsPage extends StatefulWidget {
  const SearchTripsPage({super.key});

  @override
  State<SearchTripsPage> createState() => _SearchTripsPageState();
}

class _SearchTripsPageState extends State<SearchTripsPage> {
  final _formKey = GlobalKey<FormState>();

  final _departureController = TextEditingController();
  final _universityController = TextEditingController();

  DateTime? _selectedDate;

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

    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _departureController.dispose();
    _universityController.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();

    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Veuillez sélectionner une date.')));
      return;
    }

    await _controller.search(
      departureLabel: _departureController.text.trim(),
      universityId: _universityController.text.trim(),
      date: _selectedDate!,
    );

    if (!mounted) return;

    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rechercher un trajet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _departureController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de départ',
                  hintText: 'Ex : Patte d’Oie',
                  prefixIcon: Icon(Icons.location_on),
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
                  prefixIcon: Icon(Icons.school),
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

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDate == null
                        ? 'Choisir une date'
                        : '${_selectedDate!.day}/'
                              '${_selectedDate!.month}/'
                              '${_selectedDate!.year}',
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _controller.isLoading ? null : _search,
                  icon: const Icon(Icons.search),
                  label: const Text('Rechercher'),
                ),
              ),

              const SizedBox(height: 24),

              Expanded(child: _buildResults()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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

  Widget _buildResults() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.trips.isEmpty) {
      return const Center(child: Text('Aucun trajet trouvé.', style: TextStyle(fontSize: 16)));
    }

    return ListView.builder(
      itemCount: _controller.trips.length,
      itemBuilder: (context, index) {
        final trip = _controller.trips[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.directions_car)),
            title: Text(trip.departureLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),

                Text(
                  'Date : '
                  '${trip.departureDateTime.day}/'
                  '${trip.departureDateTime.month}/'
                  '${trip.departureDateTime.year}',
                ),

                Text(
                  'Heure : '
                  '${trip.departureDateTime.hour.toString().padLeft(2, '0')}:'
                  '${trip.departureDateTime.minute.toString().padLeft(2, '0')}',
                ),

                Text(
                  'Places disponibles : '
                  '${trip.availableSeats}',
                ),

                Text(
                  'Prix : '
                  '${trip.pricePerSeat.toStringAsFixed(0)} FCFA',
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
