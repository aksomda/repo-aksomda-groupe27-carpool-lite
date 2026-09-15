import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../../../bookings/domain/entities/ride_request_entity.dart';
import '../../../bookings/presentation/providers/booking_provider.dart';
import '../../domain/entities/trip_entity.dart';
import '../providers/trip_provider.dart';
import '../widgets/trip_card.dart';

/// Recherche de trajets : liste l'ensemble des trajets enregistrés dans
/// Firestore (tous conducteurs confondus), avec filtrage optionnel sur le
/// lieu de départ et le lieu d'arrivée.
///
/// Nécessite un [TripProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart).
class SearchTripsScreen extends StatefulWidget {
  const SearchTripsScreen({super.key});

  @override
  State<SearchTripsScreen> createState() => _SearchTripsScreenState();
}

class _SearchTripsScreenState extends State<SearchTripsScreen> {
  final _departController = TextEditingController();
  final _arriveeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Au premier affichage, on liste tous les trajets sans filtre.
      context.read<TripProvider>().searchTrips();
    });
  }

  @override
  void dispose() {
    _departController.dispose();
    _arriveeController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    FocusScope.of(context).unfocus();
    context.read<TripProvider>().searchTrips(
          lieuDepart: _departController.text,
          lieuArrivee: _arriveeController.text,
        );
  }

  void _resetFilters() {
    FocusScope.of(context).unfocus();
    _departController.clear();
    _arriveeController.clear();
    context.read<TripProvider>().clearSearchFilters();
  }

  Future<void> _reserve(TripEntity trip) async {
    final passengerId = Injector.authProvider.user?.uid ?? '';
    if (passengerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous devez être connecté pour réserver un trajet.')),
      );
      return;
    }

    final placesController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    final nombrePlaces = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réserver ce trajet'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: placesController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de places souhaitées',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final n = int.tryParse((value ?? '').trim());
                if (n == null || n <= 0) return 'Entrez un nombre de places valide';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(dialogContext).pop(int.parse(placesController.text.trim()));
                }
              },
              child: const Text('Envoyer la demande'),
            ),
          ],
        );
      },
    );

    if (nombrePlaces == null || !mounted) return;

    final bookingProvider = context.read<BookingProvider>();
    final success = await bookingProvider.requestBooking(
      RideRequestEntity(
        id: '',
        tripId: trip.id,
        driverId: trip.driverId,
        passengerId: passengerId,
        lieuDepart: trip.lieuDepart,
        lieuArrivee: trip.lieuArrivee,
        nombrePlaces: nombrePlaces,
        statut: RideRequestStatus.enAttente,
        dateDemande: DateTime.now(),
      ),
    );

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande de réservation envoyée.')),
      );
    } else if (bookingProvider.saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingProvider.saveError!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TripProvider>();
    final hasFilters =
        provider.filtreDepart.isNotEmpty || provider.filtreArrivee.isNotEmpty;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Recherche de trajets')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _departController,
                        decoration: const InputDecoration(
                          labelText: 'Lieu de départ',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _arriveeController,
                        decoration: const InputDecoration(
                          labelText: "Lieu d'arrivée",
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) => _applyFilters(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _applyFilters,
                        icon: const Icon(Icons.search),
                        label: const Text('Rechercher'),
                      ),
                    ),
                    if (hasFilters) ...[
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _resetFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Effacer'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildResults(context, provider, hasFilters)),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context, TripProvider provider, bool hasFilters) {
    if (provider.isLoadingSearch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.searchErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            provider.searchErrorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final trips = provider.searchResults;

    if (trips.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            hasFilters
                ? 'Aucun trajet ne correspond à votre recherche.'
                : 'Aucun trajet enregistré pour le moment.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${trips.length} trajet${trips.length > 1 ? 's' : ''} trouvé'
            '${trips.length > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final trip = trips[index];
              final isOwnTrip = trip.driverId == (Injector.authProvider.user?.uid ?? '');
              return TripCard(
                trip: trip,
                onReserve: isOwnTrip ? null : () => _reserve(trip),
              );
            },
          ),
        ),
      ],
    );
  }
}
