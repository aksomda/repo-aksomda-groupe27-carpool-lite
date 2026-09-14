import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Résumé rapide affiché en tête d'un tableau de bord de statistiques
/// (ex. [StatisticsPage]). Composé de plusieurs [QuickStatItem] séparés
/// par des [QuickStatDivider].
///
/// Widget public et autonome du module Statistiques : il ne dépend
/// d'aucune couleur ou classe du module Profil, afin que les deux
/// modules restent indépendants et accessibles distinctement (menu
/// latéral, accès rapide) plutôt qu'imbriqués l'un dans l'autre.
class QuickStatsRow extends StatelessWidget {
  final List<QuickStatItem> items;

  const QuickStatsRow({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      children.add(items[i]);
      if (i != items.length - 1) {
        children.add(const QuickStatDivider());
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(children: children),
    );
  }
}

class QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const QuickStatItem({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class QuickStatDivider extends StatelessWidget {
  const QuickStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 70, color: AppColors.border);
  }
}
