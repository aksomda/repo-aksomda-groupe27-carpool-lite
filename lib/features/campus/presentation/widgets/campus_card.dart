import 'package:flutter/material.dart';

import '../../data/models/campus_model.dart';

class CampusCard extends StatelessWidget {
  const CampusCard({
    super.key,
    required this.campus,
    required this.onEdit,
    required this.onDelete,
  });

  final CampusModel campus;
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
          child: Icon(Icons.apartment, color: Theme.of(context).primaryColor),
        ),
        title: Text(campus.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${campus.code} • ${campus.universityName}'),
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
