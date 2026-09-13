import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notification_provider.dart';

class NotificationsScreen
    extends ConsumerWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    final notifications =
    ref.watch(
      notificationsStreamProvider(userId),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
      ),
      body: notifications.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) =>
            Center(
              child: Text(
                'Erreur : $error',
              ),
            ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Aucune notification',
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final notification =
              items[index];

              return ListTile(
                leading: Icon(
                  notification.isRead
                      ? Icons.notifications_none
                      : Icons.notifications,
                ),
                title: Text(
                  notification.title,
                ),
                subtitle: Text(
                  notification.body,
                ),
                tileColor:
                notification.isRead
                    ? null
                    : Colors.blue
                    .withValues(alpha: 0.08),
                onTap: () async {
                  await ref.read(
                    markNotificationAsReadProvider,
                  )(
                    userId: userId,
                    notificationId:
                    notification.id,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}