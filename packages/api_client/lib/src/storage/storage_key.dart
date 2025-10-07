import 'package:core/core.dart';
import 'package:flutter/widgets.dart';

/// Function to parse the value from [String] to [T].
typedef Parser<T> = T Function(String);

/// {@template storage_key}
/// A key for storing and retrieving values from storage.
/// {@endtemplate}

// ! toString() method of [T] should be implemented to return a string
// ! representation of [T].
class StorageKey<T> {
  /// {@macro storage_key}
  @protected
  const StorageKey({required this.name, required this.parser});

  /// Authentication token
  static final token = StorageKey<String>(
    name: 'token',
    parser: (p0) => p0,
  );

  /// User data
  static const user = StorageKey<User>(
    name: 'User',
    parser: User.fromJsonString,
  );

  /// The name of the key.
  final String name;

  /// Function to parse the value from [String] to [T].
  ///
  final Parser<T> parser;

  @override
  String toString() => name;
}
