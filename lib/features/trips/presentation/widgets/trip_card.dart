// Carte d'affichage d'un trajet dans une liste.
import 'package:flutter/material.dart';

import '../../domain/entities/trip_entity.dart';

class TripCard extends StatelessWidget {
  final TripEntity trip;
  final VoidCallback? onEdit;
  final VoidCallback? onReserve;

  const TripCard({super.key, required this.trip, this.onEdit, this.onReserve});

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year} à ${two(date.hour)}:${two(date.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.route_outlined)),
        title: Text('${trip.lieuDepart} → ${trip.lieuArrivee}'),
        subtitle: Text(
          'Véhicule : ${trip.immatriculationVehicule}\n'
          '${trip.distanceKm.toStringAsFixed(1)} km · '
          '${trip.prixParPlace} F/place · ${_formatDate(trip.createdAt)}',
        ),
        isThreeLine: true,
        trailing: onEdit != null
            ? IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier',
                onPressed: onEdit,
              )
            : onReserve != null
                ? FilledButton(onPressed: onReserve, child: const Text('Réserver'))
                : null,
      ),
    );
  }
}
