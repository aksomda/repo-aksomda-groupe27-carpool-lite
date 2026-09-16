import 'package:flutter/material.dart';

import '../../domain/entities/booking_entity.dart';
import '../../domain/entities/ride_request_entity.dart';

class BookingCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int numberOfSeats;
  final double totalPrice;
  final BookingStatus status;
  final DateTime date;

  final VoidCallback? onConfirm;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.numberOfSeats,
    required this.totalPrice,
    required this.status,
    required this.date,
    this.onConfirm,
    this.onReject,
    this.onCancel,
  });

  factory BookingCard.fromBooking({
    Key? key,
    required BookingEntity booking,
    VoidCallback? onCancel,
  }) {
    return BookingCard(
      key: key,
      title: 'Réservation',
      subtitle: 'Trajet : ${booking.tripId}',
      numberOfSeats: booking.numberOfSeats,
      totalPrice: booking.totalPrice,
      status: booking.status,
      date: booking.reservationDate,
      onCancel: onCancel,
    );
  }

  factory BookingCard.fromRequest({
    Key? key,
    required RideRequestEntity request,
    VoidCallback? onConfirm,
    VoidCallback? onReject,
  }) {
    return BookingCard(
      key: key,
      title: 'Demande de réservation',
      subtitle: 'Passager : ${request.passengerId}',
      numberOfSeats: request.numberOfSeats,
      totalPrice: request.totalPrice,
      status: request.status,
      date: request.createdAt,
      onConfirm: onConfirm,
      onReject: onReject,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withValues(
                            alpha: 0.12,
                          ),
                  child: Icon(
                    Icons.directions_car,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.event_seat,
                    label: 'Places',
                    value: '$numberOfSeats',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.payments_outlined,
                    label: 'Prix',
                    value: '${totalPrice.toStringAsFixed(0)} GNF',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: _formatDate(date),
                  ),
                ),
              ],
            ),

            if (onConfirm != null ||
                onReject != null ||
                onCancel != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null)
                    OutlinedButton(
                      onPressed: onReject,
                      child: const Text('Refuser'),
                    ),
                  if (onReject != null && onConfirm != null)
                    const SizedBox(width: 8),
                  if (onConfirm != null)
                    ElevatedButton(
                      onPressed: onConfirm,
                      child: const Text('Accepter'),
                    ),
                  if (onCancel != null)
                    OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Annuler'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;

    switch (status) {
      case BookingStatus.pending:
        label = 'En attente';
        color = Colors.orange;
        break;

      case BookingStatus.confirmed:
        label = 'Confirmée';
        color = Colors.green;
        break;

      case BookingStatus.cancelled:
        label = 'Annulée';
        color = Colors.red;
        break;

      case BookingStatus.completed:
        label = 'Terminée';
        color = Colors.blue;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}