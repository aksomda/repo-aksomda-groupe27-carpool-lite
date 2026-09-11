import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:repo_aksomda_groupe27_carpool_lite/features/notification/presentation/providers/notification_provider.dart';

void main() {
  test(
    'notificationsStreamProvider doit être créé correctement',
        () async {
      final container = ProviderContainer();

      addTearDown(container.dispose);

      final provider = notificationsStreamProvider('user1');

      final result = container.read(provider);

      expect(result, isA<AsyncValue>());
    },
  );
}