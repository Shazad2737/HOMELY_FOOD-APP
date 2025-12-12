import 'package:api_client/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiValidationFailure', () {
    test('parses new errors array format correctly', () {
      final json = {
        'success': false,
        'message': 'Validation error in body',
        'errors': [
          {
            'field': 'mobile',
            'message': 'Invalid mobile number format',
            'type': 'string.pattern.base',
          },
          {
            'field': 'password',
            'message': 'Password must be at least 6 characters long',
            'type': 'string.min',
          },
          {
            'field': 'locations.0.name',
            'message': 'Location name is required',
            'type': 'string.empty',
          },
        ],
      };

      final failure = ApiValidationFailure.fromJson(json);

      expect(failure.message, 'Validation error in body');
      expect(failure.errors.length, 3);
      expect(failure.hasErrors, true);

      expect(failure.errors[0].field, 'mobile');
      expect(failure.errors[0].message, 'Invalid mobile number format');
      expect(failure.errors[0].type, 'string.pattern.base');

      expect(failure.errors[1].field, 'password');
      expect(failure.errors[2].field, 'locations.0.name');

      expect(
        failure.getErrorForField('mobile'),
        'Invalid mobile number format',
      );
      expect(failure.getErrorForField('unknown'), null);
    });

    test('handles simple error string format', () {
      final json = {
        'error': 'Something went wrong',
      };

      final failure = ApiValidationFailure.fromJson(json);

      expect(failure.message, 'Something went wrong');
      expect(failure.errors, isEmpty);
      expect(failure.hasErrors, false);
    });

    test('handles missing errors gracefully', () {
      final json = {
        'message': 'Validation failed',
      };

      final failure = ApiValidationFailure.fromJson(json);

      expect(failure.message, 'Validation failed');
      expect(failure.errors, isEmpty);
    });
  });

  group('ValidationFailureDetail', () {
    test('parses from JSON correctly', () {
      final json = {
        'field': 'mobile',
        'message': 'Invalid format',
        'type': 'string.pattern.base',
      };

      final detail = ValidationFailureDetail.fromJson(json);

      expect(detail.field, 'mobile');
      expect(detail.message, 'Invalid format');
      expect(detail.type, 'string.pattern.base');
    });

    test('equality works correctly', () {
      final detail1 = ValidationFailureDetail.fromJson(const {
        'field': 'mobile',
        'message': 'Invalid',
        'type': 'pattern',
      });

      final detail2 = ValidationFailureDetail.fromJson(const {
        'field': 'mobile',
        'message': 'Invalid',
        'type': 'pattern',
      });

      final detail3 = ValidationFailureDetail.fromJson(const {
        'field': 'name',
        'message': 'Required',
        'type': 'empty',
      });

      expect(detail1, equals(detail2));
      expect(detail1, isNot(equals(detail3)));
    });
  });
}
