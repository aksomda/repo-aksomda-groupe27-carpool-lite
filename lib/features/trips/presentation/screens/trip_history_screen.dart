import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../../../vehicles/presentation/providers/vehicle_provider.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';
import 'publish_trip_screen.dart';

/// Historique des trajets publiés par l'utilisateur connecté.
///
/// Nécessite un [TripProvider] et un [VehicleProvider] fournis plus haut
/// dans l'arbre (voir app_router.dart) : le second est réutilisé par
/// l'écran de modification, ouvert depuis cet écran.
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
      final driverId = Injector.authProvider.user?.uid ?? '';
      context.read<TripProvider>().listenToTripHistory(driverId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final vehicleProvider = context.watch<VehicleProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Historique des trajets')),
      body: Builder(
        builder: (context) {
          if (tripProvider.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tripProvider.historyError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(tripProvider.historyError!, textAlign: TextAlign.center),
              ),
            );
          }

          final trips = tripProvider.tripHistory;

          if (trips.isEmpty) {
            return const Center(
              child: Text('Aucun trajet enregistré pour le moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              return TripCard(
                trip: trip,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(value: tripProvider),
                          ChangeNotifierProvider.value(value: vehicleProvider),
                        ],
                        child: PublishTripScreen(existing: trip),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => MultiProvider(
              providers: [
                ChangeNotifierProvider.value(value: tripProvider),
                ChangeNotifierProvider.value(value: vehicleProvider),
              ],
              child: const PublishTripScreen(),
            ),
          ),
        ),
        icon: const Icon(Icons.add_road),
        label: const Text('Publier'),
      ),
    );
  }
}
