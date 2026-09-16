import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';

/// Liste des véhicules du conducteur connecté.
///
/// Attend un [VehicleProvider] fourni plus haut dans l'arbre
/// (voir `app_router.dart`).
class VehicleListScreen extends StatefulWidget {
  final String ownerId;

  const VehicleListScreen({super.key, required this.ownerId});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<VehicleProvider>().loadUserVehicles(widget.ownerId);
    });
  }

  Future<void> _openForm({VehicleEntity? vehicle}) async {
    final provider = context.read<VehicleProvider>();

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: AddVehicleScreen(
            ownerId: widget.ownerId,
            vehicle: vehicle,
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(VehicleEntity vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le véhicule'),
        content: Text(
          'Voulez-vous vraiment supprimer ${vehicle.displayName} ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<VehicleProvider>();

    final success = await provider.deleteVehicle(
      ownerId: widget.ownerId,
      vehicleId: vehicle.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? (provider.successMessage ?? 'Véhicule supprimé.')
              : (provider.errorMessage ?? 'Suppression impossible.'),
        ),
        backgroundColor: success ? null : Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _setDefault(VehicleEntity vehicle) async {
    final provider = context.read<VehicleProvider>();

    await provider.setDefaultVehicle(
      ownerId: widget.ownerId,
      vehicleId: vehicle.id,
    );

    if (!mounted) return;

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes véhicules')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(VehicleProvider provider) {
    if (provider.isLoading && provider.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () =>
                    provider.loadUserVehicles(widget.ownerId),
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (provider.vehicles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Aucun véhicule enregistré',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ajoutez un véhicule pour pouvoir publier des trajets '
                'en tant que conducteur.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Ajouter un véhicule'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: provider.vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = provider.vehicles[index];

        return VehicleCard(
          vehicle: vehicle,
          onEdit: () => _openForm(vehicle: vehicle),
          onDelete: () => _confirmDelete(vehicle),
          onSetDefault: () => _setDefault(vehicle),
        );
      },
    );
  }
}
