import 'package:formz/formz.dart';

/// Validation errors for the [Name] [FormzInput].
enum NameValidationError {
  /// The name is empty.
  empty,

  /// The name is too short.
  tooShort,

  /// The name contains invalid characters.
  invalid,
}

/// Extension to provide user-friendly error messages.
extension NameValidationErrorX on NameValidationError {
  String get message {
    switch (this) {
      case NameValidationError.empty:
        return 'Name is required';
      case NameValidationError.tooShort:
        return 'Name must be at least 2 characters';
      case NameValidationError.invalid:
        return 'Name can only contain letters and spaces';
    }
  }
}

/// Form input for a name field.
class Name extends FormzInput<String, NameValidationError>
    with FormzInputErrorCacheMixin {
  /// Constructor for an unmodified (pure) name input.
  Name.pure([super.value = '']) : super.pure();

  /// Constructor for a modified (dirty) name input.
  Name.dirty([super.value = '']) : super.dirty();

  static final _nameRegex = RegExp(r'^[a-zA-Z\s]+$');

  @override
  NameValidationError? validator(String value) {
    if (value.isEmpty) {
      return NameValidationError.empty;
    } else if (value.trim().length < 2) {
      return NameValidationError.tooShort;
    } else if (!_nameRegex.hasMatch(value)) {
      return NameValidationError.invalid;
    }
    return null;
  }
}
