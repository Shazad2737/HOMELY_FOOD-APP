import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/session/i_session_manager.dart';

/// {@template session_auth_token_provider}
/// Adapter that implements [AuthTokenProvider] using [ISessionManager].
///
/// This bridges the session management layer with the API client's
/// authentication requirements, maintaining clean architectural boundaries.
/// {@endtemplate}
class SessionAuthTokenProvider implements AuthTokenProvider {
  /// {@macro session_auth_token_provider}
  const SessionAuthTokenProvider({
    required ISessionManager sessionManager,
  }) : _sessionManager = sessionManager;

  final ISessionManager _sessionManager;

  @override
  TaskOption<String> getToken() => _sessionManager.getToken();

  @override
  TaskEither<Failure, Unit> clearOnUnauthorized() {
    return _sessionManager.clear().mapLeft(
          // Map StorageFailure to UnknownFailure for API client
          (storageFailure) => UnknownFailure(
            code: storageFailure.code,
            message: storageFailure.message,
          ),
        );
  }

  @override
  Stream<Option<String>> get token$ => _sessionManager.token$;

  @override
  CancelToken get cancelToken => _sessionManager.cancelToken;
}
