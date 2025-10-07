part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

class LoginUserNameChangedEvent extends LoginEvent {
  LoginUserNameChangedEvent(this.username);

  final String username;
}

class LoginPasswordChangedEvent extends LoginEvent {
  LoginPasswordChangedEvent(this.password);

  final String password;
}

class LoginSubmittedEvent extends LoginEvent {}
