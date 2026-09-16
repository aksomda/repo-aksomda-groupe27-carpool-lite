import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

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
    body: const Center(
      child: Text(
        'Mes véhicules — module prêt à être raccordé aux données Firestore.',
      ),
    ),
  );
}
