import 'package:flutter/material.dart';

class SearchTripsScreen extends StatelessWidget {
  const SearchTripsScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Recherche de trajets')), body: const Center(child: Text('Recherche de trajets — module prêt à être raccordé aux données Firestore.')));
}
