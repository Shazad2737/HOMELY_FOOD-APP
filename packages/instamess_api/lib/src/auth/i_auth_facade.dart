import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart' show ISessionManager;
import 'package:instamess_api/src/auth/models/models.dart';
import 'package:instamess_api/src/session/i_session_manager.dart'
    show ISessionManager;
import 'package:instamess_api/src/session/session.dart' show ISessionManager;

/// Interface for authentication related tasks such as signing in,
/// signing out, and getting the current user.
///
/// Uses consistent error handling with [Failure] types and delegates
/// session management to [ISessionManager] for better architecture.
abstract class IAuthFacade {
  /// Signs in a user with the given email and password.
  ///
  /// Returns [User] if successful, otherwise [Failure]
  Future<Either<Failure, User>> signIn({
    required String mobile,
    required String password,
  });

  /// Signs up a new user with the given details
  ///
  /// Returns [SignupResponse] if successful, otherwise [Failure]
  /// Note: This does not authenticate the user. OTP verification is required.
  /// [locations] is optional - users can add delivery addresses later
  Future<Either<Failure, SignupResponse>> signUp({
    required String name,
    required String mobile,
    required String password,
    required String confirmPassword,
    List<SignupLocationInput>? locations,
  });

  /// Signs out the current user.
  ///
  /// Returns [Unit] if successful, otherwise [Failure]
  Future<Either<Failure, Unit>> signOut();

  /// Gets the authenticated user
  ///
  /// Returns user if token is valid, otherwise [Failure]
  Future<Either<Failure, User>> getAuthenticatedUser();

  /// Verifies OTP for signup or password reset
  ///
  /// Returns [User] with token if successful, otherwise [Failure]
  Future<Either<Failure, User>> verifyOtp({
    required String mobile,
    required String otp,
    String type = 'signup',
  });

  /// Resends OTP to the user's mobile
  ///
  /// Returns success message if successful, otherwise [Failure]
  Future<Either<Failure, String>> resendOtp({
    required String mobile,
    String type = 'signup',
  });
}
