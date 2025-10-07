import 'package:api_client/api_client.dart';
import 'package:api_client/src/storage/storage_key.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class IStorageController {
  Future<Either<StorageFailure, Unit>> delete({
    required StorageKey<dynamic> key,
  });

  Future<Either<StorageFailure, T>> get<T>({
    required StorageKey<T> key,
  });

  Future<Either<StorageFailure, Unit>> save<T>({
    required StorageKey<T> key,
    required T value,
  });

  Future<Either<StorageFailure, Unit>> clear();
}
