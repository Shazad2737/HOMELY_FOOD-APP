// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required this.cmsFacade,
  }) : super(HomeState.initial()) {
    on<HomeEvent>((event, emit) async {
      switch (event) {
        case HomeLoadedEvent():
          await _onLoadedEvent(event, emit);
        case HomeRefreshedEvent():
          await _onRefreshedEvent(event, emit);
      }
    });
  }

  final ICmsRepository cmsFacade;

  Future<void> _onLoadedEvent(
    HomeLoadedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(homePageState: DataState.loading()));

    final result = await cmsFacade.getHomePage();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            homePageState: DataState.failure(failure),
          ),
        );
      },
      (homePageData) {
        emit(
          state.copyWith(
            homePageState: DataState.success(homePageData),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshedEvent(
    HomeRefreshedEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Use refreshing state if we already have data
    final currentState = state.homePageState;
    if (currentState is DataStateSuccess<HomePageData>) {
      emit(
        state.copyWith(
          homePageState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(homePageState: DataState.loading()));
    }

    final result = await cmsFacade.getHomePage();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            homePageState: DataState.failure(failure),
          ),
        );
      },
      (homePageData) {
        emit(
          state.copyWith(
            homePageState: DataState.success(homePageData),
          ),
        );
      },
    );
  }
}
