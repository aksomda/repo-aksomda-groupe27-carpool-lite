import 'package:flutter/material.dart';

import '../../data/models/academic_level_model.dart';

class AcademicLevelCard extends StatelessWidget {
  const AcademicLevelCard({
    super.key,
    required this.level,
    required this.onEdit,
    required this.onDelete,
  });

  final AcademicLevelModel level;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.stairs, color: Theme.of(context).primaryColor),
        ),
        title: Text(level.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${level.formationName} • ${level.academicYear}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
