import 'package:flutter/material.dart';

class ConversationsScreen extends StatelessWidget {
 const ConversationsScreen({super.key});
 @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Conversations')), body: const Center(child: Text('Conversations — module prêt à être raccordé aux données Firestore.')));
}
