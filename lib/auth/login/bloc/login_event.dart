part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginMobileChangedEvent extends LoginEvent {
  LoginMobileChangedEvent(this.mobile);

  final String mobile;
}

class LoginPasswordChangedEvent extends LoginEvent {
  LoginPasswordChangedEvent(this.password);

  final String password;
}

class LoginSubmittedEvent extends LoginEvent {}
