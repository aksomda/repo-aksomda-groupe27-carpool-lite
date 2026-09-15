import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injector.dart';
import 'core/firebase/firebase_status.dart';
import 'core/router/app_router.dart';

import 'features/notification/presentation/services/notification_service.dart';
import 'firebase_options.dart';

// =======================================================
// NOTIFICATIONS EN ARRIÈRE-PLAN
// =======================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Message reçu en arrière-plan : ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =======================================================
  // FIREBASE
  // =======================================================
  // FirebaseStatus est lu par tous les dépôts (universités, campus,
  // formations, UFR, niveaux académiques...) pour savoir s'ils doivent
  // utiliser Firestore ou basculer sur leur source de données locale.
  // Sans cet appel à markAvailable(), ils restent TOUJOURS en mode
  // hors-ligne, même quand Firebase est correctement initialisé.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseStatus.markAvailable();
  } catch (e, stackTrace) {
    FirebaseStatus.markUnavailable();
    debugPrint('⚠️ Firebase indisponible, bascule en mode hors-ligne : $e');
    debugPrint('$stackTrace');
  }

  // =======================================================
  // RESTAURATION DE LA SESSION
  // =======================================================
  // Firebase Auth conserve la session d'un lancement à l'autre, mais
  // AuthProvider repartait de zéro : l'utilisateur se retrouvait déconnecté
  // à chaque redémarrage, et tous les écrans qui lisent
  // `Injector.authProvider.user?.uid ?? ''` (demandes de réservation,
  // véhicules, historique de trajets...) interrogeaient Firestore avec un
  // identifiant vide, donc n'affichaient rien.
  //
  // On restaure la session AVANT runApp() pour que la première évaluation
  // des redirections du routeur connaisse déjà l'utilisateur.
  if (FirebaseStatus.available) {
    await Injector.authProvider.checkCurrentUser();
  }

  // =======================================================
  // NOTIFICATIONS (FCM)
  // =======================================================
  // Tout ce bloc est mis en sandbox : sur le web notamment, l'enregistrement
  // du service worker ou l'absence de clé VAPID peuvent faire échouer FCM.
  // Une erreur ici ne doit jamais empêcher runApp() de s'exécuter, sous
  // peine d'obtenir une page blanche silencieuse (ce qui arrivait avant).
  try {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await NotificationService.instance.initialize();

    // Sur le web, getToken() nécessite une clé VAPID (Console Firebase >
    // Cloud Messaging > Configuration web > Génération de paire de clés).
    // Remplacez la valeur ci-dessous par votre propre clé publique.
    final fcmToken = await FirebaseMessaging.instance.getToken(
      vapidKey: kIsWeb
          ? 'BLWOny4p88o2cloWcLqYyUxiYtEDvKQ-frIfnWEvJeCWBHvu3i6lyBFlNgBrcwyl0k39JaYqTH3mhBq182Dpmm0'
          : null,
    );
    debugPrint("FCM Token: $fcmToken");

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('🔔 Message reçu au premier plan !');
      debugPrint('Titre: ${message.notification?.title}');
      debugPrint('Corps: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      final notification = message.notification;

      if (notification != null) {
        await NotificationService.instance.showLocalNotification(
          title: notification.title ?? 'CarPool Lite',
          body: notification.body ?? '',
          payload: message.data,
        );
      }
    });
  } catch (e, stackTrace) {
    debugPrint('⚠️ Initialisation FCM ignorée (non bloquante) : $e');
    debugPrint('$stackTrace');
  }

  runApp(const ProviderScope(child: CarpoolLiteApp()));
}

class CarpoolLiteApp extends StatelessWidget {
  const CarpoolLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Carpool Lite',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1468F5)),
        scaffoldBackgroundColor: const Color(0xFFF8FBFF),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
        ),
      ),
    );
  }
}
