import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/trips_remote_datasource.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/usecases/cancel_trip.dart';
import '../../domain/usecases/get_trip_history.dart';
import '../../domain/usecases/publish_trip.dart';
import '../../domain/usecases/search_trips.dart';
import '../controllers/trip_controller.dart';

class TripHistoryPage extends StatefulWidget {
  final String userId;

  const TripHistoryPage({super.key, required this.userId});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage> {
  late final TripController _controller;

  @override
  void initState() {
    super.initState();

    final firestore = FirebaseFirestore.instance;

    final remoteDataSource = TripsRemoteDataSource(firestore);

    final repository = TripRepositoryImpl(remoteDataSource);

    _controller = TripController(
      publishTrip: PublishTrip(repository),
      searchTrips: SearchTrips(repository),
      getTripHistory: GetTripHistory(repository),
      cancelTrip: CancelTrip(repository),
    );

    _controller.addListener(_onControllerChanged);

    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await _controller.loadHistory(widget.userId);
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmCancellation(String tripId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Annuler le trajet ?'),
          content: const Text(
            'Êtes-vous sûr de vouloir annuler ce trajet ? '
            'Cette action modifiera son statut.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Non'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Oui, annuler'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _controller.cancel(tripId);

    if (!mounted) return;

    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_controller.errorMessage!)));

      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Trajet annulé avec succès.')));

    await _loadHistory();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des trajets')),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            context.go('/trips/publish');
          } else if (index == 1) {
            context.go('/trips/search');
          } else if (index == 2) {
            context.go('/trips/history');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Publier'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(_controller.errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loadHistory, child: const Text('Réessayer')),
            ],
          ),
        ),
      );
    }

    if (_controller.history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 60),
            SizedBox(height: 12),
            Text('Aucun trajet dans votre historique.', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _controller.history.length,
        itemBuilder: (context, index) {
          final trip = _controller.history[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(child: Icon(Icons.directions_car)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          trip.departureLabel,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatus(trip.status),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Date : '
                    '${trip.departureDateTime.day}/'
                    '${trip.departureDateTime.month}/'
                    '${trip.departureDateTime.year}',
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Heure : '
                    '${trip.departureDateTime.hour.toString().padLeft(2, '0')}:'
                    '${trip.departureDateTime.minute.toString().padLeft(2, '0')}',
                  ),

                  const SizedBox(height: 4),

                  Text('Places : ${trip.availableSeats}'),

                  const SizedBox(height: 4),

                  Text(
                    'Prix : '
                    '${trip.pricePerSeat.toStringAsFixed(0)} FCFA',
                  ),

                  if (trip.status == TripStatus.available) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          _confirmCancellation(trip.id);
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text('Annuler le trajet'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatus(TripStatus status) {
    String text;

    switch (status) {
      case TripStatus.available:
        text = 'Disponible';
        break;

      case TripStatus.cancelled:
        text = 'Annulé';
        break;

      default:
        text = status.name;
    }

    return Chip(label: Text(text));
  }
}
