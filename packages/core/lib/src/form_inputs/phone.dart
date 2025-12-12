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
        return 'Please enter a valid phone number';
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

  /// Phone number validation pattern:
  /// - International format: +[country code][number]
  /// - For UAE specifically: +971 followed by 9 digits
  /// - Generic international: 10-15 digits total after +
  static final _internationalPhoneRegex = RegExp(
    r'^\+[1-9]\d{9,14}$',
  );

  @override
  PhoneValidationError? validator(String value) {
    final cleanedValue = value.replaceAll(RegExp(r'\s+'), '');

    if (cleanedValue.isEmpty) {
      return PhoneValidationError.empty;
    } else if (!_internationalPhoneRegex.hasMatch(cleanedValue)) {
      return PhoneValidationError.invalid;
    }
    return null;
  }
}
