part of 'forgot_password_bloc.dart';

enum ForgotPasswordStep { mobileInput, otpInput, newPasswordInput }

class ForgotPasswordStateFull {
  const ForgotPasswordStateFull({
    this.mobile = '',
    this.otp = '',
    this.newPassword = '',
    this.step = ForgotPasswordStep.mobileInput,
    this.isLoading = false,
    this.submissionResult = const None(),
    this.token,
    this.expiresIn = 300,
  });

  final String mobile;
  final String otp;
  final String newPassword;
  final ForgotPasswordStep step;
  final bool isLoading;
  final Option<Either<Failure, String>> submissionResult;
  final String? token;
  final int expiresIn;

  ForgotPasswordStateFull copyWith({
    String? mobile,
    String? otp,
    String? newPassword,
    ForgotPasswordStep? step,
    bool? isLoading,
    Option<Either<Failure, String>>? submissionResult,
    String? token,
    int? expiresIn,
  }) {
    return ForgotPasswordStateFull(
      mobile: mobile ?? this.mobile,
      otp: otp ?? this.otp,
      newPassword: newPassword ?? this.newPassword,
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      submissionResult: submissionResult ?? this.submissionResult,
      token: token ?? this.token,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }
}
