import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/notification_model.dart';

class FirebaseNotificationDataSource {
  final FirebaseFirestore firestore;

  FirebaseNotificationDataSource({
    FirebaseFirestore? firestore,
  }) : firestore =
      firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>>
  _notifications(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('notifications');
  }

  Stream<List<NotificationModel>> getNotifications(
      String userId,
      ) {
    return _notifications(userId)
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
        NotificationModel.fromFirestore,
      )
          .toList(),
    );
  }

  Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _notifications(userId)
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead(
      String userId,
      ) async {
    final snapshot = await _notifications(userId)
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    if (snapshot.docs.isEmpty) return;

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

  Future<void> saveFcmToken({
    required String userId,
    required String token,
  }) async {
    await firestore
        .collection('users')
        .doc(userId)
        .set(
      {
        'fcmTokens': FieldValue.arrayUnion([token]),
      },
      SetOptions(merge: true),
    );
  }
}