import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template auth_facade}
/// Authentication facade
///
/// This class is responsible for handling all authentication related tasks
/// such as signing in, signing up, signing out, and getting the current user.
/// Uses SessionManager for consistent state management and error handling.
/// {@endtemplate}
class AuthFacade implements IAuthFacade {
  /// {@macro auth_facade}
  const AuthFacade({
    required this.apiClient,
    required this.sessionManager,
  });

  /// Api client
  final ApiClient apiClient;

  /// Session manager for authentication state
  final ISessionManager sessionManager;

  @override
  Future<Either<Failure, User>> signIn({
    required String mobile,
    required String password,
  }) async {
    final body = {'mobile': mobile, 'password': password};

    final resEither = await apiClient.post<Map<String, dynamic>>(
      'auth/login',
      body: body,
      authRequired: false,
    );

    return resEither.fold(
      (apiFailure) async => left(AuthFailures.fromApiFailure(apiFailure)),
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            AuthFailures.unknown('Unknown Error occurred while signing in'),
          );
        }

        try {
          final user =
              User.fromJson(body['data']['customer'] as Map<String, dynamic>);
          final token = body['data']['token'] as String?;

          if (token == null) {
            return left(
              AuthFailures.unknown('Unknown Error occurred while signing in'),
            );
          }

          // Normalize token: store raw JWT without "Bearer " prefix
          final rawToken =
              token.startsWith('Bearer ') ? token.substring(7) : token;

          // Use SessionManager to store session data atomically
          final setSessionResult = await sessionManager
              .setSession(
                token: rawToken,
                user: user,
              )
              .run();

          return setSessionResult.fold(
            (storageFailure) =>
                left(AuthFailures.fromStorageFailure(storageFailure)),
            (_) => right(user),
          );
        } catch (e, s) {
          log('Error parsing sign-in response: $e', stackTrace: s);
          return left(
            AuthFailures.unknown('Unknown Error occurred while signing in'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, Unit>> signOut() async {
    final clearResult = await sessionManager.clear().run();
    return clearResult.fold(
      (storageFailure) => left(AuthFailures.fromStorageFailure(storageFailure)),
      right,
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
    final body = {
      'name': name,
      'mobile': mobile,
      'password': password,
      'confirmPassword': confirmPassword,
      if (locations != null && locations.isNotEmpty)
        'locations': locations.map((loc) => loc.toJson()).toList(),
    };

    final resEither = await apiClient.post<Map<String, dynamic>>(
      'auth/signup',
      body: body,
      authRequired: false,
    );

    return resEither.fold(
      (apiFailure) async => left(AuthFailures.fromApiFailure(apiFailure)),
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            AuthFailures.unknown('Unknown error occurred while signing up'),
          );
        }

        try {
          // Parse signup response without storing session
          // Session will be stored after OTP verification
          final signupResponse = SignupResponse.fromJson(body);
          return right(signupResponse);
        } catch (e, s) {
          log('Error parsing sign-up response: $e', stackTrace: s);
          return left(
            AuthFailures.unknown('Unknown Error occurred while signing up'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, User>> getAuthenticatedUser() async {
    try {
      final sessionResult = await sessionManager.getSession().run();

      return sessionResult.fold(
        (storageFailure) =>
            left(AuthFailures.fromStorageFailure(storageFailure)),
        (sessionOption) => sessionOption.fold(
          () => left(AuthFailures.unauthorized()),
          (sessionData) {
            return right(sessionData.user);
          },
        ),
      );
    } catch (e, s) {
      log('Error getting authenticated user: $e', stackTrace: s);
      return left(AuthFailures.unknown('Error getting authenticated user'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String mobile,
    required String otp,
    String type = 'signup',
  }) async {
    final body = {
      'mobile': mobile,
      'otp': otp,
      'type': type,
    };

    final resEither = await apiClient.post<Map<String, dynamic>>(
      'auth/verify-otp',
      body: body,
      authRequired: false,
    );

    return resEither.fold(
      (apiFailure) async => left(AuthFailures.fromApiFailure(apiFailure)),
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            AuthFailures.unknown(
                'Unknown error occurred during OTP verification'),
          );
        }

        try {
          // Parse user and token from response
          final user =
              User.fromJson(body['data']['customer'] as Map<String, dynamic>);
          final token = body['data']['token'] as String?;

          if (token == null) {
            return left(
              AuthFailures.unknown(
                  'Token not found in OTP verification response'),
            );
          }

          // Normalize token: store raw JWT without "Bearer " prefix
          final rawToken =
              token.startsWith('Bearer ') ? token.substring(7) : token;

          // Use SessionManager to store session data atomically
          final setSessionResult = await sessionManager
              .setSession(
                token: rawToken,
                user: user,
              )
              .run();

          return setSessionResult.fold(
            (storageFailure) =>
                left(AuthFailures.fromStorageFailure(storageFailure)),
            (_) => right(user),
          );
        } catch (e, s) {
          log('Error parsing OTP verification response: $e', stackTrace: s);
          return left(
            AuthFailures.unknown(
                'Unknown error occurred during OTP verification'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, String>> resendOtp({
    required String mobile,
    String type = 'signup',
  }) async {
    final body = {
      'mobile': mobile,
      'type': type,
    };

    final resEither = await apiClient.post<Map<String, dynamic>>(
      'auth/resend-otp',
      body: body,
      authRequired: false,
    );

    return resEither.fold(
      (apiFailure) async => left(AuthFailures.fromApiFailure(apiFailure)),
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            AuthFailures.unknown('Unknown error occurred while resending OTP'),
          );
        }

        try {
          final message = body['message'] as String? ?? 'OTP sent successfully';
          return right(message);
        } catch (e, s) {
          log('Error parsing resend OTP response: $e', stackTrace: s);
          return left(
            AuthFailures.unknown('Unknown error occurred while resending OTP'),
          );
        }
      },
    );
  }
}
