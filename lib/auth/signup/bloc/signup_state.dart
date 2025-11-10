part of 'signup_bloc.dart';

@immutable
class SignupState with FormzMixin {
  SignupState({
    required this.signupState,
    Name? name,
    Phone? phone,
    Password? password,
    ConfirmedPassword? confirmPassword,
    this.showErrorMessages = false,
    this.location,
  }) : name = name ?? Name.pure(),
       phone = phone ?? Phone.pure(),
       password = password ?? Password.pure(),
       confirmPassword = confirmPassword ?? const ConfirmedPassword.pure();

  factory SignupState.initial() {
    return SignupState(
      signupState: DataState.initial(),
    );
  }

  final Name name;
  final Phone phone;
  final Password password;
  final ConfirmedPassword confirmPassword;

  final SignupLocationInput? location;

  final bool showErrorMessages;
  final DataState<SignupResponse> signupState;

  bool get isSubmitting => signupState.isLoading;

  /// FormzMixin automatically provides `isValid` by checking all inputs
  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    name,
    phone,
    password,
    confirmPassword,
  ];

  SignupState copyWith({
    Name? name,
    Phone? phone,
    Password? password,
    ConfirmedPassword? confirmPassword,
    bool? showErrorMessages,
    DataState<SignupResponse>? signupState,
    SignupLocationInput? location,
  }) {
    return SignupState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      showErrorMessages: showErrorMessages ?? this.showErrorMessages,
      signupState: signupState ?? this.signupState,
      location: location,
    );
  }

  @override
  String toString() =>
      '''
SignupState {
name: ${name.value},
phone: ${phone.value},
password: ${password.value},
confirmPassword: ${confirmPassword.value},
showErrorMessages: $showErrorMessages,
isValid: $isValid,
signupState: $signupState
}
''';
}
