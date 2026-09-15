import 'package:flutter/material.dart';

import '../widgets/seat_counter.dart';

class TripDetailScreen extends StatefulWidget {
  final String tripId;
  final String driverName;
  final String departure;
  final String arrival;
  final String date;
  final String departureTime;
  final String duration;
  final int availableSeats;
  final double price;
  final double rating;

  const TripDetailScreen({
    super.key,
    required this.tripId,
    required this.driverName,
    required this.departure,
    required this.arrival,
    required this.date,
    required this.departureTime,
    required this.duration,
    required this.availableSeats,
    required this.price,
    required this.rating,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  int numberOfSeats = 1;

  @override
  Widget build(BuildContext context) {
    final totalPrice = widget.price * numberOfSeats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du trajet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Conducteur
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      child: Icon(Icons.person),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.driverName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(widget.rating.toString()),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Trajet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.location_on,
                      title: 'Départ',
                      value: widget.departure,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.flag,
                      title: 'Arrivée',
                      value: widget.arrival,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      title: 'Date',
                      value: widget.date,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.access_time,
                      title: 'Heure de départ',
                      value: widget.departureTime,
                    ),
                    const Divider(),
                    _InfoRow(
                      icon: Icons.timer,
                      title: 'Durée',
                      value: widget.duration,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Places disponibles',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              '${widget.availableSeats} place(s) disponible(s)',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 15),

            SeatCounter(
              initialValue: numberOfSeats,
              maxValue: widget.availableSeats,
              onChanged: (value) {
                setState(() {
                  numberOfSeats = value;
                });
              },
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${totalPrice.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Demande de réservation en préparation.',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Réserver ce trajet',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}