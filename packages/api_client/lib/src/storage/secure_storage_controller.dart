import 'dart:async';
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';

/// {@template storage_controller}
/// A controller to read and write to secure storage.
/// Uses [FlutterSecureStorage].
/// {@endtemplate}
class SecureStorageController implements IStorageController {
  ///{@macro storage_controller}
  SecureStorageController()
      : _flutterSecureStorage = const FlutterSecureStorage(
          iOptions: IOSOptions(
            synchronizable: true,
            accessibility: KeychainAccessibility.first_unlock,
          ),
        );

  /// The [SecureStorageController] instance.
  factory SecureStorageController.instance() =>
      _instance ??= SecureStorageController();

  static SecureStorageController? _instance;

  /// The [FlutterSecureStorage] instance.
  final FlutterSecureStorage _flutterSecureStorage;

  final Map<String, String> _cache = {};

  /// Deletes the value at [key].
  ///
  /// Returns [StorageFailure] if an error occurs.
  @override
  Future<Either<StorageFailure, Unit>> delete({
    required StorageKey<dynamic> key,
  }) async {
    try {
      await _flutterSecureStorage.delete(key: key.name);
      _cache.remove(key.name);
      log('Deleted "$key"');
      return right(unit);
    } catch (e, s) {
      Logger.logError(
        'Error deleting "$key"',
        e,
        stackTrace: s,
      );
      return left(StorageFailure(code: 500, message: 'Error deleting "$key"'));
    }
  }

  /// Returns the value at [key].
  ///
  /// Returns [StorageFailure] if an error occurs.
  @override
  Future<Either<StorageFailure, T>> get<T>({
    required StorageKey<T> key,
  }) async {
    try {
      if (_cache.containsKey(key.name)) {
        final value = _cache[key.name];
        if (value != null) {
          log('Got "$key" from cache');
          return right(key.parser(value));
        }
      }
      final value = await _flutterSecureStorage.read(key: key.name);
      if (value != null) {
        log('Got "$key" from storage');
        _cache[key.name] = value;
        return right(key.parser(value));
      } else {
        log('No "$key" found, value is null');
        return left(StorageFailure(code: 404, message: 'No "$key" found'));
      }
    } catch (e, s) {
      Logger.logError(
        'Error getting "$key"',
        e,
        stackTrace: s,
      );
      return left(StorageFailure(code: 500, message: 'No "$key" found'));
    }
  }

  /// Saves the value at [key].
  ///
  /// Returns [StorageFailure] if an error occurs.
  @override
  Future<Either<StorageFailure, Unit>> save<T>({
    required StorageKey<T> key,
    required T value,
  }) async {
    try {
      await _flutterSecureStorage.write(key: key.name, value: value.toString());
      _cache[key.name] = value.toString();
      log('Saved "$key"');
      return right(unit);
    } catch (e, s) {
      Logger.logError(
        'Error saving "$key"',
        e,
        stackTrace: s,
      );
      return left(StorageFailure(code: 500, message: 'Error saving "$key"'));
    }
  }

  /// Clears the secure storage.
  ///
  /// Returns [StorageFailure] if an error occurs.
  @override
  Future<Either<StorageFailure, Unit>> clear() async {
    try {
      await _flutterSecureStorage.deleteAll();
      _cache.clear();
      log('Cleared storage');
      return right(unit);
    } catch (e, s) {
      Logger.logError(
        'Error clearing storage',
        e,
        stackTrace: s,
      );
      return left(
        const StorageFailure(code: 500, message: 'Error clearing storage'),
      );
    }
  }
}
