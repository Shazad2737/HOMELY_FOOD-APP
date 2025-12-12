import 'package:api_client/api_client.dart';
import 'package:instamess_app/auth/models/validation_error_groups.dart';

/// Classifier for authentication-related validation errors.
///
/// This class contains domain knowledge about which fields belong to
/// signup vs delivery address, and groups errors accordingly.
class AuthErrorClassifier {
  /// Fields that belong to the signup form.
  static const Set<String> signupFields = {
    'name',
    'mobile',
    'password',
    'confirmPassword',
  };

  /// Prefixes that indicate delivery address fields.
  static const Set<String> deliveryFieldPrefixes = {
    'locations.',
    'locationId',
    'areaId',
  };

  /// Groups validation errors by domain concern (signup vs delivery).
  ///
  /// Takes a list of [ValidationFailureDetail] from an API response
  /// and categorizes them into signup errors and delivery address errors.
  ///
  /// Example:
  /// ```dart
  /// final groups = AuthErrorClassifier.groupAuthErrors(failure.errors);
  /// if (groups.hasSignupErrors) {
  ///   // Show dialog and navigate back to signup
  /// } else {
  ///   // Show inline errors on current screen
  /// }
  /// ```
  static ValidationErrorGroups groupAuthErrors(
    List<ValidationFailureDetail> errors,
  ) {
    final signupErrors = <String, String>{};
    final deliveryErrors = <String, String>{};

    for (final error in errors) {
      final field = error.field;
      final message = error.message;

      if (_isSignupField(field)) {
        signupErrors[field] = message;
      } else if (_isDeliveryField(field)) {
        // Clean the field name (remove 'locations.0.' prefix)
        final cleanField = _cleanFieldName(field);
        deliveryErrors[cleanField] = message;
      } else {
        // Unknown field - default to delivery errors
        deliveryErrors[field] = message;
      }
    }

    return ValidationErrorGroups(
      signupErrors: signupErrors,
      deliveryErrors: deliveryErrors,
    );
  }

  /// Checks if a field belongs to the signup form.
  static bool _isSignupField(String field) {
    return signupFields.contains(field);
  }

  /// Checks if a field belongs to the delivery address form.
  static bool _isDeliveryField(String field) {
    // Check for exact matches
    if (field == 'locationId' || field == 'areaId') {
      return true;
    }

    // Check for prefixes (e.g., 'locations.0.name')
    return deliveryFieldPrefixes.any((prefix) => field.startsWith(prefix));
  }

  /// Cleans field names by removing array index prefixes.
  ///
  /// Example: 'locations.0.name' -> 'name'
  static String _cleanFieldName(String field) {
    // Remove 'locations.0.' prefix if present
    if (field.startsWith('locations.')) {
      final parts = field.split('.');
      if (parts.length >= 3) {
        return parts.sublist(2).join('.');
      }
    }
    return field;
  }

  /// Gets a user-friendly field label for display.
  ///
  /// Converts technical field names to readable labels.
  static String getUserFriendlyLabel(String field) {
    const fieldLabels = {
      'name': 'Name',
      'mobile': 'Phone Number',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'locationId': 'Location',
      'areaId': 'Area',
      'roomNumber': 'Room Number',
      'buildingName': 'Building Name',
      'zipCode': 'Zip Code',
      'type': 'Delivery Type',
    };

    return fieldLabels[field] ?? field;
  }

  /// Formats a field error into a user-friendly message.
  ///
  /// Example: ('mobile', 'Invalid format') -> 'Phone Number: Invalid format'
  static String formatError(String field, String message) {
    final label = getUserFriendlyLabel(field);
    return '$label: $message';
  }
}
