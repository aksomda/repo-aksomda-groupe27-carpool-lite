import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../providers/booking_provider.dart';
import '../widgets/booking_card.dart';

/// Demandes de réservation envoyées par l'utilisateur connecté, en tant que
/// passager (sur les trajets d'autres conducteurs).
///
/// Nécessite un [BookingProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart).
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final passengerId = Injector.authProvider.user?.uid ?? '';
      context.read<BookingProvider>().listenToMyRequests(passengerId);
    });
  }

  Future<void> _cancel(BuildContext context, BookingProvider provider, String id) async {
    final success = await provider.cancelRequest(id);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Demande annulée.')),
      );
    } else if (provider.saveError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.saveError!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes demandes de réservation')),
      body: Builder(
        builder: (context) {
          if (provider.isLoadingMyRequests) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.myRequestsError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(provider.myRequestsError!, textAlign: TextAlign.center),
              ),
            );
          }

          final requests = provider.myRequests;

          if (requests.isEmpty) {
            return const Center(
              child: Text("Vous n'avez envoyé aucune demande de réservation."),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return BookingCard(
                request: request,
                onCancel: () => _cancel(context, provider, request.id),
              );
            },
          );
        },
      ),
    );
  }
}
