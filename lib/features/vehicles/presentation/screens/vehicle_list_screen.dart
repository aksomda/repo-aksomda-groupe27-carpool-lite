import 'package:flutter/material.dart';

class VehicleListScreen extends StatelessWidget {
 const VehicleListScreen({super.key});
 @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mes véhicules')), body: const Center(child: Text('Mes véhicules — module prêt à être raccordé aux données Firestore.')));
}
