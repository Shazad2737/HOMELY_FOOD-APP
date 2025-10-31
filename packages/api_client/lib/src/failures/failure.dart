import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:flutter/foundation.dart';

/// Base class for all failures
@immutable
sealed class Failure {
  const Failure(this.code, this.message);

  /// ErrorCode for the failure
  final int code;

  /// Message for the failure, should be in a form presentable to the user
  final String message;

  @override
  String toString() {
    return 'Failure{code: $code, message: $message}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message;

  @override
  int get hashCode => code.hashCode ^ message.hashCode;
}

/// {@template unknown_failure}
/// Class representing an unknown failure
/// {@endtemplate}
class UnknownFailure extends Failure {
  /// {@macro unknown_failure}
  ///
  /// [message] should be in a form presentable to the user
  const UnknownFailure({
    int code = 0,
    String message = 'Unknown error occurred',
  }) : super(code, message);

  @override
  String toString() {
    return 'UnknownFailure{code: $code, message: $message}';
  }
}

/// Base class for all API failures
sealed class ApiFailure extends Failure {
  const ApiFailure(super.code, super.message);
}

/// Base class for all storage failures
class StorageFailure extends Failure {
  /// Create a new instance of [StorageFailure]
  const StorageFailure({
    required int code,
    required String message,
  }) : super(code, message);
}

/// {@template api_validation_failure}
/// Api Validation Failure
/// Thrown when the API returns a 400 or 422 response with validation errors
/// {@endtemplate}
class ApiValidationFailure extends ApiFailure {
  /// {@macro api_validation_failure}
  const ApiValidationFailure(this.errors, String message) : super(422, message);

  /// Create a new instance of [ApiValidationFailure] from json
  ///
  /// Expected format:
  /// ```json
  /// {
  ///   "success": false,
  ///   "message": "Validation error in body",
  ///   "errors": [
  ///     {"field": "mobile", "message": "Invalid format", "type": "string.pattern.base"},
  ///     {"field": "password", "message": "Too short", "type": "string.min"}
  ///   ]
  /// }
  /// ```
  factory ApiValidationFailure.fromJson(Map<String, dynamic> json) {
    try {
      final message = json['message'] as String? ?? 'Validation failed';

      // Handle 'error' key (simple error string)
      if (json.containsKey('error') && json['error'] is String) {
        return ApiValidationFailure(
          const [],
          json['error'] as String,
        );
      }

      // Handle 'errors' array (new format)
      if (json.containsKey('errors') && json['errors'] is List) {
        final errors = (json['errors'] as List)
            .map<ValidationFailureDetail>(
              (e) =>
                  ValidationFailureDetail.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        return ApiValidationFailure(errors, message);
      }

      // Fallback: no errors found
      return ApiValidationFailure(const [], message);
    } on Exception catch (e, s) {
      log('Error parsing ApiValidationFailure: $e', stackTrace: s);
      return const ApiValidationFailure(
        [],
        'Validation failed',
      );
    }
  }

  /// List of validation errors from the API
  final List<ValidationFailureDetail> errors;

  /// Checks if there are any validation errors
  bool get hasErrors => errors.isNotEmpty;

  /// Get error message for a specific field
  String? getErrorForField(String field) {
    try {
      return errors.firstWhere((e) => e.field == field).message;
    } catch (_) {
      return null;
    }
  }

  @override
  String toString() {
    return 'ApiValidationFailure{message: $message, errors: $errors}';
  }
}

/// Failure for 401 Unauthorized
class UnauthorizedFailure extends ApiFailure {
  /// Create a new instance of [UnauthorizedFailure]
  const UnauthorizedFailure() : super(401, 'Unauthorized');
}

/// Failure for 403 Forbidden when account needs verification
class AccountNotVerifiedFailure extends ApiFailure {
  /// Create a new instance of [AccountNotVerifiedFailure]
  const AccountNotVerifiedFailure({
    required this.redirectTo,
    String? message,
  }) : super(403, message ?? 'Account not verified');

  /// Where the user should be redirected (e.g., 'otp-verification')
  final String redirectTo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountNotVerifiedFailure &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          redirectTo == other.redirectTo;

  @override
  int get hashCode => code.hashCode ^ message.hashCode ^ redirectTo.hashCode;

  @override
  String toString() {
    return 'AccountNotVerifiedFailure{code: $code, message: $message, redirectTo: $redirectTo}';
  }
}

/// Failure for 404 Not Found
class NotFoundFailure extends ApiFailure {
  /// Create a new instance of [NotFoundFailure]
  const NotFoundFailure({
    String? message,
  }) : super(404, message ?? 'Not Found');
}

/// Used for unknown failures
class UnknownApiFailure extends ApiFailure {
  /// Create a new instance of [UnknownApiFailure]
  const UnknownApiFailure(super.code, super.message, {this.apiErrorMessage});

  /// Error message from the API. Could be inside 'error' in the response body
  final String? apiErrorMessage;

  @override
  String toString() {
    return 'UnknownApiFailure{apiErrorMessage: $apiErrorMessage}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownApiFailure &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          apiErrorMessage == other.apiErrorMessage;

  @override
  int get hashCode =>
      code.hashCode ^ message.hashCode ^ apiErrorMessage.hashCode;
}
