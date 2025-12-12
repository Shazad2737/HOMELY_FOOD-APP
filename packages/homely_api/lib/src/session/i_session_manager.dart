import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

/// {@template session_manager}
/// Interface for managing complete user session state including authentication
/// tokens, user data, and session lifecycle.
///
/// Provides a single source of truth for all session state, replacing direct
/// storage access with a reactive, functional approach using fpdart.
/// {@endtemplate}
abstract class ISessionManager {
  // Token management methods
  /// Gets the current raw JWT token if available.
  ///
  /// Returns [TaskOption<String>] where:
  /// - [some(token)] if a valid token exists
  /// - [none()] if no token is present (valid unauthenticated state)
  ///
  /// Note: This is not an error condition - absence of token is normal.
  TaskOption<String> getToken();

  /// Sets the authentication token.
  ///
  /// [token] should be the raw JWT without "Bearer " prefix.
  /// Returns [TaskEither<StorageFailure, Unit>] to handle storage failures.
  TaskEither<StorageFailure, Unit> setToken(String token);

  // User management methods
  /// Gets the current authenticated user if available.
  ///
  /// Returns [TaskOption<User>] where:
  /// - [some(user)] if user data exists
  /// - [none()] if no user data is present
  TaskOption<User> getUser();

  /// Sets the authenticated user data.
  ///
  /// Returns [TaskEither<StorageFailure, Unit>] to handle storage failures.
  TaskEither<StorageFailure, Unit> setUser(User user);

  // Combined session operations
  /// Sets complete session data atomically.
  ///
  /// This ensures all session components are set together or none at all.
  TaskEither<StorageFailure, Unit> setSession({
    required String token,
    required User user,
  });

  /// Gets complete session data if available.
  ///
  /// Returns [TaskEither<StorageFailure, Option<SessionData>>] where:
  /// - [some(sessionData)] if both token and user exist
  /// - [none()] if session is incomplete or doesn't exist
  /// - [left(failure)] if storage errors occur
  TaskEither<StorageFailure, Option<SessionData>> getSession();

  /// Clears the current session (token, user, and role data).
  ///
  /// Returns [TaskEither<StorageFailure, Unit>] to handle storage failures.
  /// This should be an atomic operation that clears all session-related data.
  TaskEither<StorageFailure, Unit> clear();

  // Reactive streams
  /// Reactive stream of token state changes.
  ///
  /// Emits:
  /// - [some(token)] when user logs in or token is refreshed
  /// - [none()] when user logs out or session is cleared
  Stream<Option<String>> get token$;

  /// Reactive stream of user state changes.
  ///
  /// Emits:
  /// - [some(user)] when user data is set or updated
  /// - [none()] when user data is cleared
  Stream<Option<User>> get user$;

  /// Reactive stream of complete session state changes.
  ///
  /// Emits:
  /// - [some(sessionData)] when session is complete (token + user + optional role)
  /// - [none()] when session is incomplete or cleared
  Stream<Option<SessionData>> get session$;

  // State checks
  /// Checks if the user is currently authenticated
  bool get isAuthenticated;

  /// Gets the current session-scoped cancel token.
  ///
  /// This token is used to cancel in-flight requests when the session ends.
  /// A new token is created each time a session starts.
  CancelToken get cancelToken;
}

/// {@template session_data}
/// Represents complete session data including user and optional role.
/// {@endtemplate}
@immutable
class SessionData {
  /// {@macro session_data}
  const SessionData({
    required this.user,
  });

  /// The authenticated user
  final User user;

  /// Creates a copy with updated fields
  SessionData copyWith({
    User? user,
  }) {
    return SessionData(
      user: user ?? this.user,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionData && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'SessionData(user: $user)';
}
