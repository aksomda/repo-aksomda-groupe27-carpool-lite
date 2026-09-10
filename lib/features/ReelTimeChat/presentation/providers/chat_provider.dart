import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories_impl/chat_repository_mock.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/get_messages.dart';
import '../../domain/usecases/get_user_messages.dart';
import '../../domain/usecases/mark_messages_as_read.dart';
import '../../domain/usecases/send_message.dart';

// ============================================================
// REPOSITORY MOCK
// ============================================================

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = ChatRepositoryMock();

  ref.onDispose(repository.dispose);

  return repository;
});


// ============================================================
// USE CASE : ENVOYER UN MESSAGE
// ============================================================

final sendMessageUseCaseProvider = Provider<SendMessage>((ref) {
  return SendMessage(
    ref.watch(chatRepositoryProvider),
  );
});

// ============================================================
// USE CASE : RÉCUPÉRER LES MESSAGES
// ============================================================

final getMessagesUseCaseProvider = Provider<GetMessages>((ref) {
  return GetMessages(
    ref.watch(chatRepositoryProvider),
  );
});

// ============================================================
// USE CASE : RÉCUPÉRER LES MESSAGES DE L'UTILISATEUR
// ============================================================

final getUserMessagesUseCaseProvider = Provider<GetUserMessages>((ref) {
  return GetUserMessages(
    ref.watch(chatRepositoryProvider),
  );
});

// ============================================================
// USE CASE : MARQUER COMME LU
// ============================================================

final markMessagesAsReadUseCaseProvider =
Provider<MarkMessagesAsRead>((ref) {
  return MarkMessagesAsRead(
    ref.watch(chatRepositoryProvider),
  );
});

// ============================================================
// PARAMÈTRES CONVERSATION
// ============================================================

class ChatParams {
  final String currentUserId;
  final String contactId;

  const ChatParams({
    required this.currentUserId,
    required this.contactId,
  });

  @override
  bool operator ==(Object other) {
    return other is ChatParams &&
        other.currentUserId == currentUserId &&
        other.contactId == contactId;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentUserId,
      contactId,
    );
  }
}

// ============================================================
// STREAM : CONVERSATION
// ============================================================

final messagesProvider =
StreamProvider.autoDispose.family<List<Message>, ChatParams>(
      (ref, params) {
    final useCase = ref.watch(
      getMessagesUseCaseProvider,
    );

    return useCase(
      currentUserId: params.currentUserId,
      contactId: params.contactId,
    );
  },
);

// ============================================================
// STREAM : LISTE DES CONVERSATIONS
// ============================================================

final userMessagesProvider =
StreamProvider.autoDispose.family<List<Message>, String>(
      (ref, currentUserId) {
    final useCase = ref.watch(
      getUserMessagesUseCaseProvider,
    );

    return useCase(currentUserId);
  },
);

// ============================================================
// ENVOYER UN MESSAGE
// ============================================================

final sendMessageProvider =
Provider<Future<void> Function(
    String text,
    String senderId,
    String receiverId,
    )>((ref) {
  final useCase = ref.watch(
    sendMessageUseCaseProvider,
  );

  return (
      String text,
      String senderId,
      String receiverId,
      ) {
    return useCase(
      text: text,
      senderId: senderId,
      receiverId: receiverId,
    );
  };
});

// ============================================================
// MARQUER LES MESSAGES COMME LUS
// ============================================================

final markMessagesAsReadProvider =
Provider<Future<void> Function({
required String currentUserId,
required String contactId,
})>((ref) {
  final useCase = ref.watch(
    markMessagesAsReadUseCaseProvider,
  );

  return ({
    required String currentUserId,
    required String contactId,
  }) {
    return useCase(
      currentUserId: currentUserId,
      contactId: contactId,
    );
  };
});