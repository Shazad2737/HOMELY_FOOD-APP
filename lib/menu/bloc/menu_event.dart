part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {}

/// Initialize menu - fetches categories and sets initial category
final class MenuInitializedEvent extends MenuEvent {}

/// Categories loaded from repository
final class MenuCategoriesLoadedEvent extends MenuEvent {
  MenuCategoriesLoadedEvent({required this.categories});

  final List<Category> categories;
}

/// Category selection changed
final class MenuCategorySelectedEvent extends MenuEvent {
  MenuCategorySelectedEvent({required this.category});

  final Category category;
}

/// Plan selection changed
final class MenuPlanSelectedEvent extends MenuEvent {
  MenuPlanSelectedEvent({this.plan});

  final MenuPlan? plan; // null = clear filter
}

/// Meal type tab changed
final class MenuMealTypeSelectedEvent extends MenuEvent {
  MenuMealTypeSelectedEvent({required this.mealType});

  final MealType mealType;
}

/// Search query changed (will be debounced)
final class MenuSearchQueryChangedEvent extends MenuEvent {
  MenuSearchQueryChangedEvent({required this.query});

  final String query;
}

/// Refresh current menu
final class MenuRefreshedEvent extends MenuEvent {}
