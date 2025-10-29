part of 'signup_bloc.dart';

@immutable
sealed class SignupEvent {}

class SignupNameChangedEvent extends SignupEvent {
  SignupNameChangedEvent(this.name);

  final String name;
}

class SignupPhoneChangedEvent extends SignupEvent {
  SignupPhoneChangedEvent(this.phone);

  final String phone;
}

class SignupPasswordChangedEvent extends SignupEvent {
  SignupPasswordChangedEvent(this.password);

  final String password;
}

class SignupConfirmPasswordChangedEvent extends SignupEvent {
  SignupConfirmPasswordChangedEvent(this.confirmPassword);

  final String confirmPassword;
}

class SignupLocationChangedEvent extends SignupEvent {
  SignupLocationChangedEvent(this.location);

  final SignupLocationInput location;
}

class SignupSubmittedEvent extends SignupEvent {}

class SignupServerValidationErrorsEvent extends SignupEvent {
  SignupServerValidationErrorsEvent(this.errors);

  final Map<String, String> errors;
}
