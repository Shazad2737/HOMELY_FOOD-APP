import 'package:formz/formz.dart';

/// Validation errors for the [Password] [FormzInput].
enum PasswordValidationError {
  /// The password is empty.
  empty,

  /// The password is too short.
  tooShort,

  /// The password is too weak (optional: add complexity rules).
  weak,
}

/// Extension to provide user-friendly error messages.
extension PasswordValidationErrorX on PasswordValidationError {
  String get message {
    switch (this) {
      case PasswordValidationError.empty:
        return 'Password is required';
      case PasswordValidationError.tooShort:
        return 'Password must be at least 6 characters';
      case PasswordValidationError.weak:
        return 'Password must contain letters and numbers';
    }
  }
}

/// Form input for a password field.
class Password extends FormzInput<String, PasswordValidationError>
    with FormzInputErrorCacheMixin {
  /// Constructor for an unmodified (pure) password input.
  Password.pure([super.value = '']) : super.pure();

  /// Constructor for a modified (dirty) password input.
  Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) {
      return PasswordValidationError.empty;
    } else if (value.length < 6) {
      return PasswordValidationError.tooShort;
    }
    // Optional: Add complexity requirements
    // else if (!_hasLettersAndNumbers(value)) {
    //   return PasswordValidationError.weak;
    // }
    return null;
  }

  // Optional: Add complexity check
  // static bool _hasLettersAndNumbers(String value) {
  //   return value.contains(RegExp(r'[a-zA-Z]')) &&
  //          value.contains(RegExp(r'[0-9]'));
  // }
}
