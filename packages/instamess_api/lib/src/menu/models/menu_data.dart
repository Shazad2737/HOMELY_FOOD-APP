import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/food_item.dart';
import 'package:instamess_api/src/menu/models/meal_type.dart';
import 'package:instamess_api/src/menu/models/meal_type_info.dart';
import 'package:instamess_api/src/menu/models/menu_plan.dart';

/// {@template menu_data}
/// Complete menu data including plans, meal types, and food items
/// {@endtemplate}
class MenuData extends Equatable {
  /// {@macro menu_data}
  const MenuData({
    required this.availablePlans,
    required this.mealTypes,
    required this.menu,
  });

  /// Parse from JSON
  factory MenuData.fromJson(Map<String, dynamic> json) {
    // Parse available plans
    final availablePlans = (json['availablePlans'] as List<dynamic>?)
            ?.map((e) => MenuPlan.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse meal types
    final mealTypes = (json['mealTypes'] as List<dynamic>?)
            ?.map((e) => MealTypeInfo.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    // Parse menu map
    final menuMap = <MealType, List<FoodItem>>{};
    final menuJson = json['menu'] as Map<String, dynamic>?;

    if (menuJson != null) {
      // Parse breakfast items
      if (menuJson.containsKey('breakfast')) {
        menuMap[MealType.breakfast] = (menuJson['breakfast'] as List<dynamic>)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse lunch items
      if (menuJson.containsKey('lunch')) {
        menuMap[MealType.lunch] = (menuJson['lunch'] as List<dynamic>)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse dinner items
      if (menuJson.containsKey('dinner')) {
        menuMap[MealType.dinner] = (menuJson['dinner'] as List<dynamic>)
            .map((e) => FoodItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return MenuData(
      availablePlans: availablePlans,
      mealTypes: mealTypes,
      menu: menuMap,
    );
  }

  /// Available subscription plans
  final List<MenuPlan> availablePlans;

  /// Available meal types with timing information
  final List<MealTypeInfo> mealTypes;

  /// Menu items organized by meal type
  final Map<MealType, List<FoodItem>> menu;

  /// Get food items for a specific meal type
  List<FoodItem> getItemsForMealType(MealType type) {
    return menu[type] ?? [];
  }

  /// Check if menu has items for a specific meal type
  bool hasMealType(MealType type) {
    final items = menu[type];
    return items != null && items.isNotEmpty;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'availablePlans': availablePlans.map((e) => e.toJson()).toList(),
      'mealTypes': mealTypes.map((e) => e.toJson()).toList(),
      'menu': {
        if (menu.containsKey(MealType.breakfast))
          'breakfast':
              menu[MealType.breakfast]!.map((e) => e.toJson()).toList(),
        if (menu.containsKey(MealType.lunch))
          'lunch': menu[MealType.lunch]!.map((e) => e.toJson()).toList(),
        if (menu.containsKey(MealType.dinner))
          'dinner': menu[MealType.dinner]!.map((e) => e.toJson()).toList(),
      },
    };
  }

  @override
  List<Object?> get props => [availablePlans, mealTypes, menu];
}
