import 'package:flutter/foundation.dart';

/// Details of a validation failure.
///
/// Represents a single validation error from the API.
@immutable
class ValidationFailureDetail {
  /// [ValidationFailureDetail] constructor.
  const ValidationFailureDetail({
    required this.field,
    required this.message,
    required this.type,
  });

  /// Creates a [ValidationFailureDetail] from JSON.
  ///
  /// Supports the API error format:
  /// ```json
  /// {
  ///   "field": "mobile",
  ///   "message": "Invalid mobile number format",
  ///   "type": "string.pattern.base"
  /// }
  /// ```
  factory ValidationFailureDetail.fromJson(Map<String, dynamic> json) {
    return ValidationFailureDetail(
      field: json['field'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
    );
  }

  /// The field name that failed validation.
  ///
  /// Examples: "mobile", "password", "locations.0.name"
  final String field;

  /// The validation error message.
  ///
  /// Example: "Invalid mobile number format"
  final String message;

  /// The validation error type/code.
  ///
  /// Example: "string.pattern.base", "string.min", "any.only"
  final String type;

  @override
  String toString() =>
      'ValidationFailureDetail(field: $field, message: $message, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidationFailureDetail &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          message == other.message &&
          type == other.type;

  @override
  int get hashCode => field.hashCode ^ message.hashCode ^ type.hashCode;
}
