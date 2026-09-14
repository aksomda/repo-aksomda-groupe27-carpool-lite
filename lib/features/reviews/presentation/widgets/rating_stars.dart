// Widget réutilisable d'affichage/saisie de note en étoiles (échelle 1-10).
import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  /// Note courante (0 = aucune note saisie).
  final int value;

  /// Note maximale représentée (10 pour coller à l'échelle des avis).
  final int max;

  /// null => lecture seule (affichage d'un avis existant).
  final ValueChanged<int>? onChanged;

  final double size;

  const RatingStars({
    super.key,
    required this.value,
    this.max = 10,
    this.onChanged,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final readOnly = onChanged == null;

    return Wrap(
      children: List.generate(max, (index) {
        final rating = index + 1;
        final icon = Icon(
          rating <= value ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );

        if (readOnly) {
          return Padding(padding: const EdgeInsets.only(right: 2), child: icon);
        }

        return IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () => onChanged!(rating),
          icon: icon,
        );
      }),
    );
  }
}
