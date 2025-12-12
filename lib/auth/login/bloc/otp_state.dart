part of 'otp_bloc.dart';

/// State for OTP verification screen
@immutable
class OtpState {
  const OtpState({
    required this.otp,
    required this.isSubmitting,
    required this.resendCountdown,
    required this.verifyOtpOption,
    required this.resendOtpMessage,
  });

  factory OtpState.initial() {
    return OtpState(
      otp: '',
      isSubmitting: false,
      resendCountdown: 0,
      verifyOtpOption: none(),
      resendOtpMessage: none(),
    );
  }

  /// Current OTP input value
  final String otp;

  /// Whether OTP verification is in progress
  final bool isSubmitting;

  /// Countdown timer for resend OTP (in seconds)
  final int resendCountdown;

  /// Result of OTP verification (success with User or failure)
  final Option<Either<Failure, User>> verifyOtpOption;

  /// Message after resending OTP
  final Option<String> resendOtpMessage;

  /// Whether user can resend OTP (countdown must be 0)
  bool get canResend => resendCountdown == 0 && !isSubmitting;

  /// Whether OTP is complete (6 digits)
  bool get isOtpComplete => otp.length == 6;

  OtpState copyWith({
    String? otp,
    bool? isSubmitting,
    int? resendCountdown,
    Option<Either<Failure, User>>? verifyOtpOption,
    Option<String>? resendOtpMessage,
  }) {
    return OtpState(
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      resendCountdown: resendCountdown ?? this.resendCountdown,
      verifyOtpOption: verifyOtpOption ?? this.verifyOtpOption,
      resendOtpMessage: resendOtpMessage ?? this.resendOtpMessage,
    );
  }

  @override
  String toString() =>
      '''
OtpState {
  otp: ${otp.isEmpty ? '(empty)' : '***'},
  isSubmitting: $isSubmitting,
  resendCountdown: $resendCountdown,
  canResend: $canResend,
  isOtpComplete: $isOtpComplete,
}
''';
}
