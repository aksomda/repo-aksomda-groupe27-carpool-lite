import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/firebase/firebase_status.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation globale de Firebase pour Firestore, Auth et Cloud Messaging.
  // DefaultFirebaseOptions.currentPlatform vient de firebase_options.dart,
  // généré par `flutterfire configure` pour le projet "carpoollite".
  // On garde un try/catch : si jamais ce fichier venait à être supprimé ou
  // mal régénéré, l'application démarre quand même en mode local au lieu
  // de planter, et les fonctionnalités concernées basculent sur des
  // données en mémoire.
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseStatus.available = true;

    // Persistance hors-ligne : Firestore garde un cache local et l'affiche
    // immédiatement en cas de coupure réseau, au lieu de laisser l'UI
    // bloquée en attente d'une réponse serveur. Fonctionne sur mobile
    // comme sur web (IndexedDB) avec les versions récentes du SDK.
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );
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
