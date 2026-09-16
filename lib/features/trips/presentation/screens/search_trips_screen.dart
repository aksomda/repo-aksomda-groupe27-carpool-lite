import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../widgets/trip_card.dart';
import 'trip_detail_screen.dart';

class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({
    super.key,
  });

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final TextEditingController departureController =
      TextEditingController();

  final TextEditingController arrivalController =
      TextEditingController();

  String? selectedDate;

  final List<Map<String, dynamic>> trips = [
    {
      'id': 'trip_001',
      'driverName': 'Chantal M.',
      'departure': 'Université Nongo Conakry',
      'arrival': 'Kaloum',
      'departureTime': '07:30',
      'duration': '2h10',
      'availableSeats': 4,
      'price': 1500.0,
      'rating': 4.8,
      'date': 'Aujourd’hui',
    },
    {
      'id': 'trip_002',
      'driverName': 'Kevin T.',
      'departure': 'Sonfonia',
      'arrival': 'Kaloum',
      'departureTime': '08:00',
      'duration': '2h00',
      'availableSeats': 3,
      'price': 1200.0,
      'rating': 4.6,
      'date': 'Aujourd’hui',
    },
    {
      'id': 'trip_003',
      'driverName': 'Sandra B.',
      'departure': 'Lambanyi',
      'arrival': 'Université Gamal Abdel Nasser',
      'departureTime': '08:15',
      'duration': '2h30',
      'availableSeats': 4,
      'price': 1500.0,
      'rating': 4.9,
      'date': 'Aujourd’hui',
    },
  ];

  List<Map<String, dynamic>> get filteredTrips {
    final departure = departureController.text.trim().toLowerCase();
    final arrival = arrivalController.text.trim().toLowerCase();

    return trips.where((trip) {
      final tripDeparture =
          trip['departure'].toString().toLowerCase();

      final tripArrival =
          trip['arrival'].toString().toLowerCase();

      final departureMatches =
          departure.isEmpty ||
          tripDeparture.contains(departure);

      final arrivalMatches =
          arrival.isEmpty ||
          tripArrival.contains(arrival);

      return departureMatches && arrivalMatches;
    }).toList();
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
      selectedDate =
          '${pickedDate.day.toString().padLeft(2, '0')}/'
          '${pickedDate.month.toString().padLeft(2, '0')}/'
          '${pickedDate.year}';
    });
  }

  void _search() {
    setState(() {});
  }

  void _openTrip(Map<String, dynamic> trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TripDetailScreen(
          tripId: trip['id'].toString(),
          driverName: trip['driverName'].toString(),
          departure: trip['departure'].toString(),
          arrival: trip['arrival'].toString(),
          date: selectedDate ?? trip['date'].toString(),
          departureTime: trip['departureTime'].toString(),
          duration: trip['duration'].toString(),
          availableSeats:
              (trip['availableSeats'] as num).toInt(),
          price:
              (trip['price'] as num).toDouble(),
          rating:
              (trip['rating'] as num).toDouble(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedTrips = filteredTrips;

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
                          selectedDate ?? 'Choisir une date',
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

          // Liste des trajets
          Expanded(
            child: displayedTrips.isEmpty
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
                        tripId: trip['id'].toString(),
                        driverName:
                            trip['driverName'].toString(),
                        departure:
                            trip['departure'].toString(),
                        arrival:
                            trip['arrival'].toString(),
                        departureTime:
                            trip['departureTime'].toString(),
                        duration:
                            trip['duration'].toString(),
                        availableSeats:
                            (trip['availableSeats'] as num)
                                .toInt(),
                        price:
                            (trip['price'] as num).toDouble(),
                        rating:
                            (trip['rating'] as num).toDouble(),
                        date:
                            selectedDate ??
                            trip['date'].toString(),
                        onTap: () => _openTrip(trip),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}