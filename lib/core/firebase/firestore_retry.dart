import 'dart:async';

/// Réessaie une opération Firestore transitoirement indisponible.
class FirestoreRetry {
  FirestoreRetry._();

  static Future<T> run<T>(
    Future<T> Function() operation, {
    int maxAttempts = 3,
  }) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error, stackTrace) {
        lastError = error;
        lastStackTrace = stackTrace;
        if (attempt < maxAttempts) {
          await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
        }
      }
    }

    Error.throwWithStackTrace(lastError!, lastStackTrace!);
  }

  static Stream<T> runStream<T>(
    Stream<T> Function() operation, {
    int maxAttempts = 5,
  }) async* {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        yield* operation();
        return;
      } catch (_) {
        if (attempt == maxAttempts) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 250 * attempt));
      }
    }
  }
}
