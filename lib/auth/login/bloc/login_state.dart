part of 'login_bloc.dart';

@immutable
class LoginState {
  const LoginState({
    required this.username,
    required this.password,
    required this.isSubmitting,
    required this.showErrorMessages,
    required this.loginFailureOrSuccessOption,
  });

  factory LoginState.initial() {
    return LoginState(
      username: '',
      password: '',
      isSubmitting: false,
      showErrorMessages: false,
      loginFailureOrSuccessOption: none(),
    );
  }

  final String username;
  final bool isSubmitting;
  final String password;

  final bool showErrorMessages;

  final Option<Either<Failure, User>> loginFailureOrSuccessOption;

  LoginState copyWith({
    String? username,
    String? password,
    bool? isSubmitting,
    bool? showErrorMessages,
    Option<Either<Failure, User>>? loginFailureOrSuccessOption,
  }) {
    return LoginState(
      username: username ?? this.username,
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
username: $username,
password: $password,
isSubmitting: $isSubmitting,
showErrorMessages: $showErrorMessages,
loginFailureOrSuccessOption: $loginFailureOrSuccessOption
}
''';
}
