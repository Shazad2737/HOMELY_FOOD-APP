/// Details of a validation failure.
class ValidationFailureDetail {
  /// [ValidationFailureDetail] constructor.
  ValidationFailureDetail(this.message, this.path, this.type, this.context);

  /// Creates a [ValidationFailureDetail] from JSON.
  ValidationFailureDetail.fromJson(Map<String, dynamic> json)
      : message = json['message'] as String,
        path = json['path'] is String
            ? [json['path'] as String]
            : (json['path'] as List).map((e) => e as String).toList(),
        type = json['type'] as String,
        context = ValidationFailureDetailContext.fromJson(
          json['context'] as Map<String, dynamic>,
        );

  /// The message of the validation failure.
  ///
  /// eg: "email is required"
  final String message;

  /// The path of the validation failure.
  ///
  /// eg: "email"
  ///
  /// Usually this is the name of the field that failed validation.
  final List<String> path;

  /// The type of the validation failure.
  ///
  /// eg: "required"
  ///
  /// Usually this is the name of the validation rule that failed.
  final String type;

  /// Context of the validation failure.
  ///
  /// Contains details about the field that failed validation.
  final ValidationFailureDetailContext context;
}

/// Context of a validation failure.
class ValidationFailureDetailContext {
  /// [ValidationFailureDetailContext] constructor.
  ValidationFailureDetailContext(
    this.value,
    this.invalids,
    this.label,
    this.key,
  );

  /// Creates a [ValidationFailureDetailContext] from JSON.
  ValidationFailureDetailContext.fromJson(Map<String, dynamic> json)
      : value = json['value'] is int?
            ? json['value'].toString()
            : json['value'] as String?,
        invalids =
            (json['invalids'] as List?)?.map((e) => e as String).toList(),
        label = json['label'] as String,
        key = json['key'] as String;

  /// The value of the field that failed validation.
  final String? value;

  /// More details about the field that failed validation.
  final List<String>? invalids;

  /// Field that failed validation.
  ///
  /// eg: "email"
  final String label;

  /// Key of the field that failed validation.
  ///
  /// eg: "email"
  final String key;
}
