part of 'otp_bloc.dart';

/// Base class for OTP events
sealed class OtpEvent {
  const OtpEvent();
}

/// Event fired when OTP input changes
final class OtpChangedEvent extends OtpEvent {
  const OtpChangedEvent(this.otp);

  final String otp;
}

/// Event fired when user submits OTP for verification
final class OtpSubmittedEvent extends OtpEvent {
  const OtpSubmittedEvent();
}

/// Event fired when user requests to resend OTP
final class ResendOtpEvent extends OtpEvent {
  const ResendOtpEvent();
}

/// Internal event for countdown timer tick
final class _OtpCountdownTickEvent extends OtpEvent {
  const _OtpCountdownTickEvent();
}
