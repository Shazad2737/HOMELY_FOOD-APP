import 'package:api_client/api_client.dart';

/// {@template auth_failures}
/// Utility class for creating authentication-related failures.
///
/// Provides factory methods to create appropriate failure types for
/// authentication operations, ensuring consistent error handling.
/// {@endtemplate}
class AuthFailures {
  AuthFailures._(); // Private constructor to prevent instantiation

  /// Creates an authentication failure from an API failure.
  static Failure fromApiFailure(ApiFailure failure) => failure;

  /// Creates an authentication failure from a storage failure.
  static Failure fromStorageFailure(StorageFailure failure) => failure;

  /// Creates an authentication failure from a general failure.
  static Failure fromFailure(Failure failure) => failure;

  /// Creates an unauthorized authentication failure.
  static UnauthorizedFailure unauthorized([String? message]) {
    return message != null
        ? const UnauthorizedFailure() // Can't customize message in existing type
        : const UnauthorizedFailure();
  }

  /// Creates a validation failure for authentication.
  static ApiValidationFailure validation(String message) {
    return ApiValidationFailure(const [], message);
  }

  /// Creates an unknown authentication failure.
  static UnknownApiFailure unknown(String message, {int code = 500}) {
    return UnknownApiFailure(code, message);
  }

  /// Creates a storage-related authentication failure.
  static StorageFailure storage(String message, {int code = 500}) {
    return StorageFailure(code: code, message: message);
  }
}
