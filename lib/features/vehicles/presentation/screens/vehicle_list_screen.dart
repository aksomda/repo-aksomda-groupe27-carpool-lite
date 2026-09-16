import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';

class VehicleListScreen extends StatefulWidget {
  final VehicleProvider vehicleProvider;
  final String ownerId;

  const VehicleListScreen({
    super.key,
    required this.vehicleProvider,
    required this.ownerId,
  });

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  @override
  void initState() {
    super.initState();

    widget.vehicleProvider.listenToUserVehicles(ownerId: widget.ownerId);
    widget.vehicleProvider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    if (!mounted) return;

    setState(() {});
  }

  @override
  void dispose() {
    widget.vehicleProvider.removeListener(_onProviderChanged);
    super.dispose();
  }

  Future<void> _addVehicle() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddVehicleScreen(
          vehicleProvider: widget.vehicleProvider,
          ownerId: widget.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    drawer: AppDrawer(authProvider: Injector.authProvider),
    appBar: AppBar(
      title: const Text('Mes véhicules'),
      actions: [
        Builder(
          builder: (context) => IconButton(
            tooltip: 'Menu',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addVehicle,
      icon: const Icon(Icons.add),
      label: const Text('Ajouter un véhicule'),
    ),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/trips/search'),
              icon: const Icon(Icons.event_seat_outlined),
              label: const Text('Faire une demande de réservation'),
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(child: _buildBody(widget.vehicleProvider)),
      ],
    ),
  );

  Widget _buildBody(VehicleProvider provider) {
    final vehicles = provider.vehicles;

    if (provider.errorMessage != null && vehicles.isEmpty) {
      return _ErrorView(
        message: provider.errorMessage!,
        onRetry: () =>
            provider.listenToUserVehicles(ownerId: widget.ownerId),
      );
    }

    if (vehicles.isEmpty) {
      return const _EmptyVehiclesView();
    }

    return RefreshIndicator(
      onRefresh: () async =>
          provider.listenToUserVehicles(ownerId: widget.ownerId),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: vehicles.length,
        itemBuilder: (context, index) {
          final VehicleEntity vehicle = vehicles[index];
          return VehicleCard(vehicle: vehicle);
        },
      ),
    );
  }
}

class _EmptyVehiclesView extends StatelessWidget {
  const _EmptyVehiclesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun véhicule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n’avez encore ajouté aucun véhicule.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
