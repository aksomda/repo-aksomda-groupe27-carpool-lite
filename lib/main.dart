import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'features/notification/data/services/notification_service.dart';
import 'firebase_options.dart';

// =======================================================
// NOTIFICATIONS EN ARRIÈRE-PLAN
// =======================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint("Message reçu en arrière-plan : ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // =======================================================
  // FIREBASE
  // =======================================================
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // =======================================================
  // NOTIFICATIONS BACKGROUND
  // =======================================================
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // =======================================================
  // INITIALISATION NOTIFICATIONS
  // =======================================================
  final notificationService = NotificationService();
  await notificationService.initialize();

  // =======================================================
  // TOKEN FCM
  // =======================================================
  final fcmToken = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM Token: $fcmToken");

  // =======================================================
  // LISTENER EN PREMIER PLAN
  // =======================================================
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint("Message reçu en premier plan !");
    debugPrint("Titre: ${message.notification?.title}");
    debugPrint("Corps: ${message.notification?.body}");
  });

  runApp(
    const ProviderScope(
      child: CarpoolLiteApp(),
    ),
  );
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
