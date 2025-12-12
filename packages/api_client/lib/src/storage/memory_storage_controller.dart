import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';

class MemoryStorageController implements IStorageController {
  final Map<StorageKey<dynamic>, dynamic> _storage = {};

  @override
  Future<Either<StorageFailure, Unit>> delete({
    required StorageKey<dynamic> key,
  }) async {
    _storage.remove(key);
    return right(unit);
  }

  @override
  Future<Either<StorageFailure, T>> get<T>({
    required StorageKey<T> key,
  }) async {
    final value = _storage[key] as T?;
    if (value != null) {
      return right(value);
    } else {
      return left(
        StorageFailure(
          code: 404,
          message: 'Key not found: ${key.name}',
        ),
      );
    }
  }

  @override
  Future<Either<StorageFailure, Unit>> save<T>({
    required StorageKey<T> key,
    required T value,
  }) async {
    _storage[key] = value;
    return right(unit);
  }

  @override
  Future<Either<StorageFailure, Unit>> clear() async {
    _storage.clear();
    return right(unit);
  }
}
