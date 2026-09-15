// Carte d'affichage d'un véhicule.
import 'package:flutter/material.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback? onEdit;

  const VehicleCard({super.key, required this.vehicle, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.directions_car)),
        title: Text('${vehicle.marque} ${vehicle.modele}'),
        subtitle: Text(
          '${vehicle.immatriculation} · ${vehicle.categorie} · '
          '${vehicle.nombrePlaces} place(s)\n'
          'Châssis : ${vehicle.numeroChassis}',
        ),
        isThreeLine: true,
        trailing: onEdit == null
            ? null
            : IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Modifier',
                onPressed: onEdit,
              ),
      ),
    );
  }
}
