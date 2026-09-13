import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin
  _localNotifications =
  FlutterLocalNotificationsPlugin();

  static const String channelId =
      'carpool_notifications';

  static const String channelName =
      'CarPool Lite';

  static const String channelDescription =
      'Notifications de CarPool Lite';

  /// Initialise le système de notifications
  Future<void> initialize() async {
    // --------------------------------------------------
    // 1. Permissions FCM
    // --------------------------------------------------

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'Permission notification : '
          '${settings.authorizationStatus}',
    );

    // --------------------------------------------------
    // 2. Configuration Android
    // --------------------------------------------------

    const androidInitialization =
    AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // --------------------------------------------------
    // 3. Configuration iOS
    // --------------------------------------------------

    const iosInitialization =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // --------------------------------------------------
    // 4. Initialisation notifications locales
    // --------------------------------------------------

    const initializationSettings =
    InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
      _onNotificationTapped,
    );

    // --------------------------------------------------
    // 5. Création du channel Android
    // --------------------------------------------------

    const androidChannel =
    AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
    );

    final androidPlugin =
    _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      androidChannel,
    );

    // --------------------------------------------------
    // 6. Récupération du token FCM
    // --------------------------------------------------

    final token = await getToken();

    debugPrint('FCM TOKEN : $token');

    // --------------------------------------------------
    // 7. Écoute des changements de token
    // --------------------------------------------------

    _messaging.onTokenRefresh.listen(
          (newToken) {
        debugPrint(
          'Nouveau FCM TOKEN : $newToken',
        );

        // Ici tu pourras sauvegarder
        // le nouveau token dans Firestore.
      },
    );

    // --------------------------------------------------
    // 8. Notification lorsque l'application
    //    est au premier plan
    // --------------------------------------------------

    FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );

    // --------------------------------------------------
    // 9. Application ouverte depuis une notification
    // --------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationOpened,
    );

    // --------------------------------------------------
    // 10. Vérifier si l'application a été
    //     ouverte depuis une notification
    // --------------------------------------------------

    final initialMessage =
    await _messaging.getInitialMessage();

    if (initialMessage != null) {
      _handleNotificationOpened(
        initialMessage,
      );
    }
  }

  // ==================================================
  // TOKEN FCM
  // ==================================================

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint(
        'Erreur récupération FCM token : $e',
      );

      return null;
    }
  }

  // ==================================================
  // NOTIFICATION FOREGROUND
  // ==================================================

  Future<void> _handleForegroundMessage(
      RemoteMessage message,
      ) async {
    debugPrint(
      'Notification reçue au premier plan',
    );

    debugPrint(
      'Title : ${message.notification?.title}',
    );

    debugPrint(
      'Body : ${message.notification?.body}',
    );

    debugPrint(
      'Data : ${message.data}',
    );

    final notification =
        message.notification;

    if (notification == null) {
      return;
    }

    await showLocalNotification(
      title: notification.title ??
          'CarPool Lite',
      body: notification.body ??
          '',
      payload: message.data,
    );
  }

  // ==================================================
  // NOTIFICATION LOCALE
  // ==================================================

  Future<void> showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const androidDetails =
    AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails =
    NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload?.entries
          .map(
            (entry) =>
        '${entry.key}=${entry.value}',
      )
          .join('&'),
    );
  }

  // ==================================================
  // NOTIFICATION CLIQUÉE
  // ==================================================

  void _onNotificationTapped(
      NotificationResponse response,
      ) {
    final payload = response.payload;

    debugPrint(
      'Notification locale cliquée : $payload',
    );

    if (payload == null) {
      return;
    }

    _handlePayload(payload);
  }

  // ==================================================
  // APPLICATION OUVERTE DEPUIS FCM
  // ==================================================

  void _handleNotificationOpened(
      RemoteMessage message,
      ) {
    debugPrint(
      'Notification FCM ouverte',
    );

    debugPrint(
      'Data : ${message.data}',
    );

    _handleData(message.data);
  }

  // ==================================================
  // TRAITEMENT DES DATA FCM
  // ==================================================

  void _handleData(
      Map<String, dynamic> data,
      ) {
    final type = data['type'];

    switch (type) {
      case 'chat':
        final senderId =
        data['senderId'];

        final receiverId =
        data['receiverId'];

        final messageId =
        data['messageId'];

        debugPrint(
          'Notification chat',
        );

        debugPrint(
          'senderId : $senderId',
        );

        debugPrint(
          'receiverId : $receiverId',
        );

        debugPrint(
          'messageId : $messageId',
        );

        break;

      case 'ride':
        debugPrint(
          'Notification trajet',
        );


        break;

      default:
        debugPrint(
          'Type notification inconnu : $type',
        );
    }
  }

  // ==================================================
  // PAYLOAD NOTIFICATION LOCALE
  // ==================================================

  void _handlePayload(
      String payload,
      ) {
    final data = <String, String>{};

    for (final item
    in payload.split('&')) {
      final parts = item.split('=');

      if (parts.length == 2) {
        data[parts[0]] = parts[1];
      }
    }

    _handleData(data);
  }

  // ==================================================
  // SUPPRIMER TOUTES LES NOTIFICATIONS
  // ==================================================

  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }

  // ==================================================
  // SUPPRIMER UNE NOTIFICATION
  // ==================================================

  Future<void> cancel(
      int notificationId,
      ) async {
    await _localNotifications.cancel(
      id: notificationId,
    );
  }

// ============================================================
// REGISTER DEVICE
// ============================================================

  Future<void> registerDevice({
    required String userId,
  }) async {
    final token =
    await FirebaseMessaging.instance.getToken();

    if (token == null || token.isEmpty) {
      return;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('devices')
        .doc(token)
        .set(
      {
        'fcmToken': token,
        'platform': 'android',
        'createdAt':
        FieldValue.serverTimestamp(),
        'updatedAt':
        FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    FirebaseMessaging.instance
        .onTokenRefresh
        .listen((newToken) async {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(newToken)
          .set(
        {
          'fcmToken': newToken,
          'platform': 'android',
          'updatedAt':
          FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }
}