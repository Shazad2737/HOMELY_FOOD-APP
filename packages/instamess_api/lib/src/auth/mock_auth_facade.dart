import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template mock_auth_facade}
/// Mock authentication facade for testing and development.
///
/// Simulates authentication operations without requiring a real backend.
/// Uses SessionManager for consistent state management.
/// {@endtemplate}
class MockAuthFacade implements IAuthFacade {
  /// {@macro mock_auth_facade}
  const MockAuthFacade({required this.sessionManager});

  final ISessionManager sessionManager;

  /// Signs in a user with the given username and password.
  ///
  /// This mock accepts any non-empty username and password and returns a
  /// deterministic fake user and token. For invalid input it returns a failure.
  @override
  Future<Either<Failure, User>> signIn({
    required String username,
    required String password,
  }) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (username.isEmpty || password.isEmpty) {
      return left(AuthFailures.validation('Invalid credentials'));
    }

    final user = User(
      id: 'mock-${username.hashCode}',
      name: 'Mock User',
      username: username,
      active: true,
      createdAt: DateTime.now(),
    );

    final token = 'mock-token-${username.hashCode}';

    // Use SessionManager to store session data atomically
    final setSessionResult = await sessionManager
        .setSession(
          token: token,
          user: user,
        )
        .run();

    return setSessionResult.fold(
      (storageFailure) => left(AuthFailures.fromStorageFailure(storageFailure)),
      (_) => right(user),
    );
  }

  /// Signs out the current user.
  @override
  Future<Either<Failure, Unit>> signOut() async {
    final clearResult = await sessionManager.clear().run();
    return clearResult.fold(
      (storageFailure) => left(AuthFailures.fromStorageFailure(storageFailure)),
      right,
    );
  }

  /// Returns user with selected role if available, otherwise a failure.
  @override
  Future<Either<Failure, User>> getAuthenticatedUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final sessionResult = await sessionManager.getSession().run();

    return sessionResult.fold(
      (storageFailure) => left(AuthFailures.fromStorageFailure(storageFailure)),
      (sessionOption) => sessionOption.fold(
        () => left(AuthFailures.unauthorized()),
        (sessionData) {
          return right(sessionData.user);
        },
      ),
    );
  }
}
