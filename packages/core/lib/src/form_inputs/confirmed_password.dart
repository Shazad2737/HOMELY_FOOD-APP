import 'package:formz/formz.dart';

/// Validation errors for the [ConfirmedPassword] [FormzInput].
enum ConfirmedPasswordValidationError {
  /// The confirmed password is empty.
  empty,

  /// The confirmed password does not match the original password.
  mismatch,
}

/// Extension to provide user-friendly error messages.
extension ConfirmedPasswordValidationErrorX
    on ConfirmedPasswordValidationError {
  String get message {
    switch (this) {
      case ConfirmedPasswordValidationError.empty:
        return 'Please confirm your password';
      case ConfirmedPasswordValidationError.mismatch:
        return 'Passwords do not match';
    }
  }
}

/// Form input for a confirmed password field.
///
/// This input validates that the confirmed password matches the original
/// password. The original password is passed as a parameter to the validator.
class ConfirmedPassword
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  /// Constructor for an unmodified (pure) confirmed password input.
  const ConfirmedPassword.pure({
    this.password = '',
    String value = '',
  }) : super.pure(value);

  /// Constructor for a modified (dirty) confirmed password input.
  const ConfirmedPassword.dirty({
    required this.password,
    String value = '',
  }) : super.dirty(value);

  /// The original password to match against.
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return ConfirmedPasswordValidationError.empty;
    } else if (value != password) {
      return ConfirmedPasswordValidationError.mismatch;
    }
    return null;
  }
}
