import 'dart:async';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/homely_api.dart';

part 'otp_event.dart';
part 'otp_state.dart';

/// Bloc for managing OTP verification flow
class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({
    required this.authFacade,
    required this.mobile,
    this.otpType = 'signup',
  }) : super(OtpState.initial()) {
    on<OtpChangedEvent>(_onOtpChanged);
    on<OtpSubmittedEvent>(_onOtpSubmitted);
    on<ResendOtpEvent>(_onResendOtp);
    on<_OtpCountdownTickEvent>(_onCountdownTick);
  }

  final IAuthFacade authFacade;
  final String mobile;
  final String otpType;

  Timer? _countdownTimer;

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }

  void _onOtpChanged(OtpChangedEvent event, Emitter<OtpState> emit) {
    emit(state.copyWith(otp: event.otp));
  }

  Future<void> _onOtpSubmitted(
    OtpSubmittedEvent event,
    Emitter<OtpState> emit,
  ) async {
    if (state.otp.length != 6) {
      emit(
        state.copyWith(
          verifyOtpOption: optionOf(
            left(
              const UnknownFailure(
                message: 'Please enter a valid 6-digit OTP',
              ),
            ),
          ),
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, verifyOtpOption: none()));

    final result = await authFacade.verifyOtp(
      mobile: mobile,
      otp: state.otp,
      type: otpType,
    );

    emit(
      state.copyWith(
        isSubmitting: false,
        verifyOtpOption: optionOf(result),
      ),
    );
  }

  Future<void> _onResendOtp(
    ResendOtpEvent event,
    Emitter<OtpState> emit,
  ) async {
    if (!state.canResend) return;

    emit(
      state.copyWith(
        resendCountdown: 60,
        resendOtpMessage: none(),
      ),
    );

    // Start countdown timer
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const _OtpCountdownTickEvent()),
    );

    final result = await authFacade.resendOtp(
      mobile: mobile,
      type: otpType,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            resendOtpMessage: optionOf(failure.message),
          ),
        );
      },
      (String message) {
        emit(
          state.copyWith(
            resendOtpMessage: optionOf(message),
          ),
        );
      },
    );
  }

  void _onCountdownTick(
    _OtpCountdownTickEvent event,
    Emitter<OtpState> emit,
  ) {
    if (state.resendCountdown > 0) {
      emit(state.copyWith(resendCountdown: state.resendCountdown - 1));
    } else {
      _countdownTimer?.cancel();
    }
  }
}
