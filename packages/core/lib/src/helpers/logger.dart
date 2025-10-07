import 'dart:developer';

/// Helper class for logging errors into the console
class Logger {
  /// Logs an error message into the console
  ///  with optional error and stack trace
  static void logError(
    String message,
    dynamic error, {
    StackTrace? stackTrace,
  }) {
    log('$message\n$error', stackTrace: stackTrace);
  }
}
