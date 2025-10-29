import 'package:formz/formz.dart';

/// Validation errors for the [Phone] [FormzInput].
enum PhoneValidationError {
  /// The phone number is empty.
  empty,

  /// The phone number format is invalid.
  invalid,
}

/// Extension to provide user-friendly error messages.
extension PhoneValidationErrorX on PhoneValidationError {
  String get message {
    switch (this) {
      case PhoneValidationError.empty:
        return 'Phone number is required';
      case PhoneValidationError.invalid:
        return 'Please enter a valid UAE phone number (e.g., 0501234567)';
    }
  }
}

/// Form input for a UAE phone number field.
class Phone extends FormzInput<String, PhoneValidationError>
    with FormzInputErrorCacheMixin {
  /// Constructor for an unmodified (pure) phone input.
  Phone.pure([super.value = '']) : super.pure();

  /// Constructor for a modified (dirty) phone input.
  Phone.dirty([super.value = '']) : super.dirty();

  /// UAE phone number patterns:
  /// - 05X XXXXXXX (9 digits starting with 05)
  /// - +971 5X XXXXXXX
  /// - 00971 5X XXXXXXX
  static final _uaePhoneRegex = RegExp(
    r'^(\+971|00971|0)?5[0-9]{8}$',
  );

  @override
  PhoneValidationError? validator(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'\s+'), '');

    if (cleanedValue.isEmpty) {
      return PhoneValidationError.empty;
    } else if (!_uaePhoneRegex.hasMatch(cleanedValue)) {
      return PhoneValidationError.invalid;
    }
    return null;
  }
}
