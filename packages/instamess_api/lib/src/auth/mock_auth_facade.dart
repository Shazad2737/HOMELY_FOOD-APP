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
    required String mobile,
    required String password,
  }) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 150));

    if (mobile.isEmpty || password.isEmpty) {
      return left(AuthFailures.validation('Invalid credentials'));
    }

    final user = User(
      id: 'mock-${mobile.hashCode}',
      name: 'Mock User',
      mobile: mobile,
      active: true,
      createdAt: DateTime.now(),
    );

    final token = 'mock-token-${mobile.hashCode}';

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

  @override
  Future<Either<Failure, SignupResponse>> signUp({
    required String name,
    required String mobile,
    required String password,
    required String confirmPassword,
    List<SignupLocationInput>? locations,
  }) async {
    // simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (name.isEmpty || mobile.isEmpty || password.isEmpty) {
      return left(AuthFailures.validation('All fields are required'));
    }

    if (password != confirmPassword) {
      return left(AuthFailures.validation('Passwords do not match'));
    }

    // Create a mock signup response (no session stored yet)
    final signupResponse = SignupResponse(
      customerId: 'mock-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      mobile: mobile,
      requiresOtpVerification: true,
      redirectTo: 'otp-verification',
    );

    return right(signupResponse);
  }

  @override
  Future<Either<Failure, String>> resendOtp({
    required String mobile,
    String type = 'signup',
  }) {
    // TODO: implement resendOtp
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String mobile,
    required String otp,
    String type = 'signup',
  }) {
    // TODO: implement verifyOtp
    throw UnimplementedError();
  }
}
