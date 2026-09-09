import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
 const MyBookingsScreen({super.key});
 @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mes réservations')), body: const Center(child: Text('Mes réservations — module prêt à être raccordé aux données Firestore.')));
}
