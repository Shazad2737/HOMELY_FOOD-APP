// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:core/form_inputs.dart';
import 'package:flutter/foundation.dart';
import 'package:formz/formz.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignupBloc extends Bloc<SignupEvent, SignupState> {
  SignupBloc({
    required IAuthFacade authFacade,
  })  : _authFacade = authFacade,
        super(SignupState.initial()) {
    on<SignupEvent>((event, emit) async {
      switch (event) {
        case SignupNameChangedEvent():
          _onNameChangedEvent(event, emit);
        case SignupPhoneChangedEvent():
          _onPhoneChangedEvent(event, emit);
        case SignupPasswordChangedEvent():
          _onPasswordChangedEvent(event, emit);
        case SignupConfirmPasswordChangedEvent():
          _onConfirmPasswordChangedEvent(event, emit);
        case SignupLocationChangedEvent():
          emit(state.copyWith(location: event.location));
        case SignupSubmittedEvent():
          await _onSubmitEvent(event, emit);
        case SignupServerValidationErrorsEvent():
          _onServerValidationErrorsEvent(event, emit);
      }
    });
  }

  final IAuthFacade _authFacade;

  void _onNameChangedEvent(
    SignupNameChangedEvent event,
    Emitter<SignupState> emit,
  ) {
    final name = Name.dirty(event.name);
    emit(state.copyWith(name: name, signupState: DataState.initial()));
  }

  void _onPhoneChangedEvent(
    SignupPhoneChangedEvent event,
    Emitter<SignupState> emit,
  ) {
    final phone = Phone.dirty(event.phone);
    emit(state.copyWith(phone: phone, signupState: DataState.initial()));
  }

  void _onPasswordChangedEvent(
    SignupPasswordChangedEvent event,
    Emitter<SignupState> emit,
  ) {
    final password = Password.dirty(event.password);
    final confirmPassword = ConfirmedPassword.dirty(
      password: event.password,
      value: state.confirmPassword.value,
    );
    emit(
      state.copyWith(
        password: password,
        confirmPassword: confirmPassword,
        signupState: DataState.initial(),
      ),
    );
  }

  void _onConfirmPasswordChangedEvent(
    SignupConfirmPasswordChangedEvent event,
    Emitter<SignupState> emit,
  ) {
    final confirmPassword = ConfirmedPassword.dirty(
      password: state.password.value,
      value: event.confirmPassword,
    );
    emit(
      state.copyWith(
        confirmPassword: confirmPassword,
        signupState: DataState.initial(),
      ),
    );
  }

  Future<void> _onSubmitEvent(
    SignupSubmittedEvent event,
    Emitter<SignupState> emit,
  ) async {
    // Mark all fields as "dirty" to show validation errors
    emit(
      state.copyWith(
        signupState: DataState.initial(),
        name: Name.dirty(state.name.value),
        phone: Phone.dirty(state.phone.value),
        password: Password.dirty(state.password.value),
        confirmPassword: ConfirmedPassword.dirty(
          password: state.password.value,
          value: state.confirmPassword.value,
        ),
        showErrorMessages: true,
      ),
    );

    // Check if form is valid using FormzMixin
    if (!state.isValid) {
      emit(
        state.copyWith(
          signupState: DataState.failure(
            const UnknownFailure(
              message: 'Please fix the errors above',
            ),
          ),
        ),
      );
      return;
    }

    // Form is valid, call signup API without address
    emit(state.copyWith(signupState: DataState.loading()));

    final result = await _authFacade.signUp(
      name: state.name.value,
      mobile: state.phone.value,
      password: state.password.value,
      confirmPassword: state.confirmPassword.value,
      // No locations - users can add address later
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            signupState: DataState.failure(failure),
          ),
        );
      },
      (signupResponse) {
        emit(
          state.copyWith(
            signupState: DataState.success(signupResponse),
          ),
        );
      },
    );
  }

  /// Handler for server-side validation errors
  /// Called when backend returns validation errors
  void _onServerValidationErrorsEvent(
    SignupServerValidationErrorsEvent event,
    Emitter<SignupState> emit,
  ) {
    emit(
      state.copyWith(
        name: event.errors.containsKey('name')
            ? Name.dirty(state.name.value)
            : state.name,
        phone: event.errors.containsKey('mobile')
            ? Phone.dirty(state.phone.value)
            : state.phone,
        password: event.errors.containsKey('password')
            ? Password.dirty(state.password.value)
            : state.password,
        confirmPassword: event.errors.containsKey('confirmPassword')
            ? ConfirmedPassword.dirty(
                password: state.password.value,
                value: state.confirmPassword.value,
              )
            : state.confirmPassword,
        showErrorMessages: true,
      ),
    );
  }
}
