import 'package:core/form_inputs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Name', () {
    group('pure', () {
      test('is invalid when empty', () {
        expect(Name.pure().isValid, false);
      });
    });

    group('dirty', () {
      test('is invalid when empty', () {
        expect(Name.dirty().isValid, false);
        expect(
          Name.dirty().error,
          NameValidationError.empty,
        );
      });

      test('is invalid when too short', () {
        expect(Name.dirty('a').isValid, false);
        expect(
          Name.dirty('a').error,
          NameValidationError.tooShort,
        );
      });

      test('is invalid with special characters', () {
        expect(Name.dirty('John123').isValid, false);
        expect(
          Name.dirty('John123').error,
          NameValidationError.invalid,
        );
      });

      test('is valid with correct name', () {
        expect(Name.dirty('John Doe').isValid, true);
        expect(Name.dirty('John Doe').error, null);
      });
    });
  });

  group('Phone', () {
    group('pure', () {
      test('is invalid when empty', () {
        expect(Phone.pure().isValid, false);
      });
    });

    group('dirty', () {
      test('is invalid when empty', () {
        expect(Phone.dirty().isValid, false);
        expect(
          Phone.dirty().error,
          PhoneValidationError.empty,
        );
      });

      test('is invalid with incorrect format', () {
        expect(Phone.dirty('1234').isValid, false);
        expect(
          Phone.dirty('1234').error,
          PhoneValidationError.invalid,
        );
      });

      test('is valid with UAE phone format (05X)', () {
        expect(Phone.dirty('0501234567').isValid, true);
      });

      test('is valid with +971 prefix', () {
        expect(Phone.dirty('+971501234567').isValid, true);
      });

      test('is valid with 00971 prefix', () {
        expect(Phone.dirty('00971501234567').isValid, true);
      });
    });
  });

  group('Password', () {
    group('pure', () {
      test('is invalid when empty', () {
        expect(Password.pure().isValid, false);
      });
    });

    group('dirty', () {
      test('is invalid when empty', () {
        expect(Password.dirty().isValid, false);
        expect(
          Password.dirty().error,
          PasswordValidationError.empty,
        );
      });

      test('is invalid when too short', () {
        expect(Password.dirty('12345').isValid, false);
        expect(
          Password.dirty('12345').error,
          PasswordValidationError.tooShort,
        );
      });

      test('is valid with 6 or more characters', () {
        expect(Password.dirty('123456').isValid, true);
        expect(Password.dirty('mySecurePass').isValid, true);
      });
    });
  });

  group('ConfirmedPassword', () {
    group('pure', () {
      test('is invalid when empty', () {
        expect(const ConfirmedPassword.pure().isValid, false);
      });
    });

    group('dirty', () {
      test('is invalid when empty', () {
        expect(
          const ConfirmedPassword.dirty(password: 'password123').isValid,
          false,
        );
        expect(
          const ConfirmedPassword.dirty(password: 'password123').error,
          ConfirmedPasswordValidationError.empty,
        );
      });

      test('is invalid when passwords do not match', () {
        expect(
          const ConfirmedPassword.dirty(
            password: 'password123',
            value: 'different',
          ).isValid,
          false,
        );
        expect(
          const ConfirmedPassword.dirty(
            password: 'password123',
            value: 'different',
          ).error,
          ConfirmedPasswordValidationError.mismatch,
        );
      });

      test('is valid when passwords match', () {
        expect(
          const ConfirmedPassword.dirty(
            password: 'password123',
            value: 'password123',
          ).isValid,
          true,
        );
      });
    });
  });
}
