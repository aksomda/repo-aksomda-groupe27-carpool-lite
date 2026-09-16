import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Injector.authProvider.user;
      if (user == null) return;
      context.read<TripProvider>().loadTripHistory(driverId: user.uid);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} à '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(TripStatus status) {
    switch (status) {
      case TripStatus.active:
        return 'Actif';
      case TripStatus.completed:
        return 'Terminé';
      case TripStatus.cancelled:
        return 'Annulé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final user = Injector.authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des trajets'),
      ),
      body: user == null
          ? const Center(child: Text('Utilisateur non connecté'))
          : _buildBody(provider),
    );
  }

  Widget _buildBody(TripProvider provider) {
    if (provider.isLoading && provider.tripHistory.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.tripHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final user = Injector.authProvider.user;
                  if (user == null) return;
                  provider.loadTripHistory(driverId: user.uid);
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.tripHistory.isEmpty) {
      return const Center(
        child: Text(
          'Aucun trajet publié pour le moment.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.tripHistory.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final trip = provider.tripHistory[index];
        return Card(
          child: ListTile(
            title: Text('${trip.departure} → ${trip.arrival}'),
            subtitle: Text(
              '${_formatDateTime(trip.departureDateTime)}\n'
              '${trip.availableSeats}/${trip.totalSeats} places • '
              '${trip.pricePerSeat.toStringAsFixed(0)} GNF • '
              '${_statusLabel(trip.status)}',
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
