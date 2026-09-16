import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../../../profile/domain/usecases/get_profile_usecase.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class SearchTripsScreen extends StatefulWidget {
  final TripProvider tripProvider;

  const SearchTripsScreen({
    super.key,
    required this.tripProvider,
  });

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final TextEditingController departureController =
      TextEditingController();

  final TextEditingController arrivalController =
      TextEditingController();

  DateTime? selectedDate;

  final GetProfileUseCase _getProfileUseCase =
      Injector.createProfileProvider().getProfileUseCase;

  final Map<String, Future<String>> _driverNames = {};

  @override
  void initState() {
    super.initState();

    widget.tripProvider.addListener(_onProviderChanged);
    widget.tripProvider.searchTrips();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    widget.tripProvider.removeListener(_onProviderChanged);
    departureController.dispose();
    arrivalController.dispose();
    super.dispose();
  }

  Future<String> _driverName(String driverId) {
    return _driverNames.putIfAbsent(driverId, () async {
      try {
        final profile = await _getProfileUseCase(driverId);
        return profile.name;
      } catch (_) {
        return 'Conducteur';
      }
    });
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 90),
      ),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      selectedDate = pickedDate;
    });
  }

  void _search() {
    widget.tripProvider.searchTrips(
      departure: departureController.text,
      arrival: arrivalController.text,
      date: selectedDate,
    );
  }

  void _openTrip(TripEntity trip, String driverName) {
    final user = Injector.authProvider.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour réserver un trajet.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailScreen(
          tripId: trip.id,
          driverId: trip.driverId,
          driverName: driverName,
          departure: trip.departure,
          arrival: trip.arrival,
          date: _formatDate(trip.departureDateTime),
          departureTime: _formatTime(trip.departureDateTime),
          duration: '—',
          availableSeats: trip.availableSeats,
          price: trip.pricePerSeat,
          rating: 0,
          bookingProvider: Injector.createBookingProvider(),
          passengerId: user.uid,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final trips = widget.tripProvider.searchResults;

    return Scaffold(
      drawer: AppDrawer(authProvider: Injector.authProvider),
      appBar: AppBar(
        title: const Text('Rechercher un trajet'),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de recherche
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: departureController,
                  decoration: const InputDecoration(
                    labelText: 'Départ',
                    prefixIcon: Icon(
                      Icons.radio_button_checked,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: arrivalController,
                  decoration: const InputDecoration(
                    labelText: 'Arrivée',
                    prefixIcon: Icon(
                      Icons.location_on,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _selectDate,
                        icon: const Icon(
                          Icons.calendar_today,
                        ),
                        label: Text(
                          selectedDate == null
                              ? 'Choisir une date'
                              : _formatDate(selectedDate!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search),
                        label: const Text('Rechercher'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          if (widget.tripProvider.errorMessage != null && trips.isEmpty)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    widget.tripProvider.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            // Liste des trajets
            Expanded(
              child: trips.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun trajet trouvé.',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: trips.length,
                      itemBuilder: (context, index) {
                        final trip = trips[index];

                        return FutureBuilder<String>(
                          future: _driverName(trip.driverId),
                          builder: (context, snapshot) {
                            final driverName =
                                snapshot.data ?? 'Conducteur';

                            return TripCard(
                              tripId: trip.id,
                              driverName: driverName,
                              departure: trip.departure,
                              arrival: trip.arrival,
                              departureTime:
                                  _formatTime(trip.departureDateTime),
                              duration: '—',
                              availableSeats: trip.availableSeats,
                              price: trip.pricePerSeat,
                              rating: 0,
                              date: _formatDate(trip.departureDateTime),
                              onTap: () => _openTrip(trip, driverName),
                            );
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
