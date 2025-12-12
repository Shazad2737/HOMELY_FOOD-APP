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
        case LoginMobileChangedEvent():
          _onMobileChangedEvent(event, emit);
        case LoginPasswordChangedEvent():
          _onPasswordChangedEvent(event, emit);
        case _:
          break;
      }
    });
    on<LoginSubmittedEvent>(_onSubmitEvent);
  }

  void _onMobileChangedEvent(
    LoginMobileChangedEvent event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(mobile: event.mobile));
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
      mobile: state.mobile.trim(),
      password: state.password,
    );
    emit(
      state.copyWith(
        isSubmitting: false,
        loginFailureOrSuccessOption: optionOf(result),
        // mobile: '',
        password: result.isRight() ? '' : state.password,
      ),
    );
  }
}
