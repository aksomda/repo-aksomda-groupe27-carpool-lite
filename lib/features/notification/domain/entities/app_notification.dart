class AppNotification {
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

  const AppNotification({
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
}