part of 'order_form_bloc.dart';

/// {@template order_item_selection}
/// Represents a selected meal item with its details
/// {@endtemplate}
class OrderItemSelection extends Equatable {
  /// {@macro order_item_selection}
  const OrderItemSelection({
    required this.food,
    required this.location,
    this.notes,
  });

  /// The selected food item
  final FoodItem food;

  /// The selected delivery location
  final DeliveryLocation location;

  /// Optional notes for this item
  final String? notes;

  /// Copy with
  OrderItemSelection copyWith({
    FoodItem? food,
    DeliveryLocation? location,
    String? notes,
  }) {
    return OrderItemSelection(
      food: food ?? this.food,
      location: location ?? this.location,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [food, location, notes];
}

/// {@template order_form_state}
/// State for the order form
/// {@endtemplate}
class OrderFormState extends Equatable {
  /// {@macro order_form_state}
  const OrderFormState({
    required this.subscriptionState,
    required this.availableDaysState,
    required this.createOrderState,
    this.selectedDate,
    this.mealSelections = const {},
    this.orderNotes,
    this.activeBottomSheet,
    this.pendingFood,
    this.mealTapError,
  });

  /// Initial state
  factory OrderFormState.initial() {
    return OrderFormState(
      subscriptionState: DataState.initial(),
      availableDaysState: DataState.initial(),
      createOrderState: DataState.initial(),
    );
  }

  /// Subscription data state (checked first before loading available days)
  final DataState<SubscriptionData> subscriptionState;

  /// Whether user has an active subscription
  bool get hasActiveSubscription {
    return subscriptionState.maybeMap(
      success: (s) => s.data.hasSubscribedMeals,
      refreshing: (r) => r.currentData.hasSubscribedMeals,
      orElse: () => false,
    );
  }

  /// Available days data state
  final DataState<AvailableOrderDays> availableDaysState;

  /// Currently selected date (ISO 8601 format)
  final String? selectedDate;

  /// Map of meal type to selected item
  final Map<MealType, OrderItemSelection?> mealSelections;

  /// Overall order notes
  final String? orderNotes;

  /// Create order state
  final DataState<CreateOrderResponse> createOrderState;

  /// Which bottom sheet is currently active (for tracking food selection flow)
  final MealType? activeBottomSheet;

  /// Pending food item (selected but waiting for location)
  final FoodItem? pendingFood;

  /// Error message from meal tap (e.g., no date selected, meal unavailable)
  final String? mealTapError;

  /// Whether a date has been selected
  bool get hasSelectedDate => selectedDate != null;

  /// Whether meal cards can be shown
  bool get canShowMealCards {
    if (!hasSelectedDate) return false;
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.isAvailable ?? false;
  }

  /// Whether the selected date is a holiday
  bool get isSelectedDateHoliday {
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.holidayName != null;
  }

  /// Whether the selected date already has an order
  bool get isSelectedDateAlreadyOrdered {
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.alreadyOrdered ?? false;
  }

  /// Existing order number if already ordered
  String? get existingOrderNumber {
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.existingOrderNumber;
  }

  /// Existing order status if already ordered
  String? get existingOrderStatus {
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.existingOrderStatus;
  }

  /// Holiday name if applicable
  String? get holidayName {
    final selectedDay = findDayByDate(selectedDate);
    return selectedDay?.holidayName;
  }

  /// Number of meals selected
  int get selectedMealCount {
    return mealSelections.values.where((s) => s != null).length;
  }

  /// Whether the order can be submitted
  bool get canSubmit {
    return hasSelectedDate &&
        selectedMealCount > 0 &&
        !isSelectedDateHoliday &&
        !isSelectedDateAlreadyOrdered &&
        createOrderState is! DataStateLoading;
  }

  /// Get food items for a specific meal type
  List<FoodItem> getFoodItemsForMeal(MealType mealType) {
    final selectedDay = findDayByDate(selectedDate);
    if (selectedDay == null) return [];

    switch (mealType) {
      case MealType.breakfast:
        return selectedDay.foodItems.breakfast;
      case MealType.lunch:
        return selectedDay.foodItems.lunch;
      case MealType.dinner:
        return selectedDay.foodItems.dinner;
    }
  }

  /// Check if a meal type is available
  bool isMealTypeAvailable(MealType mealType) {
    final selectedDay = findDayByDate(selectedDate);
    if (selectedDay == null) return false;

    switch (mealType) {
      case MealType.breakfast:
        return selectedDay.availableMealTypes.breakfast;
      case MealType.lunch:
        return selectedDay.availableMealTypes.lunch;
      case MealType.dinner:
        return selectedDay.availableMealTypes.dinner;
    }
  }

  /// Get list of available but unselected meal types
  List<MealType> get unselectedAvailableMealTypes {
    if (selectedDate == null) return [];

    final unselected = <MealType>[];

    for (final mealType in MealType.values) {
      // Check if meal type is available
      if (isMealTypeAvailable(mealType)) {
        // Check if it's not selected
        final isSelected =
            mealSelections.containsKey(mealType) &&
            mealSelections[mealType] != null;
        if (!isSelected) {
          unselected.add(mealType);
        }
      }
    }

    return unselected;
  }

  /// Whether user has unselected available meals
  bool get hasUnselectedAvailableMeals =>
      unselectedAvailableMealTypes.isNotEmpty;

  /// Get available locations
  List<DeliveryLocation> get availableLocations {
    return availableDaysState.maybeMap(
      success: (data) => data.data.locations,
      refreshing: (data) => data.currentData.locations,
      orElse: () => [],
    );
  }

  /// Find a day by date
  user_models.OrderDay? findDayByDate(String? date) {
    if (date == null) return null;
    return availableDaysState.maybeMap(
      success: (data) {
        try {
          return data.data.days.firstWhere((d) => d.date == date);
        } catch (e) {
          return null;
        }
      },
      refreshing: (data) {
        try {
          return data.currentData.days.firstWhere((d) => d.date == date);
        } catch (e) {
          return null;
        }
      },
      orElse: () => null,
    );
  }

  /// Get list of previous available dates that haven't been ordered
  /// (skipped dates between today and the given date)
  List<user_models.OrderDay> getSkippedDates(String targetDate) {
    final skipped = <user_models.OrderDay>[];
    final days = availableDaysState.maybeMap(
      success: (data) => data.data.days,
      refreshing: (data) => data.currentData.days,
      orElse: () => <user_models.OrderDay>[],
    );

    final targetDateTime = DateTime.parse(targetDate);

    for (final day in days) {
      final dayDateTime = DateTime.parse(day.date);
      // Check if day is before target date
      if (dayDateTime.isBefore(targetDateTime)) {
        // Check if it's available but not ordered (and not a holiday)
        if (day.isAvailable && !day.alreadyOrdered && day.holidayName == null) {
          skipped.add(day);
        }
      }
    }

    return skipped;
  }

  /// Copy with
  OrderFormState copyWith({
    DataState<SubscriptionData>? subscriptionState,
    DataState<AvailableOrderDays>? availableDaysState,
    String? selectedDate,
    bool clearSelectedDate = false,
    Map<MealType, OrderItemSelection?>? mealSelections,
    String? orderNotes,
    bool clearOrderNotes = false,
    DataState<CreateOrderResponse>? createOrderState,
    MealType? activeBottomSheet,
    bool clearActiveBottomSheet = false,
    FoodItem? pendingFood,
    bool clearPendingFood = false,
    String? mealTapError,
    bool clearMealTapError = false,
  }) {
    return OrderFormState(
      subscriptionState: subscriptionState ?? this.subscriptionState,
      availableDaysState: availableDaysState ?? this.availableDaysState,
      selectedDate: clearSelectedDate
          ? null
          : (selectedDate ?? this.selectedDate),
      mealSelections: mealSelections ?? this.mealSelections,
      orderNotes: clearOrderNotes ? null : (orderNotes ?? this.orderNotes),
      createOrderState: createOrderState ?? this.createOrderState,
      activeBottomSheet: clearActiveBottomSheet
          ? null
          : (activeBottomSheet ?? this.activeBottomSheet),
      pendingFood: clearPendingFood ? null : (pendingFood ?? this.pendingFood),
      mealTapError: clearMealTapError
          ? null
          : (mealTapError ?? this.mealTapError),
    );
  }

  @override
  List<Object?> get props => [
    subscriptionState,
    availableDaysState,
    selectedDate,
    mealSelections,
    orderNotes,
    createOrderState,
    activeBottomSheet,
    pendingFood,
    mealTapError,
  ];
}
