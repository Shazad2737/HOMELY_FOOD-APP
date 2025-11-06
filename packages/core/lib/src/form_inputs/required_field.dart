import 'package:formz/formz.dart';

/// Validation errors for the [RequiredString] [FormzInput].
enum RequiredStringValidationError {
  /// The value is empty.
  empty,
}

extension RequiredStringValidationErrorX on RequiredStringValidationError {
  String get message {
    switch (this) {
      case RequiredStringValidationError.empty:
        return 'This field is required';
    }
  }
}

/// A simple non-empty string input used for dropdowns/selections.
class RequiredString extends FormzInput<String, RequiredStringValidationError>
    with FormzInputErrorCacheMixin {
  RequiredString.pure([super.value = '']) : super.pure();

  RequiredString.dirty([super.value = '']) : super.dirty();

  @override
  RequiredStringValidationError? validator(String value) {
    if (value.trim().isEmpty) return RequiredStringValidationError.empty;
    return null;
  }
}
