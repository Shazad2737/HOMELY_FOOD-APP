import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';

/// {@template auth_token_provider}
/// Interface for providing authentication tokens to the API client.
///
/// This abstracts the session dependency for cleaner architectural boundaries.
/// The API client uses this to get tokens and handle unauthorized responses.
/// {@endtemplate}
abstract class AuthTokenProvider {
  /// Gets the current raw JWT token if available.
  ///
  /// Returns [TaskOption<String>] where:
  /// - [some(token)] if a valid token exists
  /// - [none()] if no token is present (valid unauthenticated state)
  TaskOption<String> getToken();

  /// Clears the session when unauthorized response is received.
  ///
  /// This is called by the API client interceptor when a 401 response
  /// is received. Returns [TaskEither] to handle any storage failures.
  TaskEither<Failure, Unit> clearOnUnauthorized();

  /// Stream of token state changes for reactive updates.
  ///
  /// Emits:
  /// - [some(token)] when user logs in or token is refreshed
  /// - [none()] when user logs out or session is cleared
  Stream<Option<String>> get token$;

  /// Gets the current session-scoped cancel token.
  ///
  /// This token is used to cancel in-flight requests when the session ends.
  CancelToken get cancelToken;
}
