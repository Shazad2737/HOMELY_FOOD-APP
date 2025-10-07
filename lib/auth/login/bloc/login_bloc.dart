// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(
    this.authFacade,
  ) : super(LoginState.initial()) {
    on<LoginEvent>((event, emit) async {
      switch (event) {
        case LoginUserNameChangedEvent():
          _onUserNameChangedEvent(event, emit);
        case LoginPasswordChangedEvent():
          _onPasswordChangedEvent(event, emit);
        case LoginSubmittedEvent():
          await _onSubmitEvent(event, emit);
      }
    });
  }

  void _onUserNameChangedEvent(
    LoginUserNameChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(username: event.username));
  }

  void _onPasswordChangedEvent(
    LoginPasswordChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password));
  }

  final IAuthFacade authFacade;

  Future<void> _onSubmitEvent(
    LoginSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(isSubmitting: true, loginFailureOrSuccessOption: none()),
    );
    final result = await authFacade.signIn(
      username: state.username.trim(),
      password: state.password,
    );
    emit(
      state.copyWith(
        isSubmitting: false,
        loginFailureOrSuccessOption: optionOf(result),
        // username: '',
        password: result.isRight() ? '' : state.password,
      ),
    );
  }
}
