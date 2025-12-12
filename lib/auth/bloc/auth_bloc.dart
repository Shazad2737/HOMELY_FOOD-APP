import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._authFacade,
    this._sessionManager,
  ) : super(AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      switch (event) {
        case AuthCheckRequestedEvent():
          await _onAuthCheckRequested(event, emit);
        case AuthLogOutRequestedEvent():
          await _onAuthLogOutRequested(event, emit);
        case _AuthSessionChangedEvent():
          await _onSessionChanged(event, emit);
      }
    });

    // Listen to complete session changes instead of just token
    _sessionSubscription = _sessionManager.session$.listen((sessionOption) {
      log(
        'AuthBloc: Session stream fired with: ${sessionOption.isSome() ? "session present" : "no session"}',
      );
      add(_AuthSessionChangedEvent(sessionOption));
    });

    // Immediately check auth state on startup
    add(AuthCheckRequestedEvent());
  }

  final IAuthFacade _authFacade;
  final ISessionManager _sessionManager;
  late final StreamSubscription<dynamic> _sessionSubscription;

  @override
  Future<void> close() {
    _sessionSubscription.cancel();
    return super.close();
  }

  Future<void> _onSessionChanged(
    _AuthSessionChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    event.sessionOption.fold(
      () {
        // No session - user is unauthenticated
        log('AuthBloc: No session found');
        if (state is! Unauthenticated) {
          log('AuthBloc: Emitting unauthenticated state');
          emit(Unauthenticated());
        }
      },
      (SessionData sessionData) {
        if (state is! Authenticated ||
            (state is Authenticated &&
                ((state as Authenticated).user != sessionData.user))) {
          log('AuthBloc: Emitting authenticated state');
          emit(
            Authenticated(
              user: sessionData.user,
            ),
          );
        }
      },
    );
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    // First check if user is fully authenticated with role
    final userResult = await _authFacade.getAuthenticatedUser();

    await userResult.fold<Future<void>>(
      (l) async {
        emit(Unauthenticated(message: l.message));
      },
      (r) async => emit(
        Authenticated(
          user: r,
        ),
      ),
    );
  }

  Future<void> _onAuthLogOutRequested(
    AuthLogOutRequestedEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authFacade.signOut();
    result.fold(
      (failure) {
        // Even if signOut fails, emit unauthenticated state
        emit(Unauthenticated(message: failure.message));
      },
      (_) => emit(Unauthenticated()),
    );
  }
}
