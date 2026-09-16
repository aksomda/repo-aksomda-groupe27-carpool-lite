// Tableau de bord des statistiques de satisfaction.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/statistics_page.dart';
import '../pages/university_dashboard_page.dart';
import '../providers/statistics_provider.dart';

/// Statistiques du conducteur connecté (mes évaluations en tant que
/// conducteur). Charge les données via [StatisticsProvider] puis délègue
/// l'affichage à [StatisticsPage].
class DriverStatisticsScreen extends StatefulWidget {
  final String driverId;

  const DriverStatisticsScreen({super.key, required this.driverId});

  @override
  State<DriverStatisticsScreen> createState() => _DriverStatisticsScreenState();
}

class _DriverStatisticsScreenState extends State<DriverStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadDriverStatistics(widget.driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    if (provider.isLoadingDriverStats) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.driverStatsError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques CarPool Lite')),
        body: Center(child: Text(provider.driverStatsError!)),
      );
    }

    final stats = provider.driverStatistics;
    if (stats == null || !stats.hasReviews) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques CarPool Lite')),
        body: const Center(child: Text('Pas encore assez d\'évaluations pour afficher des statistiques.')),
      );
    }

    return StatisticsPage(
      punctuality: stats.punctuality,
      driving: stats.driving,
      atmosphere: stats.atmosphere,
      overall: stats.overall,
      totalReviews: stats.numberOfReviews,
      totalTrips: 0,
      totalDrivers: 0,
    );
  }
}

/// Tableau de bord d'une université (réservé aux administrateurs). Charge
/// les données via [StatisticsProvider] puis délègue l'affichage à
/// [UniversityDashboardPage].
class UniversityStatisticsScreen extends StatefulWidget {
  final String universityId;

  const UniversityStatisticsScreen({super.key, required this.universityId});

  @override
  State<UniversityStatisticsScreen> createState() => _UniversityStatisticsScreenState();
}

class _UniversityStatisticsScreenState extends State<UniversityStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().loadUniversityStatistics(widget.universityId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();

    if (provider.isLoadingUniversityStats) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.universityStatsError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Statistiques université')),
        body: Center(child: Text(provider.universityStatsError!)),
      );
    }

    final stats = provider.universityStatistics;
    if (stats == null) {
      return const Scaffold(body: Center(child: Text('Aucune donnée.')));
    }

    return UniversityDashboardPage(statistics: stats);
  }
}
