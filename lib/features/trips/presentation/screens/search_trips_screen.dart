import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/network/maps_api_client.dart';
import '../../../favorites/presentation/providers/favorite_provider.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class SearchTripsScreen extends StatefulWidget {
  final String? initialDeparture;
  final String? initialArrival;
  final String? initialDate;
  final int? initialPassengers;

  const SearchTripsScreen({
    super.key,
    this.initialDeparture,
    this.initialArrival,
    this.initialDate,
    this.initialPassengers,
  });

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final TextEditingController departureController = TextEditingController();
  final TextEditingController arrivalController = TextEditingController();

  String? selectedDate;

  @override
  void initState() {
    super.initState();
    departureController.text = widget.initialDeparture ?? '';
    arrivalController.text = widget.initialArrival ?? '';

    if (widget.initialDate != null && widget.initialDate!.isNotEmpty) {
      selectedDate = _formatDateValue(widget.initialDate!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _search();

      // Charge les favoris de l'utilisateur pour que le cœur de chaque
      // trajet reflète immédiatement le bon état.
      context.read<FavoriteProvider>().loadFavorites(_currentUserId);
    });
  }

  String _formatDateValue(String dateValue) {
    try {
      final parsedDate = DateTime.parse(dateValue);
      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year}';
    } catch (_) {
      return dateValue;
    }
  }

  DateTime? _parsedSelectedDate() {
    if (selectedDate == null || selectedDate!.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(selectedDate!);
    } catch (_) {
      final parts = selectedDate!.split('/');
      if (parts.length == 3) {
        final day = int.tryParse(parts[0]);
        final month = int.tryParse(parts[1]);
        final year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          return DateTime(year, month, day);
        }
      }
    }

    return null;
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String get _currentUserId => Injector.authProvider.user?.uid ?? '';

  /// Durée estimée du trajet à partir des coordonnées enregistrées.
  /// Affiche « - » si le trajet n'a pas de position exploitable.
  String _estimatedDuration(TripEntity trip) {
    final estimate = MapsApiClient.estimateRoute(
      startLatitude: trip.departureLatitude,
      startLongitude: trip.departureLongitude,
      endLatitude: trip.arrivalLatitude,
      endLongitude: trip.arrivalLongitude,
    );

    return estimate?.formattedDuration ?? '-';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  List<TripEntity> _visibleTrips(List<TripEntity> trips) {
    final minSeats = widget.initialPassengers;
    if (minSeats == null) {
      return trips;
    }

    return trips
        .where((trip) => trip.availableSeats >= minSeats)
        .toList();
  }

  @override
  void dispose() {
    departureController.dispose();
    arrivalController.dispose();
    super.dispose();
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
      selectedDate = _formatDate(pickedDate);
    });
  }

  void _search() {
    context.read<TripProvider>().searchTrips(
      departure: departureController.text.trim().isEmpty
          ? null
          : departureController.text.trim(),
      arrival: arrivalController.text.trim().isEmpty
          ? null
          : arrivalController.text.trim(),
      date: _parsedSelectedDate(),
    );
  }

  void _openTrip(TripEntity trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailScreen(
          tripId: trip.id,
          driverName: 'Conducteur',
          departure: trip.departure,
          arrival: trip.arrival,
          date: _formatDate(trip.departureDateTime),
          departureTime: _formatTime(trip.departureDateTime),
          duration: _estimatedDuration(trip),
          availableSeats: trip.availableSeats,
          price: trip.pricePerSeat,
          rating: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final displayedTrips = _visibleTrips(provider.trips);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rechercher un trajet'),
      ),
      body: Column(
        children: [
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
                          selectedDate ?? 'Choisir une date',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: provider.isLoading ? null : _search,
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
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                provider.errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: provider.isLoading && displayedTrips.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : displayedTrips.isEmpty
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
                        itemCount: displayedTrips.length,
                        itemBuilder: (context, index) {
                          final trip = displayedTrips[index];

                          return TripCard(
                            tripId: trip.id,
                            driverName: 'Conducteur',
                            departure: trip.departure,
                            arrival: trip.arrival,
                            departureTime: _formatTime(trip.departureDateTime),
                            duration: _estimatedDuration(trip),
                            availableSeats: trip.availableSeats,
                            price: trip.pricePerSeat,
                            rating: 0,
                            date: _formatDate(trip.departureDateTime),
                            onTap: () => _openTrip(trip),
                            trailing: FavoriteButton(
                              userId: _currentUserId,
                              tripId: trip.id,
                              departure: trip.departure,
                              arrival: trip.arrival,
                              departureDateTime: trip.departureDateTime,
                              pricePerSeat: trip.pricePerSeat,
                              driverId: trip.driverId,
                              size: 22,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
