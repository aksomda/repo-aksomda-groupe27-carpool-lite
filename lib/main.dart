import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/firebase/firebase_status.dart';
import 'firebase_options.dart';

void main() {
  // runZonedGuarded capte toute erreur non interceptée (y compris pendant
  // l'initialisation de Firebase) pour NE JAMAIS laisser un écran blanc
  // silencieux : on affiche un écran d'erreur explicite à la place.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      try {
        // IMPORTANT : on passe explicitement les options de la plateforme.
        // Sans ce paramètre, Firebase.initializeApp() dépend d'un fichier de
        // configuration natif (google-services.json / GoogleService-Info.plist)
        // qui n'est pas présent dans ce dépôt : l'appel lève alors une
        // exception AVANT que runApp() ne soit appelé, ce qui produit
        // exactement une page blanche (aucun widget n'a encore été monté).
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        FirebaseStatus.markAvailable();

        runApp(const CarpoolLiteApp());
      } catch (error, stackTrace) {
        FirebaseStatus.markUnavailable();
        // On journalise l'erreur réelle dans la console (utile en debug/logcat)
        // puis on affiche un écran lisible plutôt qu'un écran blanc.
        debugPrint('Erreur d\'initialisation Firebase : $error');
        debugPrint('$stackTrace');
        runApp(_InitializationErrorApp(error: error));
      }
    },
    (error, stackTrace) {
      debugPrint('Erreur non interceptée : $error');
      debugPrint('$stackTrace');
    },
  );
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

/// Application de secours affichée UNIQUEMENT si Firebase n'a pas pu
/// s'initialiser (mauvais projet, clé API invalide, pas de réseau, etc.).
/// Remplace la page blanche par un message exploitable pour le débogage,
/// au lieu de planter silencieusement avant runApp().
class _InitializationErrorApp extends StatelessWidget {
  final Object error;

  const _InitializationErrorApp({required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 56,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Connexion à Firebase impossible',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Vérifiez lib/firebase_options.dart (projet Firebase '
                    '"carpoollite"), la présence de google-services.json '
                    '(Android) / GoogleService-Info.plist (iOS) et votre '
                    'connexion réseau. Voir DEPANNAGE_FIRESTORE.md.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
