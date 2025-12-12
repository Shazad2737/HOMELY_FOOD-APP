part of 'home_bloc.dart';

@immutable
class HomeState {
  const HomeState({
    required this.homePageState,
  });

  factory HomeState.initial() {
    return HomeState(
      homePageState: DataState.initial(),
    );
  }

  final DataState<HomePageData> homePageState;

  bool get isLoading => homePageState.isLoading;
  bool get isRefreshing => homePageState.isRefreshing;
  bool get isSuccess => homePageState.isSuccess;
  bool get isFailure => homePageState.isFailure;

  HomePageData? get homePageData {
    return homePageState.maybeMap(
      success: (state) => state.data,
      refreshing: (state) => state.currentData,
      orElse: () => null,
    );
  }

  Failure? get failure {
    return homePageState.maybeMap(
      failure: (state) => state.failure,
      orElse: () => null,
    );
  }

  HomeState copyWith({
    DataState<HomePageData>? homePageState,
  }) {
    return HomeState(
      homePageState: homePageState ?? this.homePageState,
    );
  }

  @override
  String toString() =>
      '''
HomeState {
  homePageState: $homePageState
}
''';
}
