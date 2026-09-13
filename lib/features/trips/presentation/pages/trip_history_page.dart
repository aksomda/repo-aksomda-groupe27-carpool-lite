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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
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

    if (!mounted) {
      return;
    }

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
      backgroundColor: const Color(0xFFF8F9FB),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(child: _buildBody()),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // =========================
  // HEADER
  // =========================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),

      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 125,

                child: Image.asset('assets/images/carpool_logo.png', fit: BoxFit.contain),
              ),

              const Spacer(),

              Container(
                width: 44,
                height: 44,

                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                  ],
                ),

                child: const Icon(Icons.history, color: Color(0xFF1769E0)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Align(
            alignment: Alignment.centerLeft,

            child: Text('Mes trajets', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          ),

          const SizedBox(height: 5),

          Align(
            alignment: Alignment.centerLeft,

            child: Text(
              'Retrouvez les trajets que vous avez proposés.',

              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // BODY
  // =========================

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              Container(
                width: 72,
                height: 72,

                decoration: const BoxDecoration(color: Color(0xFFFFECEC), shape: BoxShape.circle),

                child: const Icon(Icons.error_outline, size: 36, color: Colors.red),
              ),

              const SizedBox(height: 16),

              Text(
                _controller.errorMessage!,

                textAlign: TextAlign.center,

                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: _loadHistory,

                icon: const Icon(Icons.refresh),

                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (_controller.history.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadHistory,

        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),

          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.48,

              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    Container(
                      width: 90,
                      height: 90,

                      decoration: const BoxDecoration(
                        color: Color(0xFFEAF2FF),

                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.directions_car_outlined,

                        size: 48,

                        color: Color(0xFF1769E0),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Aucun trajet pour le moment',

                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Vos trajets publiés apparaîtront ici.',

                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,

      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),

        itemCount: _controller.history.length,

        separatorBuilder: (context, index) {
          return const SizedBox(height: 14);
        },

        itemBuilder: (context, index) {
          final trip = _controller.history[index];

          return _buildHistoryCard(trip);
        },
      ),
    );
  }

  // =========================
  // CARTE TRAJET
  // =========================

  Widget _buildHistoryCard(Trip trip) {
    final isCancelled = trip.status == TripStatus.cancelled;

    final date =
        '${trip.departureDateTime.day.toString().padLeft(2, '0')}/'
        '${trip.departureDateTime.month.toString().padLeft(2, '0')}/'
        '${trip.departureDateTime.year}';

    final time =
        '${trip.departureDateTime.hour.toString().padLeft(2, '0')}:'
        '${trip.departureDateTime.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(22),

        border: Border.all(color: Colors.grey.shade200),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),

            blurRadius: 12,

            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // TITRE + STATUT
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),

                  borderRadius: BorderRadius.circular(14),
                ),

                child: const Icon(Icons.directions_car, color: Color(0xFF1769E0)),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      trip.departureLabel,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      trip.universityId,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              _buildStatus(trip.status),
            ],
          ),

          const SizedBox(height: 18),

          // ROUTE
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 11,
                    height: 11,

                    decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  ),

                  Container(width: 2, height: 26, color: Colors.grey.shade300),

                  Container(
                    width: 11,
                    height: 11,

                    decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                  ),
                ],
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      trip.departureLabel,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      trip.universityId,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(),

          const SizedBox(height: 12),

          // DATE + HEURE
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.calendar_month_outlined,

                  label: 'DATE',

                  value: date,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildInfoItem(icon: Icons.access_time, label: 'HEURE', value: time),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // PLACES + PRIX
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  icon: Icons.people_outline,

                  label: 'PLACES',

                  value: '${trip.availableSeats}',
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _buildInfoItem(
                  icon: Icons.payments_outlined,

                  label: 'PRIX',

                  value: '${trip.pricePerSeat.toStringAsFixed(0)} FCFA',
                ),
              ),
            ],
          ),

          // ANNULATION
          if (!isCancelled) ...[
            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: () {
                  _confirmCancellation(trip.id);
                },

                icon: const Icon(Icons.cancel_outlined),

                label: const Text('Annuler le trajet'),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,

                  side: BorderSide(color: Colors.red.shade200),

                  padding: const EdgeInsets.symmetric(vertical: 14),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================
  // PETITE CARTE INFO
  // =========================

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),

      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1769E0)),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  label,

                  style: TextStyle(
                    fontSize: 9,

                    color: Colors.grey.shade600,

                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // STATUT
  // =========================

  Widget _buildStatus(TripStatus status) {
    String text;
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case TripStatus.available:
        text = 'Disponible';

        backgroundColor = const Color(0xFFEAF8EF);

        textColor = Colors.green.shade700;

        break;

      case TripStatus.cancelled:
        text = 'Annulé';

        backgroundColor = const Color(0xFFFFECEC);

        textColor = Colors.red.shade700;

        break;

      default:
        text = status.name;

        backgroundColor = Colors.grey.shade200;

        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),

      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(20)),

      child: Text(
        text,

        style: TextStyle(fontSize: 11, color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  // =========================
  // NAVIGATION
  // =========================

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      currentIndex: 2,

      type: BottomNavigationBarType.fixed,

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
        BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'Publier'),

        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Rechercher'),

        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
      ],
    );
  }
}
