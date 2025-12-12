import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart'; // For IAuthFacade, Failure

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordStateFull> {
  ForgotPasswordBloc(this._authFacade)
    : super(const ForgotPasswordStateFull()) {
    on<ForgotPasswordMobileChanged>(_onMobileChanged);
    on<ForgotPasswordOtpChanged>(_onOtpChanged);
    on<ForgotPasswordNewPasswordChanged>(_onNewPasswordChanged);
    on<ForgotPasswordRequestOtpSubmitted>(_onRequestOtpSubmitted);
    on<ForgotPasswordVerifyOtpSubmitted>(_onVerifyOtpSubmitted);
    on<ForgotPasswordResetSubmitted>(_onResetSubmitted);
    on<ForgotPasswordResendOtpRequested>(_onResendOtpRequested);
  }

  final IAuthFacade _authFacade;

  void _onMobileChanged(
    ForgotPasswordMobileChanged event,
    Emitter<ForgotPasswordStateFull> emit,
  ) {
    emit(state.copyWith(mobile: event.mobile, submissionResult: const None()));
  }

  void _onOtpChanged(
    ForgotPasswordOtpChanged event,
    Emitter<ForgotPasswordStateFull> emit,
  ) {
    emit(state.copyWith(otp: event.otp, submissionResult: const None()));
  }

  void _onNewPasswordChanged(
    ForgotPasswordNewPasswordChanged event,
    Emitter<ForgotPasswordStateFull> emit,
  ) {
    emit(
      state.copyWith(
        newPassword: event.password,
        submissionResult: const None(),
      ),
    );
  }

  Future<void> _onRequestOtpSubmitted(
    ForgotPasswordRequestOtpSubmitted event,
    Emitter<ForgotPasswordStateFull> emit,
  ) async {
    if (state.mobile.isEmpty) return;

    emit(state.copyWith(isLoading: true, submissionResult: const None()));

    final result = await _authFacade.forgotPassword(mobile: state.mobile);

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            submissionResult: Some(left(failure)),
          ),
        );
      },
      (success) {
        emit(
          state.copyWith(
            isLoading: false,
            step: ForgotPasswordStep.otpInput,
            submissionResult: Some(right('OTP sent successfully')),
          ),
        );
      },
    );
  }

  Future<void> _onVerifyOtpSubmitted(
    ForgotPasswordVerifyOtpSubmitted event,
    Emitter<ForgotPasswordStateFull> emit,
  ) async {
    if (state.otp.isEmpty) return;

    emit(state.copyWith(isLoading: true, submissionResult: const None()));

    final result = await _authFacade.verifyResetOtp(
      mobile: state.mobile,
      otp: state.otp,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isLoading: false,
            submissionResult: Some(left(failure)),
          ),
        );
      },
      (token) {
        emit(
          state.copyWith(
            isLoading: false,
            token: token,
            step: ForgotPasswordStep.newPasswordInput,
            submissionResult: const None(),
          ),
        );
      },
    );
  }

  Future<void> _onResetSubmitted(
    ForgotPasswordResetSubmitted event,
    Emitter<ForgotPasswordStateFull> emit,
  ) async {
    if (state.token == null) return;

    emit(state.copyWith(isLoading: true, submissionResult: const None()));

    final result = await _authFacade.resetPassword(
      token: state.token!,
      newPassword: state.newPassword,
    );

    emit(
      state.copyWith(
        isLoading: false,
        submissionResult: some(result),
      ),
    );
  }

  Future<void> _onResendOtpRequested(
    ForgotPasswordResendOtpRequested event,
    Emitter<ForgotPasswordStateFull> emit,
  ) async {
    emit(state.copyWith(isLoading: true, submissionResult: const None()));

    final result = await _authFacade.resendOtp(
      mobile: state.mobile,
      type: 'resetPassword',
    );

    emit(
      state.copyWith(
        isLoading: false,
        submissionResult: some(result),
      ),
    );
  }
}
