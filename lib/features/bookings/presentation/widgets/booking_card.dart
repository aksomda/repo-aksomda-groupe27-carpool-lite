// Carte d'affichage d'une demande de réservation.
import 'package:flutter/material.dart';

import '../../domain/entities/ride_request_entity.dart';

class BookingCard extends StatelessWidget {
  final RideRequestEntity request;

  /// Affichés uniquement si la demande est encore "en attente".
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onCancel;

  const BookingCard({
    super.key,
    required this.request,
    this.onAccept,
    this.onReject,
    this.onCancel,
  });

  Color _statutColor(BuildContext context) {
    switch (request.statut) {
      case RideRequestStatus.enAttente:
        return Colors.orange;
      case RideRequestStatus.acceptee:
        return Colors.green;
      case RideRequestStatus.refusee:
        return Theme.of(context).colorScheme.error;
      case RideRequestStatus.annulee:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} à ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.statut == RideRequestStatus.enAttente;
    final color = _statutColor(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${request.lieuDepart} → ${request.lieuArrivee}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.statut.label,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${request.nombrePlaces} place(s) demandée(s) · '
              'Demande du ${_formatDate(request.dateDemande)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isPending && (onAccept != null || onReject != null || onCancel != null)) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onReject != null)
                    TextButton(onPressed: onReject, child: const Text('Refuser')),
                  if (onAccept != null) ...[
                    const SizedBox(width: 8),
                    FilledButton(onPressed: onAccept, child: const Text('Accepter')),
                  ],
                  if (onCancel != null)
                    TextButton(onPressed: onCancel, child: const Text('Annuler la demande')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
