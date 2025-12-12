import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/menu/models/food_item.dart';

/// {@template available_meal_types}
/// Indicates which meal types are available for a specific day
/// {@endtemplate}
class AvailableMealTypes extends Equatable {
  /// {@macro available_meal_types}
  const AvailableMealTypes({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  /// Creates AvailableMealTypes from JSON
  factory AvailableMealTypes.fromJson(Map<String, dynamic> json) {
    return AvailableMealTypes(
      breakfast: pick(json, 'breakfast').asBoolOrThrow(),
      lunch: pick(json, 'lunch').asBoolOrThrow(),
      dinner: pick(json, 'dinner').asBoolOrThrow(),
    );
  }

  /// Whether breakfast is available
  final bool breakfast;

  /// Whether lunch is available
  final bool lunch;

  /// Whether dinner is available
  final bool dinner;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    };
  }

  @override
  List<Object?> get props => [breakfast, lunch, dinner];
}

/// {@template food_items_by_meal}
/// Food items grouped by meal type
/// {@endtemplate}
class FoodItemsByMeal extends Equatable {
  /// {@macro food_items_by_meal}
  const FoodItemsByMeal({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  /// Creates FoodItemsByMeal from JSON
  factory FoodItemsByMeal.fromJson(Map<String, dynamic> json) {
    return FoodItemsByMeal(
      breakfast: pick(json, 'breakfast').asListOrEmpty((pick) {
        return FoodItem.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      lunch: pick(json, 'lunch').asListOrEmpty((pick) {
        return FoodItem.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      dinner: pick(json, 'dinner').asListOrEmpty((pick) {
        return FoodItem.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Breakfast food items
  final List<FoodItem> breakfast;

  /// Lunch food items
  final List<FoodItem> lunch;

  /// Dinner food items
  final List<FoodItem> dinner;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'breakfast': breakfast.map((e) => e.toJson()).toList(),
      'lunch': lunch.map((e) => e.toJson()).toList(),
      'dinner': dinner.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [breakfast, lunch, dinner];
}

/// {@template order_day}
/// Represents a single day in the calendar with its availability status
/// {@endtemplate}
class OrderDay extends Equatable {
  /// {@macro order_day}
  const OrderDay({
    required this.date,
    required this.dayOfWeek,
    required this.isAvailable,
    required this.alreadyOrdered,
    required this.availableMealTypes,
    required this.foodItems,
    this.holidayName,
    this.existingOrderNumber,
    this.existingOrderStatus,
  });

  /// Creates OrderDay from JSON
  factory OrderDay.fromJson(Map<String, dynamic> json) {
    return OrderDay(
      date: pick(json, 'date').asStringOrThrow(),
      dayOfWeek: pick(json, 'dayOfWeek').asStringOrThrow(),
      isAvailable: pick(json, 'isAvailable').asBoolOrFalse(),
      holidayName: pick(json, 'holidayName').asStringOrNull(),
      alreadyOrdered: pick(json, 'alreadyOrdered').asBoolOrFalse(),
      existingOrderNumber: pick(json, 'existingOrderNumber').asStringOrNull(),
      existingOrderStatus: pick(json, 'existingOrderStatus').asStringOrNull(),
      availableMealTypes: AvailableMealTypes.fromJson(
        pick(json, 'availableMealTypes').asMapOrThrow<String, dynamic>(),
      ),
      foodItems: FoodItemsByMeal.fromJson(
        pick(json, 'foodItems').asMapOrThrow<String, dynamic>(),
      ),
    );
  }

  /// Date in ISO 8601 format (e.g., "2025-11-05")
  final String date;

  /// Day of week (e.g., "MONDAY")
  final String dayOfWeek;

  /// Whether ordering is available for this day
  final bool isAvailable;

  /// Holiday name if applicable
  final String? holidayName;

  /// Whether an order already exists for this date
  final bool alreadyOrdered;

  /// Existing order number if already ordered
  final String? existingOrderNumber;

  /// Status of existing order if already ordered
  final String? existingOrderStatus;

  /// Available meal types for this day
  final AvailableMealTypes availableMealTypes;

  /// Food items grouped by meal type
  final FoodItemsByMeal foodItems;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'dayOfWeek': dayOfWeek,
      'isAvailable': isAvailable,
      'holidayName': holidayName,
      'alreadyOrdered': alreadyOrdered,
      'existingOrderNumber': existingOrderNumber,
      'existingOrderStatus': existingOrderStatus,
      'availableMealTypes': availableMealTypes.toJson(),
      'foodItems': foodItems.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        date,
        dayOfWeek,
        isAvailable,
        holidayName,
        alreadyOrdered,
        existingOrderNumber,
        existingOrderStatus,
        availableMealTypes,
        foodItems,
      ];
}
