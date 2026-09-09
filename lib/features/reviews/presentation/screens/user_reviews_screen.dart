import 'package:flutter/material.dart';

class UserReviewsScreen extends StatelessWidget {
 const UserReviewsScreen({super.key});
 @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Mes évaluations')), body: const Center(child: Text('Mes évaluations — module prêt à être raccordé aux données Firestore.')));
}
