import 'package:flutter/material.dart';

import '../../data/models/formation_model.dart';

class FormationCard extends StatelessWidget {
  const FormationCard({
    super.key,
    required this.formation,
    required this.onEdit,
    required this.onDelete,
  });

  final FormationModel formation;
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
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(Icons.menu_book, color: Theme.of(context).primaryColor),
        ),
        title: Text(formation.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${formation.diploma} • ${formation.code} • ${formation.ufrName}'),
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
