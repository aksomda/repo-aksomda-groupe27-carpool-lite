import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../widgets/quick_stats_row.dart';
import '../widgets/satisfaction_chart.dart';
import '../widgets/statistic_card.dart';

class StatisticsPage extends StatelessWidget {
  final double punctuality;
  final double driving;
  final double atmosphere;
  final double overall;

  final int totalReviews;
  final int totalTrips;
  final int totalDrivers;

  const StatisticsPage({
    super.key,
    required this.punctuality,
    required this.driving,
    required this.atmosphere,
    required this.overall,
    required this.totalReviews,
    required this.totalTrips,
    required this.totalDrivers,
  });

  @override
  Widget build(BuildContext context) {
    final satisfactionPercentage = (overall / 10) * 100;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques CarPool Lite')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            QuickStatsRow(
              items: [
                QuickStatItem(
                  icon: Icons.directions_car,
                  value: '$totalTrips',
                  label: 'Trajets réalisés',
                  color: AppColors.primary,
                ),
                QuickStatItem(
                  icon: Icons.person,
                  value: '$totalDrivers',
                  label: 'Conducteurs',
                  color: Colors.green,
                ),
                QuickStatItem(
                  icon: Icons.rate_review,
                  value: '$totalReviews',
                  label: 'Évaluations',
                  color: Colors.amber.shade700,
                ),
                QuickStatItem(
                  icon: Icons.sentiment_satisfied,
                  value: '${satisfactionPercentage.toStringAsFixed(0)}%',
                  label: 'Satisfaction',
                  color: AppColors.primary,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Satisfaction des utilisateurs',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            StatisticCard(
              title: 'Satisfaction globale',
              value: '${satisfactionPercentage.toStringAsFixed(1)} %',
              icon: Icons.sentiment_satisfied,
              subtitle: '${overall.toStringAsFixed(1)} / 10',
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Évaluations',
              value: '$totalReviews',
              icon: Icons.rate_review,
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Trajets réalisés',
              value: '$totalTrips',
              icon: Icons.directions_car,
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Conducteurs',
              value: '$totalDrivers',
              icon: Icons.person,
            ),

            const SizedBox(height: 30),

            const Text(
              'Évaluation des conducteurs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SatisfactionChart(
              punctuality: punctuality,
              driving: driving,
              atmosphere: atmosphere,
            ),

            const SizedBox(height: 20),

            _RatingRow(label: 'Ponctualité', rating: punctuality),

            _RatingRow(label: 'Qualité de conduite', rating: driving),

            _RatingRow(label: 'Ambiance', rating: atmosphere),

            _RatingRow(label: 'Satisfaction globale', rating: overall),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final double rating;

  const _RatingRow({required this.label, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),

          Text(
            '${rating.toStringAsFixed(1)} / 10',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
