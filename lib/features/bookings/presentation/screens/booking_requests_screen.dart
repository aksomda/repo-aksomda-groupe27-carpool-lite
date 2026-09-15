import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../../domain/entities/ride_request_entity.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';
import 'my_bookings_screen.dart';

/// Liste des demandes de réservation reçues par le conducteur connecté,
/// filtrable par statut de la demande et par plage de dates (date à
/// laquelle la demande a été envoyée).
///
/// Nécessite un [BookingProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart).
class BookingRequestsScreen extends StatefulWidget {
  const BookingRequestsScreen({super.key});

  @override
  State<BookingRequestsScreen> createState() => _BookingRequestsScreenState();
}

class _BookingRequestsScreenState extends State<BookingRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final driverId = Injector.authProvider.user?.uid ?? '';
      context.read<BookingProvider>().listenToDriverRequests(driverId);
    });
  }

  String _formatDate(DateTime date) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(date.day)}/${two(date.month)}/${date.year}';
  }

  Future<void> _pickDateDebut(BuildContext context, BookingProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.dateDebutFiltre ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      provider.setDateRangeFiltre(
        dateDebut: picked,
        dateFin: provider.dateFinFiltre,
      );
    }
  }

  Future<void> _pickDateFin(BuildContext context, BookingProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.dateFinFiltre ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      provider.setDateRangeFiltre(
        dateDebut: provider.dateDebutFiltre,
        dateFin: picked,
      );
    }
  }

  Future<void> _confirmAndRun(
    BuildContext context,
    BookingProvider provider,
    Future<bool> Function() action,
    String successMessage,
  ) async {
    final success = await action();
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    } else if (provider.saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.saveError!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final hasFiltres = provider.statutFiltre != null ||
        provider.dateDebutFiltre != null ||
        provider.dateFinFiltre != null;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Demandes de réservation'),
        actions: [
          IconButton(
            tooltip: 'Mes demandes envoyées',
            icon: const Icon(Icons.send_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const MyBookingsScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                DropdownButtonFormField<RideRequestStatus?>(
                  initialValue: provider.statutFiltre,
                  decoration: const InputDecoration(
                    labelText: 'Statut de la demande',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous les statuts')),
                    ...RideRequestStatus.values.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                    ),
                  ],
                  onChanged: (value) => provider.setStatutFiltre(value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateDebut(context, provider),
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          provider.dateDebutFiltre == null
                              ? 'Date de début'
                              : _formatDate(provider.dateDebutFiltre!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickDateFin(context, provider),
                        icon: const Icon(Icons.event, size: 18),
                        label: Text(
                          provider.dateFinFiltre == null
                              ? 'Date de fin'
                              : _formatDate(provider.dateFinFiltre!),
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasFiltres) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: provider.clearFiltres,
                      icon: const Icon(Icons.clear, size: 18),
                      label: const Text('Effacer les filtres'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildList(context, provider, hasFiltres)),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, BookingProvider provider, bool hasFiltres) {
    if (provider.isLoadingDriverRequests) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.driverRequestsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(provider.driverRequestsError!, textAlign: TextAlign.center),
        ),
      );
    }

    final requests = provider.filteredDriverRequests;

    if (requests.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            hasFiltres
                ? 'Aucune demande ne correspond à ces filtres.'
                : 'Aucune demande de réservation reçue pour le moment.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return BookingCard(
          request: request,
          onAccept: () => _confirmAndRun(
            context,
            provider,
            () => provider.confirmRequest(request.id),
            'Demande acceptée.',
          ),
          onReject: () => _confirmAndRun(
            context,
            provider,
            () => provider.rejectRequest(request.id),
            'Demande refusée.',
          ),
        );
      },
    );
  }
}
