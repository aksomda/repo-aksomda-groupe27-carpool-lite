import 'package:flutter/material.dart';

import '../../data/models/ufr_model.dart';

class UfrCard extends StatelessWidget {
  const UfrCard({
    super.key,
    required this.ufr,
    required this.onEdit,
    required this.onDelete,
  });

  final UfrModel ufr;
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
          child: Icon(Icons.account_balance, color: Theme.of(context).primaryColor),
        ),
        title: Text(ufr.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${ufr.code} • ${ufr.campusName}'),
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
