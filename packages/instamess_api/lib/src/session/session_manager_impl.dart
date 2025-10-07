import 'dart:async';
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/session/i_session_manager.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// {@template session_manager_impl}
/// Implementation of [ISessionManager] using secure storage.
///
/// Manages complete session state including authentication tokens, user data,
/// and selected role with reactive updates. Provides atomic operations and
/// proper error handling using fpdart.
/// {@endtemplate}
class SessionManagerImpl implements ISessionManager {
  /// {@macro session_manager_impl}
  SessionManagerImpl({
    required IStorageController storageController,
  }) : _storageController = storageController {
    _initializeStreams();
  }

  final IStorageController _storageController;

  // Stream controllers for reactive updates
  final StreamController<Option<String>> _tokenController =
      StreamController<Option<String>>.broadcast();
  final StreamController<Option<User>> _userController =
      StreamController<Option<User>>.broadcast();
  final StreamController<Option<SessionData>> _sessionController =
      StreamController<Option<SessionData>>.broadcast();

  // Current state cache
  Option<String> _currentToken = const None();
  Option<User> _currentUser = const None();
  CancelToken _cancelToken = CancelToken();

  void _initializeStreams() {
    // Initialize with current state
    _loadInitialState();

    // Set up session stream to combine token, user, and role
    _setupSessionStream();
  }

  void _loadInitialState() {
    // Load token
    getToken().run().then((tokenOption) {
      _currentToken = tokenOption;
      _tokenController.add(tokenOption);
    });

    // Load user
    getUser().run().then((userOption) {
      _currentUser = userOption;
      _userController.add(userOption);
    });
  }

  void _setupSessionStream() {
    // Listen to all three streams and combine them for session stream
    void updateSessionStream() {
      // Session exists if both token and user exist
      final sessionOption = _currentToken.flatMap(
        (token) => _currentUser.map(
          (user) => SessionData(user: user),
        ),
      );

      _sessionController.add(sessionOption);
    }

    // Update session whenever any component changes
    _tokenController.stream.listen((_) => updateSessionStream());
    _userController.stream.listen((_) => updateSessionStream());
  }

  // Token management methods
  @override
  TaskOption<String> getToken() {
    return TaskOption(() async {
      try {
        final tokenEither = await _storageController.get(key: StorageKey.token);
        return tokenEither.fold(
          (failure) {
            log('Failed to get token from storage: $failure');
            return const None();
          },
          (token) {
            if (token.isEmpty) {
              return const None();
            }

            // Ensure we have a raw JWT (strip "Bearer " if present)
            final rawToken =
                token.startsWith('Bearer ') ? token.substring(7) : token;

            // Proactively check if token is expired (as a hint)
            try {
              if (JwtDecoder.isExpired(rawToken)) {
                log('Token is expired, treating as no token');
                // Don't clear here - let the server be authoritative
                // Just treat as no token for this request
                // TODO: uncomment the line below
                // return const None();
              }
            } catch (e) {
              log('Error checking JWT expiry: $e');
              // If we can't parse the JWT, still return it
              // Let the server decide if it's valid
            }

            return Some(rawToken);
          },
        );
      } catch (e, s) {
        log('Error getting token: $e', stackTrace: s);
        return const None();
      }
    });
  }

  @override
  TaskEither<StorageFailure, Unit> setToken(String token) {
    return TaskEither(() async {
      try {
        // Normalize token: ensure we store raw JWT without "Bearer " prefix
        final rawToken =
            token.startsWith('Bearer ') ? token.substring(7) : token;

        final result = await _storageController.save(
          key: StorageKey.token,
          value: rawToken,
        );

        return result.fold(
          left,
          (_) {
            // Create new cancel token for the new session
            if (!_cancelToken.isCancelled) {
              _cancelToken.cancel('New session started');
            }
            _cancelToken = CancelToken();

            // Update reactive stream
            _currentToken = Some(rawToken);
            _tokenController.add(_currentToken);
            return right(unit);
          },
        );
      } catch (e, s) {
        log('Error setting token: $e', stackTrace: s);
        return left(
          StorageFailure(
            code: 500,
            message: 'Failed to save token: $e',
          ),
        );
      }
    });
  }

  // User management methods
  @override
  TaskOption<User> getUser() {
    return TaskOption(() async {
      try {
        final userEither = await _storageController.get(key: StorageKey.user);
        return userEither.fold(
          (failure) {
            log('Failed to get user from storage: $failure');
            return const None();
          },
          Some.new,
        );
      } catch (e, s) {
        log('Error getting user: $e', stackTrace: s);
        return const None();
      }
    });
  }

  @override
  TaskEither<StorageFailure, Unit> setUser(User user) {
    return TaskEither(() async {
      try {
        final result = await _storageController.save(
          key: StorageKey.user,
          value: user,
        );

        return result.fold(
          left,
          (_) {
            // Update reactive stream
            _currentUser = Some(user);
            _userController.add(_currentUser);
            return right(unit);
          },
        );
      } catch (e, s) {
        log('Error setting user: $e', stackTrace: s);
        return left(
          StorageFailure(
            code: 500,
            message: 'Failed to save user: $e',
          ),
        );
      }
    });
  }

  // Combined session operations
  @override
  TaskEither<StorageFailure, Unit> setSession({
    required String token,
    required User user,
  }) {
    return TaskEither(() async {
      try {
        // Atomic operation: set all session data together
        final tokenResult = await setToken(token).run();
        if (tokenResult.isLeft()) {
          return tokenResult;
        }

        final userResult = await setUser(user).run();
        if (userResult.isLeft()) {
          // Rollback token
          await _storageController.delete(key: StorageKey.token);
          return userResult;
        }

        return right(unit);
      } catch (e, s) {
        log('Error setting session: $e', stackTrace: s);
        return left(
          StorageFailure(
            code: 500,
            message: 'Failed to set session: $e',
          ),
        );
      }
    });
  }

  @override
  TaskEither<StorageFailure, Option<SessionData>> getSession() {
    return TaskEither(() async {
      try {
        final tokenOption = await getToken().run();
        final userOption = await getUser().run();

        // Session exists if both token and user exist
        final sessionOption = tokenOption.flatMap(
          (token) => userOption.map((user) {
            return SessionData(
              user: user,
            );
          }),
        );

        return right(sessionOption);
      } catch (e, s) {
        log('Error getting session: $e', stackTrace: s);
        return left(
          StorageFailure(
            code: 500,
            message: 'Failed to get session: $e',
          ),
        );
      }
    });
  }

  @override
  TaskEither<StorageFailure, Unit> clear() {
    return TaskEither(() async {
      try {
        // Atomic operation: clear all session-related data
        final tokenResult =
            await _storageController.delete(key: StorageKey.token);
        final userResult =
            await _storageController.delete(key: StorageKey.user);

        // Check if any operation failed
        final failures = [tokenResult, userResult]
            .where((result) => result.isLeft())
            .map((result) => result.fold((l) => l, (r) => null))
            .where((failure) => failure != null)
            .cast<StorageFailure>()
            .toList();

        if (failures.isNotEmpty) {
          final firstFailure = failures.first;
          log('Failed to clear session data: $firstFailure');
          return left(firstFailure);
        }

        // Cancel any in-flight requests
        if (!_cancelToken.isCancelled) {
          _cancelToken.cancel('Session cleared');
        }

        // Create new cancel token for future requests
        _cancelToken = CancelToken();

        // Update reactive streams
        _currentToken = const None();
        _currentUser = const None();

        _tokenController.add(_currentToken);
        _userController.add(_currentUser);

        return right(unit);
      } catch (e, s) {
        log('Error clearing session: $e', stackTrace: s);
        return left(
          StorageFailure(
            code: 500,
            message: 'Failed to clear session: $e',
          ),
        );
      }
    });
  }

  // Reactive streams
  @override
  Stream<Option<String>> get token$ => _tokenController.stream;

  @override
  Stream<Option<User>> get user$ => _userController.stream;

  @override
  Stream<Option<SessionData>> get session$ => _sessionController.stream;

  // State checks
  @override
  bool get isAuthenticated => _currentToken.isSome();

  @override
  CancelToken get cancelToken => _cancelToken;

  /// Dispose resources
  void dispose() {
    _tokenController.close();
    _userController.close();
    _sessionController.close();
  }
}
