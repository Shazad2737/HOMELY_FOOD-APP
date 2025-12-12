part of 'forgot_password_bloc.dart';

sealed class ForgotPasswordEvent {}

class ForgotPasswordMobileChanged extends ForgotPasswordEvent {
  final String mobile;
  ForgotPasswordMobileChanged(this.mobile);
}

class ForgotPasswordOtpChanged extends ForgotPasswordEvent {
  final String otp;
  ForgotPasswordOtpChanged(this.otp);
}

class ForgotPasswordNewPasswordChanged extends ForgotPasswordEvent {
  final String password;
  ForgotPasswordNewPasswordChanged(this.password);
}

class ForgotPasswordRequestOtpSubmitted extends ForgotPasswordEvent {}

class ForgotPasswordVerifyOtpSubmitted extends ForgotPasswordEvent {}

class ForgotPasswordResetSubmitted extends ForgotPasswordEvent {}

class ForgotPasswordResendOtpRequested extends ForgotPasswordEvent {}
