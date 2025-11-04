part of 'order_form_bloc.dart';

/// {@template order_form_event}
/// Base class for order form events
/// {@endtemplate}
sealed class OrderFormEvent extends Equatable {
  /// {@macro order_form_event}
  const OrderFormEvent();

  @override
  List<Object?> get props => [];
}

/// Event when the order form is first loaded
class OrderFormLoadedEvent extends OrderFormEvent {
  /// {@macro order_form_loaded_event}
  const OrderFormLoadedEvent();
}

/// Event when a date is selected from the calendar
class OrderFormDateSelectedEvent extends OrderFormEvent {
  /// {@macro order_form_date_selected_event}
  const OrderFormDateSelectedEvent(this.date);

  /// The selected date (ISO 8601 format)
  final String date;

  @override
  List<Object?> get props => [date];
}

/// Event when date selection needs to be cleared (with confirmation)
class OrderFormDateClearRequestedEvent extends OrderFormEvent {
  /// {@macro order_form_date_clear_requested_event}
  const OrderFormDateClearRequestedEvent();
}

/// Event when date is actually cleared (after confirmation)
class OrderFormDateClearedEvent extends OrderFormEvent {
  /// {@macro order_form_date_cleared_event}
  const OrderFormDateClearedEvent();
}

/// Event when a meal type card is tapped
class OrderFormMealTappedEvent extends OrderFormEvent {
  /// {@macro order_form_meal_tapped_event}
  const OrderFormMealTappedEvent(this.mealType);

  /// The meal type that was tapped
  final MealType mealType;

  @override
  List<Object?> get props => [mealType];
}

/// Event when a food item is selected
class OrderFormFoodSelectedEvent extends OrderFormEvent {
  /// {@macro order_form_food_selected_event}
  const OrderFormFoodSelectedEvent({
    required this.mealType,
    required this.food,
    required this.location,
  });

  /// The meal type for this food
  final MealType mealType;

  /// The selected food item
  final FoodItem food;

  /// The selected delivery location
  final DeliveryLocation location;

  @override
  List<Object?> get props => [mealType, food, location];
}

/// Event when a location is selected
class OrderFormLocationSelectedEvent extends OrderFormEvent {
  /// {@macro order_form_location_selected_event}
  const OrderFormLocationSelectedEvent({
    required this.mealType,
    required this.location,
  });

  /// The meal type for this location
  final MealType mealType;

  /// The selected location
  final DeliveryLocation location;

  @override
  List<Object?> get props => [mealType, location];
}

/// Event when a meal is being edited
class OrderFormMealEditedEvent extends OrderFormEvent {
  /// {@macro order_form_meal_edited_event}
  const OrderFormMealEditedEvent(this.mealType);

  /// The meal type to edit
  final MealType mealType;

  @override
  List<Object?> get props => [mealType];
}

/// Event when a meal is removed
class OrderFormMealRemovedEvent extends OrderFormEvent {
  /// {@macro order_form_meal_removed_event}
  const OrderFormMealRemovedEvent(this.mealType);

  /// The meal type to remove
  final MealType mealType;

  @override
  List<Object?> get props => [mealType];
}

/// Event when order notes are changed
class OrderFormNotesChangedEvent extends OrderFormEvent {
  /// {@macro order_form_notes_changed_event}
  const OrderFormNotesChangedEvent(this.notes);

  /// The order notes
  final String notes;

  @override
  List<Object?> get props => [notes];
}

/// Event when the order form is submitted
class OrderFormSubmittedEvent extends OrderFormEvent {
  /// {@macro order_form_submitted_event}
  const OrderFormSubmittedEvent();
}
