part of 'login_bloc.dart';

@immutable
class LoginState {
  const LoginState({
    required this.mobile,
    required this.password,
    required this.isSubmitting,
    required this.showErrorMessages,
    required this.loginFailureOrSuccessOption,
  });

  factory LoginState.initial() {
    return LoginState(
      mobile: '',
      password: '',
      isSubmitting: false,
      showErrorMessages: false,
      loginFailureOrSuccessOption: none(),
    );
  }

  final String mobile;
  final bool isSubmitting;
  final String password;

  final bool showErrorMessages;

  final Option<Either<Failure, User>> loginFailureOrSuccessOption;

  LoginState copyWith({
    String? mobile,
    String? password,
    bool? isSubmitting,
    bool? showErrorMessages,
    Option<Either<Failure, User>>? loginFailureOrSuccessOption,
  }) {
    return LoginState(
      mobile: mobile ?? this.mobile,
      password: password ?? this.password,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      showErrorMessages: showErrorMessages ?? this.showErrorMessages,
      loginFailureOrSuccessOption:
          loginFailureOrSuccessOption ?? this.loginFailureOrSuccessOption,
    );
  }

  @override
  String toString() =>
      '''
LoginState {
mobile: $mobile,
password: $password,
isSubmitting: $isSubmitting,
showErrorMessages: $showErrorMessages,
loginFailureOrSuccessOption: $loginFailureOrSuccessOption
}
''';
}
