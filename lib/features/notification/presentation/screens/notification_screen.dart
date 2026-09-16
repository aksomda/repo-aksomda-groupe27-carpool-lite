import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/widgets/user_picker_screen.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../navigation/presentation/widgets/app_drawer.dart';
import '../providers/notification_provider.dart';
import 'compose_notification_screen.dart';

class NotificationsScreen
    extends ConsumerWidget {
  final String userId;

  const NotificationsScreen({
    super.key,
    required this.userId,
  });

  Future<void> _composeNotification(
    BuildContext context,
    String userId,
  ) async {
    final selected = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (_) => UserPickerScreen(
          title: 'Notifier un utilisateur',
          currentUserId: userId,
        ),
      ),
    );

    if (selected == null || !context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComposeNotificationScreen(
          senderId: userId,
          receiverId: selected.uid,
          receiverName: selected.name,
        ),
      ),
    );
  }

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
      drawer: AppDrawer(authProvider: Injector.authProvider),
      appBar: AppBar(
        title: const Text(
          'Notifications',
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _composeNotification(context, userId),
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Nouvelle notification'),
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