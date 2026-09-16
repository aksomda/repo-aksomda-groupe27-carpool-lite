import 'package:flutter/material.dart';

import '../../domain/entities/vehicle_entity.dart';

class VehicleCard extends StatelessWidget {
  final VehicleEntity vehicle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSetDefault;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onEdit,
    this.onDelete,
    this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.plateNumber,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vehicle.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Par défaut',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.event_seat, size: 18),
                const SizedBox(width: 6),
                Text('${vehicle.seats} place(s)'),
                const SizedBox(width: 18),
                const Icon(Icons.palette_outlined, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    vehicle.color.isEmpty ? 'Non précisée' : vehicle.color,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!vehicle.isDefault && onSetDefault != null)
                  TextButton.icon(
                    onPressed: onSetDefault,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Définir par défaut'),
                  ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Modifier',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
