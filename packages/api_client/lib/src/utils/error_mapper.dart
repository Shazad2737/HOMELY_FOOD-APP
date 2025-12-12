import 'dart:developer';
import 'dart:io';

import 'package:api_client/api_client.dart';

/// {@template error_mapper}
/// Utility class for mapping DioExceptions to appropriate ApiFailures
/// with robust error parsing and network state detection.
/// {@endtemplate}
class ErrorMapper {
  /// Maps a [DioException] to an appropriate [ApiFailure] with improved
  /// error handling and user-friendly messages.
  static ApiFailure mapDioException(DioException exception, String path) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;

    log('Mapping DioException for $path: ${exception.type}, status: $statusCode');

    // Handle specific HTTP status codes first
    if (statusCode != null) {
      switch (statusCode) {
        case 401:
          return const UnauthorizedFailure();
        case 403:
          // Check for account verification redirect
          if (responseData is Map<String, dynamic>) {
            final errors = responseData['errors'];
            if (errors is Map<String, dynamic> &&
                errors.containsKey('redirectTo')) {
              return AccountNotVerifiedFailure(
                redirectTo: errors['redirectTo'] as String,
                message: _safeParseErrorMessage(responseData) ??
                    'Account not verified',
              );
            }
          }
          // Generic 403 fallback
          return UnknownApiFailure(
            403,
            _safeParseErrorMessage(responseData) ?? 'Access forbidden',
            apiErrorMessage: _safeParseErrorMessage(responseData),
          );
        case 404:
          return NotFoundFailure(
            message:
                _safeParseErrorMessage(responseData) ?? 'Resource not found',
          );
        case 400:
        case 422:
          // Both 400 and 422 can contain validation errors
          return _parseValidationFailure(responseData);
        case >= 500:
          return UnknownApiFailure(
            statusCode,
            _safeParseErrorMessage(responseData) ??
                'Server error occurred. Please try again later.',
            apiErrorMessage: _safeParseErrorMessage(responseData),
          );
        default:
          return UnknownApiFailure(
            statusCode,
            _safeParseErrorMessage(responseData) ?? 'Request failed',
            apiErrorMessage: _safeParseErrorMessage(responseData),
          );
      }
    }

    // Handle network-level errors (no HTTP response)
    return _mapNetworkError(exception);
  }

  /// Maps network-level DioExceptions to user-friendly failures
  static ApiFailure _mapNetworkError(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const UnknownApiFailure(
          408,
          'Request timed out. Please check your connection and try again.',
        );

      case DioExceptionType.connectionError:
        // Check if it's likely an offline condition
        if (_isLikelyOffline(exception)) {
          return const UnknownApiFailure(
            0,
            'No internet connection. Please check your network and try again.',
          );
        }
        return const UnknownApiFailure(
          500,
          'Unable to connect to server. Please try again later.',
        );

      case DioExceptionType.cancel:
        return const UnknownApiFailure(
          0,
          'Request was cancelled.',
        );

      case DioExceptionType.badCertificate:
        return const UnknownApiFailure(
          495,
          'SSL certificate error. Please check your connection.',
        );

      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return UnknownApiFailure(
          500,
          'An unexpected error occurred. Please try again.',
          apiErrorMessage: exception.message,
        );
    }
  }

  /// Safely parses error message from response data
  static String? _safeParseErrorMessage(dynamic responseData) {
    try {
      if (responseData == null) return null;

      // Handle different response data types
      if (responseData is Map<String, dynamic>) {
        // Try common error message keys
        final errorKeys = ['error', 'message', 'detail', 'description'];
        for (final key in errorKeys) {
          final value = responseData[key];
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }

        // Try nested error objects
        final errorObj = responseData['error'];
        if (errorObj is Map<String, dynamic>) {
          final message = errorObj['message'] ?? errorObj['detail'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        return responseData;
      }

      return null;
    } catch (e) {
      log('Error parsing response data: $e');
      return null;
    }
  }

  /// Parses validation failure with safe error handling
  static ApiValidationFailure _parseValidationFailure(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        return ApiValidationFailure.fromJson(responseData);
      }
    } catch (e) {
      log('Error parsing validation failure: $e');
    }

    // Fallback to generic validation failure
    return ApiValidationFailure(
      const [],
      _safeParseErrorMessage(responseData) ?? 'Validation failed',
    );
  }

  /// Detects if the error is likely due to being offline
  static bool _isLikelyOffline(DioException exception) {
    final error = exception.error;

    // Check for common offline error patterns
    if (error is SocketException) {
      final message = error.message.toLowerCase();
      return message.contains('network is unreachable') ||
          message.contains('no route to host') ||
          message.contains('host is unreachable') ||
          message.contains('failed host lookup');
    }

    if (error is HandshakeException) {
      return true; // Often indicates network issues
    }

    // Check exception message for offline indicators
    final message = exception.message?.toLowerCase() ?? '';
    return message.contains('network error') ||
        message.contains('no internet') ||
        message.contains('offline') ||
        message.contains('connection failed');
  }
}
