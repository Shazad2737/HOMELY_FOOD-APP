import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'food_selection_state.dart';

/// {@template food_selection_cubit}
/// Cubit for managing food selection bottom sheet state
/// {@endtemplate}
class FoodSelectionCubit extends Cubit<FoodSelectionState> {
  /// {@macro food_selection_cubit}
  FoodSelectionCubit({
    required List<FoodItem> foodItems,
  }) : super(FoodSelectionState(foodItems: foodItems));

  /// Update the search query and filter items
  void updateSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  /// Clear the search query
  void clearSearch() {
    emit(state.copyWith(searchQuery: ''));
  }
}
