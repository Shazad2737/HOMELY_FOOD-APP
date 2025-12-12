part of 'menu_bloc.dart';

@immutable
class MenuState {
  const MenuState({
    required this.menuState,
    this.categories = const [],
    this.selectedCategory,
    this.selectedPlan,
    this.selectedMealType = MealType.breakfast,
    this.searchQuery = '',
    this.debouncedSearchQuery = '',
  });

  factory MenuState.initial() {
    return MenuState(
      menuState: DataState.initial(),
    );
  }

  final DataState<MenuData> menuState;
  final List<Category> categories;
  final Category? selectedCategory;
  final MenuPlan? selectedPlan;
  final MealType selectedMealType;
  final String searchQuery; // User typing
  final String debouncedSearchQuery; // Actually used for API call

  // Convenience getters
  bool get isLoading => menuState.isLoading;
  bool get isRefreshing => menuState.isRefreshing;
  bool get isSuccess => menuState.isSuccess;
  bool get isFailure => menuState.isFailure;

  MenuData? get menuData {
    return menuState.maybeMap(
      success: (state) => state.data,
      refreshing: (state) => state.currentData,
      orElse: () => null,
    );
  }

  Failure? get failure {
    return menuState.maybeMap(
      failure: (state) => state.failure,
      orElse: () => null,
    );
  }

  // Get current meal items
  List<FoodItem> get currentMealItems {
    final data = menuData;
    if (data == null) return [];
    return data.getItemsForMealType(selectedMealType);
  }

  MenuState copyWith({
    DataState<MenuData>? menuState,
    List<Category>? categories,
    Category? selectedCategory,
    MenuPlan? selectedPlan,
    bool overrideSelectedPlan = false,
    MealType? selectedMealType,
    String? searchQuery,
    String? debouncedSearchQuery,
  }) {
    return MenuState(
      menuState: menuState ?? this.menuState,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPlan: overrideSelectedPlan
          ? selectedPlan
          : (selectedPlan ?? this.selectedPlan),
      selectedMealType: selectedMealType ?? this.selectedMealType,
      searchQuery: searchQuery ?? this.searchQuery,
      debouncedSearchQuery: debouncedSearchQuery ?? this.debouncedSearchQuery,
    );
  }
}
