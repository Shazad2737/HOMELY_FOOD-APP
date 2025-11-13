part of 'food_selection_cubit.dart';

/// {@template food_selection_state}
/// State for the food selection bottom sheet
/// {@endtemplate}
@immutable
class FoodSelectionState {
  /// {@macro food_selection_state}
  const FoodSelectionState({
    required this.foodItems,
    this.searchQuery = '',
  });

  /// All available food items
  final List<FoodItem> foodItems;

  /// Current search query
  final String searchQuery;

  /// Get filtered food items based on search query
  List<FoodItem> get filteredFoodItems {
    if (searchQuery.isEmpty) return foodItems;

    final query = searchQuery.toLowerCase();
    return foodItems.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) ?? false) ||
          (item.code?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Copy with
  FoodSelectionState copyWith({
    List<FoodItem>? foodItems,
    String? searchQuery,
  }) {
    return FoodSelectionState(
      foodItems: foodItems ?? this.foodItems,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FoodSelectionState &&
        other.foodItems == foodItems &&
        other.searchQuery == searchQuery;
  }

  @override
  int get hashCode => foodItems.hashCode ^ searchQuery.hashCode;
}
