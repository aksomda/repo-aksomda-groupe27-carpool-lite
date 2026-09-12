import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<void> call({
    required String text,
    required String senderId,
    required String receiverId,
  }) async {
    final message = text.trim();

    if (message.isEmpty) {
      throw Exception(
        'Le message ne peut pas être vide.',
      );
    }

    if (senderId.isEmpty) {
      throw Exception(
        'Expéditeur invalide.',
      );
    }

    if (receiverId.isEmpty) {
      throw Exception(
        'Destinataire invalide.',
      );
    }

    await repository.sendMessage(
      text: message,
      senderId: senderId,
      receiverId: receiverId,
    );
  }
}