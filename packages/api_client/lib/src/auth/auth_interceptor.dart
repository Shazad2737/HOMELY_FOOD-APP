import 'dart:developer';

import 'package:api_client/src/auth/auth_token_provider.dart';
import 'package:dio/dio.dart';

/// {@template auth_interceptor}
/// Dio interceptor that handles authentication headers and 401 responses.
///
/// Automatically adds Authorization headers to requests that require auth
/// and clears the session when 401 responses are received.
/// {@endtemplate}
class AuthInterceptor extends InterceptorsWrapper {
  /// {@macro auth_interceptor}
  AuthInterceptor({required AuthTokenProvider tokenProvider})
      : _tokenProvider = tokenProvider;

  final AuthTokenProvider _tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Check if this request requires authentication
    final authRequired = options.extra['authRequired'] as bool? ?? true;

    if (authRequired) {
      // Get token and add Authorization header if present
      final tokenOption = await _tokenProvider.getToken().run();

      tokenOption.match(
        () {
          // No token available - proceed without Authorization header
          log('No token available for authenticated request to ${options.path}');
        },
        (token) {
          // Add Bearer token to headers
          options.headers['Authorization'] = 'Bearer $token';
          log('Added Authorization header for request to ${options.path}');
        },
      );
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 Unauthorized responses
    if (err.response?.statusCode == 401) {
      // Don't clear session for authentication endpoints where 401 is a valid
      // business response (wrong credentials, not session expired)
      final path = err.requestOptions.path;
      final isAuthEndpoint = path.contains('auth/login') ||
          path.contains('auth/signup') ||
          path.contains('auth/register') ||
          path.contains('auth/otp') ||
          path.contains('auth/verify');

      if (!isAuthEndpoint) {
        log('Received 401 response on protected endpoint, clearing session');
        // Clear session and let app layer handle the state change
        await _tokenProvider.clearOnUnauthorized().run();
      } else {
        log('Received 401 response on auth endpoint, not clearing session');
      }
    }

    handler.next(err);
  }
}
