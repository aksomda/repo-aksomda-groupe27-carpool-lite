import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';

/// Liste des véhicules appartenant à l'utilisateur connecté, avec
/// possibilité d'en ajouter un nouveau ou de modifier un véhicule existant.
///
/// Nécessite un [VehicleProvider] fourni plus haut dans l'arbre (voir
/// app_router.dart).
class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ownerId = Injector.authProvider.user?.uid ?? '';
      context.read<VehicleProvider>().listenToUserVehicles(ownerId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Mes véhicules')),
      body: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(provider.errorMessage!, textAlign: TextAlign.center),
              ),
            );
          }

          final vehicles = provider.vehicles;

          if (vehicles.isEmpty) {
            return const Center(
              child: Text('Aucun véhicule enregistré pour le moment.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return VehicleCard(
                vehicle: vehicle,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: provider,
                        child: AddVehicleScreen(existing: vehicle),
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
            builder: (_) => ChangeNotifierProvider.value(
              value: provider,
              child: const AddVehicleScreen(),
            ),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }
}
