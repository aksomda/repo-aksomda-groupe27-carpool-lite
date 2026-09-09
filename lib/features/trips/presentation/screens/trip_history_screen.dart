import 'package:flutter/material.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Historique des trajets')), body: const Center(child: Text('Historique des trajets — module prêt à être raccordé aux données Firestore.')));
}
