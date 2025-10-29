import 'package:api_client/api_client.dart';

/// Wrapper class to manage UI state in response to async tasks
sealed class DataState<T> {
  const DataState();

  factory DataState.initial() => DataStateInitial<T>();
  factory DataState.loading() => DataStateLoading<T>();
  factory DataState.refreshing(T currentData) =>
      DataStateRefreshing<T>(currentData);
  factory DataState.success(T data) => DataStateSuccess<T>(data);
  factory DataState.failure(Failure failure) => DataStateFailure<T>(failure);

  /// Whether the data is loading
  bool get isLoading => this is DataStateLoading;

  /// Whether the data is refreshing
  bool get isRefreshing => this is DataStateRefreshing;

  /// Whether the data is success
  bool get isSuccess => this is DataStateSuccess;

  /// Whether the data is failure
  bool get isFailure => this is DataStateFailure;

  W map<W>({
    required W Function(DataStateInitial<T>) initial,
    required W Function(DataStateLoading<T>) loading,
    required W Function(DataStateSuccess<T>) success,
    required W Function(DataStateFailure<T>) failure,
    W Function(DataStateRefreshing<T>)? refreshing,
  }) {
    return switch (this) {
      DataStateInitial() => initial(this as DataStateInitial<T>),
      DataStateLoading() => loading(this as DataStateLoading<T>),
      DataStateRefreshing() => refreshing != null
          ? refreshing(this as DataStateRefreshing<T>)
          : loading(
              this as DataStateLoading<T>,
            ), // Fallback to loading behavior
      DataStateSuccess() => success(this as DataStateSuccess<T>),
      DataStateFailure() => failure(this as DataStateFailure<T>),
    };
  }

  W maybeMap<W>({
    required W Function() orElse,
    W? Function(DataStateInitial<T>)? initial,
    W? Function(DataStateLoading<T>)? loading,
    W? Function(DataStateRefreshing<T>)? refreshing,
    W? Function(DataStateSuccess<T>)? success,
    W? Function(DataStateFailure<T>)? failure,
  }) {
    var result = orElse();
    if (this is DataStateInitial) {
      result = initial?.call(this as DataStateInitial<T>) ?? orElse();
    }
    if (this is DataStateLoading) {
      result = loading?.call(this as DataStateLoading<T>) ?? orElse();
    }
    if (this is DataStateRefreshing) {
      result = refreshing?.call(this as DataStateRefreshing<T>) ?? orElse();
    }
    if (this is DataStateSuccess) {
      result = success?.call(this as DataStateSuccess<T>) ?? orElse();
    }
    if (this is DataStateFailure) {
      result = failure?.call(this as DataStateFailure<T>) ?? orElse();
    }
    return result;
  }
}

/// Initial state
final class DataStateInitial<T> extends DataState<T> {
  const DataStateInitial();
}

/// Data is loading.
final class DataStateLoading<T> extends DataState<T> {
  /// Creates a new [DataStateLoading]
  const DataStateLoading();
}

/// Data is refreshing while showing current data.
final class DataStateRefreshing<T> extends DataState<T> {
  /// Creates a new [DataStateRefreshing]
  const DataStateRefreshing(this.currentData);

  /// The current data being shown while refreshing
  final T currentData;

  @override
  String toString() {
    return 'DataStateRefreshing{currentData: $currentData}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataStateRefreshing<T> && other.currentData == currentData;
  }

  @override
  int get hashCode => currentData.hashCode;
}

/// Data has success successfully.
final class DataStateSuccess<T> extends DataState<T> {
  /// Creates a new [DataStateSuccess]
  const DataStateSuccess(this.data);

  /// The actual data
  final T data;

  @override
  String toString() {
    return 'DataStateSuccess{data: $data}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataStateSuccess<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// {@template data_state_failure}
/// Represents an failure occurred while fetching data
/// {@endtemplate}
final class DataStateFailure<T> extends DataState<T> {
  /// {@macro data_state_failure}
  const DataStateFailure(
    this.failure,
  );

  /// [Failure] that occurred
  final Failure failure;
}
