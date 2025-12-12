import 'dart:convert';

/// An abstract class that represents a model.
abstract class Model {
  Model();

  /// Parses the json and returns an instance of [Model].
  factory Model.fromJson(Map<String, dynamic> _) {
    throw UnimplementedError();
  }

  /// Parses the [source] and returns an instance of [Model].
  factory Model.fromJsonString(String source) {
    return Model.fromJson(json.decode(source) as Map<String, dynamic>);
  }

  /// Converts the [Model] to a [Map<String, dynamic>].
  Map<String, dynamic> toJson();

  /// Converts the [Model] to a RAW string.
  String toJsonString() => json.encode(toJson());

  @override
  String toString() => toJson().toString();
}
