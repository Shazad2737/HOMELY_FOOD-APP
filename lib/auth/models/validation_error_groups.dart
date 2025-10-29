/// Groups validation errors by domain concern.
///
/// Used to separate signup-related errors from delivery address errors
/// so the UI can decide how to display them appropriately.
class ValidationErrorGroups {
  /// Creates a [ValidationErrorGroups] with the given error maps.
  const ValidationErrorGroups({
    this.signupErrors = const {},
    this.deliveryErrors = const {},
  });

  /// Validation errors related to signup fields (name, mobile, password).
  ///
  /// Map of field name to error message.
  /// Example: {'mobile': 'Invalid mobile number format'}
  final Map<String, String> signupErrors;

  /// Validation errors related to delivery address fields.
  ///
  /// Map of field name to error message.
  /// Example: {'locationId': 'Location is required'}
  final Map<String, String> deliveryErrors;

  /// Returns true if there are any signup validation errors.
  bool get hasSignupErrors => signupErrors.isNotEmpty;

  /// Returns true if there are any delivery address validation errors.
  bool get hasDeliveryErrors => deliveryErrors.isNotEmpty;

  /// Returns true if there are any validation errors at all.
  bool get hasAnyErrors => hasSignupErrors || hasDeliveryErrors;

  /// Returns the total number of errors across both groups.
  int get totalErrorCount => signupErrors.length + deliveryErrors.length;

  @override
  String toString() {
    return 'ValidationErrorGroups('
        'signupErrors: $signupErrors, '
        'deliveryErrors: $deliveryErrors'
        ')';
  }
}
