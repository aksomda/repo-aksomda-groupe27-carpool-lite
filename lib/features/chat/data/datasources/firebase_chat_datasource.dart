import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../model/message_model.dart';

class FirebaseChatDataSource {
  final FirebaseFirestore firestore;

  FirebaseChatDataSource({
    FirebaseFirestore? firestore,
  }) : firestore =
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  get _messages {
    return firestore.collection('messages');
  }

  // ============================================================
  // ENVOYER UN MESSAGE
  // ============================================================

  Future<void> sendMessage(
      MessageModel message,
      ) async {
    await _messages.add({
      'senderId': message.senderId,
      'receiverId': message.receiverId,
      'text': message.text,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': message.type,
      'participants': [
        message.senderId,
        message.receiverId,
      ],
    });
  }

  // ============================================================
  // MESSAGES D'UNE CONVERSATION
  // ============================================================

  Stream<List<MessageModel>> getMessagesStream({
    required String currentUserId,
    required String contactId,
  }) {
    return _messages
        .where(
      'participants',
      arrayContains: currentUserId,
    )
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map(
            (doc) => MessageModel.fromFirestore(doc),
      )
          .where((message) {
        return (message.senderId == currentUserId &&
            message.receiverId == contactId) ||
            (message.senderId == contactId &&
                message.receiverId == currentUserId);
      }).toList();

      messages.sort(
            (a, b) => a.timestamp.compareTo(b.timestamp),
      );

      return messages;
    });
  }

  // ============================================================
  // TOUS LES MESSAGES DE L'UTILISATEUR
  // ============================================================

  Stream<List<MessageModel>> getUserMessages(
      String currentUserId,
      ) {
    return _messages
        .where(
      'participants',
      arrayContains: currentUserId,
    )
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map(
            (doc) => MessageModel.fromFirestore(doc),
      )
          .toList();

      messages.sort(
            (a, b) => b.timestamp.compareTo(a.timestamp),
      );

      return messages;
    });
  }

  // ============================================================
  // MARQUER UN MESSAGE COMME LU
  // ============================================================

  Future<void> markMessageAsRead(
      String messageId,
      ) async {
    await _messages.doc(messageId).update({
      'isRead': true,
    });
  }

  // ============================================================
  // MARQUER UNE CONVERSATION COMME LUE
  // ============================================================

  Future<void> markConversationAsRead({
    required String currentUserId,
    required String contactId,
  }) async {
    final snapshot = await _messages
        .where(
      'receiverId',
      isEqualTo: currentUserId,
    )
        .where(
      'senderId',
      isEqualTo: contactId,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

// ============================================================
// REGISTER DEVICE
// ============================================================

  Future<void> registerDevice({
    required String userId,
  }) async {
    try {
      final token =
      await FirebaseMessaging.instance.getToken();

      debugPrint('=================================');
      debugPrint('DEVICE REGISTRATION');
      debugPrint('USER ID: $userId');
      debugPrint('FCM TOKEN: $token');
      debugPrint('=================================');

      if (token == null || token.isEmpty) {
        debugPrint(
          '❌ Aucun token FCM disponible',
        );
        return;
      }

      final deviceRef = firestore
          .collection('users')
          .doc(userId)
          .collection('devices')
          .doc(token);

      await deviceRef.set(
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

      debugPrint(
        '✅ Device enregistré dans Firestore',
      );
    } catch (e) {
      debugPrint(
        '❌ Erreur enregistrement device: $e',
      );

      rethrow;
    }
  }


}