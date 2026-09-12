import 'package:flutter/material.dart';

import '../../domain/entities/university_satisfaction_statistics.dart';
import '../widgets/satisfaction_chart.dart';
import '../widgets/statistic_card.dart';

class UniversityDashboardPage extends StatelessWidget {
  final UniversitySatisfactionStatistics statistics;

  const UniversityDashboardPage({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(statistics.universityName)),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              'Tableau de bord',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            StatisticCard(
              title: 'Satisfaction globale',
              value:
                  '${statistics.satisfactionPercentage.toStringAsFixed(1)} %',
              icon: Icons.sentiment_satisfied,
              subtitle: '${statistics.averageOverall.toStringAsFixed(1)} / 10',
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Évaluations',
              value: '${statistics.totalReviews}',
              icon: Icons.rate_review,
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Trajets',
              value: '${statistics.totalTrips}',
              icon: Icons.directions_car,
            ),

            const SizedBox(height: 12),

            StatisticCard(
              title: 'Conducteurs',
              value: '${statistics.totalDrivers}',
              icon: Icons.people,
            ),

            const SizedBox(height: 30),

            const Text(
              'Satisfaction des étudiants',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            SatisfactionChart(
              punctuality: statistics.averagePunctuality,
              driving: statistics.averageDriving,
              atmosphere: statistics.averageAtmosphere,
            ),

            const SizedBox(height: 20),

            _StatisticRow(
              title: 'Ponctualité',
              value: statistics.averagePunctuality,
            ),

            _StatisticRow(title: 'Conduite', value: statistics.averageDriving),

            _StatisticRow(
              title: 'Ambiance',
              value: statistics.averageAtmosphere,
            ),

            _StatisticRow(
              title: 'Satisfaction globale',
              value: statistics.averageOverall,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String title;
  final double value;

  const _StatisticRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        '${value.toStringAsFixed(1)} / 10',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
