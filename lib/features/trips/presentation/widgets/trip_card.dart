import 'package:flutter/material.dart';

class TripCard extends StatelessWidget {
  final String tripId;
  final String driverName;
  final String departure;
  final String arrival;
  final String departureTime;
  final String duration;
  final int availableSeats;
  final double price;
  final double rating;
  final String date;
  final VoidCallback? onTap;

  /// Widget optionnel affiché en haut à droite de la carte
  /// (utilisé pour le bouton « favori »).
  final Widget? trailing;

  const TripCard({
    super.key,
    required this.tripId,
    required this.driverName,
    required this.departure,
    required this.arrival,
    required this.departureTime,
    required this.duration,
    required this.availableSeats,
    required this.price,
    required this.rating,
    required this.date,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Conducteur
              Row(
                children: [
                  const CircleAvatar(
                    radius: 23,
                    child: Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          driverName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 17,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(rating.toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${price.toStringAsFixed(0)} FCFA',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (trailing != null) trailing!,
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Départ → arrivée
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.radio_button_checked,
                        size: 18,
                      ),
                      Container(
                        width: 2,
                        height: 28,
                        color: Colors.grey,
                      ),
                      const Icon(
                        Icons.location_on,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departure,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          departureTime,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          arrival,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Divider(),

              // Informations
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 17,
                  ),
                  const SizedBox(width: 6),
                  Text(date),
                  const Spacer(),
                  const Icon(
                    Icons.timer_outlined,
                    size: 17,
                  ),
                  const SizedBox(width: 5),
                  Text(duration),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Icon(
                    Icons.event_seat,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$availableSeats place(s) disponible(s)',
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}