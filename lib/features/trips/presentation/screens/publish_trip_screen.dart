import 'package:flutter/material.dart';

class PublishTripScreen extends StatelessWidget {
  const PublishTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Publication d'un trajet")),
      body: const Center(
        child: Text(
          "Publication d'un trajet — module prêt à être raccordé aux données Firestore.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
