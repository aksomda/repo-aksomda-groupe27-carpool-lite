import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/firebase/firebase_status.dart';
import 'core/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation globale de Firebase pour Firestore, Auth et Cloud Messaging.
  // On protège l'appel : si aucune configuration Firebase n'est présente
  // (pas de firebase_options.dart / google-services.json), l'application ne
  // doit pas planter au démarrage. Les fonctionnalités qui dépendent de
  // Firestore (ex : gestion des universités) basculent alors sur des
  // données locales en mémoire, pour rester testables graphiquement.
  try {
    await Firebase.initializeApp();
    FirebaseStatus.available = true;
  } catch (e) {
    debugPrint(
      'Firebase indisponible (configuration manquante) : $e\n'
      "L'application démarre en mode local (sans persistance distante).",
    );
    FirebaseStatus.available = false;
  }

  runApp(const CarpoolLiteApp());
}

class CarpoolLiteApp extends StatelessWidget {
  const CarpoolLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Carpool Lite - Covoiturage Universitaire',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
