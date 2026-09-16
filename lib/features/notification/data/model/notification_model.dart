import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final String? senderId;
  final String? receiverId;
  final String? chatId;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.senderId,
    this.receiverId,
    this.chatId,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    final timestamp = data['createdAt'];

    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? 'general',
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      chatId: data['chatId'],
      isRead: data['isRead'] ?? false,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.now(),
      data: Map<String, dynamic>.from(
        data['data'] ?? {},
      ),
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      senderId: senderId,
      receiverId: receiverId,
      chatId: chatId,
      isRead: isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}