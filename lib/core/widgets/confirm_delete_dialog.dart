import 'package:flutter/material.dart';

/// Affiche une confirmation avant une suppression logique et retourne
/// `true` si l'utilisateur confirme.
Future<bool> confirmSoftDelete(BuildContext context, String itemLabel) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmer la suppression'),
      content: Text(
        'Voulez-vous vraiment supprimer "$itemLabel" ?\n'
        "L'élément ne sera plus visible mais restera archivé en base.",
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuler'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Supprimer'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
