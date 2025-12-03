import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/available_day.dart';
import 'package:instamess_api/src/menu/models/day_of_week.dart';
import 'package:instamess_api/src/menu/models/deliver_with.dart';
import 'package:instamess_api/src/menu/models/delivery_mode.dart';
// Keep cuisine/style as raw strings (no enums)
import 'package:instamess_api/src/menu/models/meal_type.dart';
import 'package:instamess_api/src/user/models/delivery_location.dart';

/// {@template food_item}
/// Represents a food item in the menu
/// {@endtemplate}
class FoodItem extends Equatable {
  /// {@macro food_item}
  const FoodItem({
    required this.id,
    required this.name,
    required this.isVegetarian,
    required this.isVegan,
    required this.deliveryMode,
    required this.availableDays,
    this.mealTypeId,
    this.code,
    this.description,
    this.imageUrl,
    this.cuisine,
    this.style,
    this.price,
    this.deliverWith,
    this.availableLocations = const <DeliveryLocation>[],
  });

  /// Parse from JSON
  factory FoodItem.fromJson(Map<String, dynamic> json) {
    // Parse price - handle both string and numeric values
    double? parsedPrice;
    final priceValue = json['price'];
    if (priceValue != null) {
      if (priceValue is num) {
        parsedPrice = priceValue.toDouble();
      } else if (priceValue is String) {
        parsedPrice = double.tryParse(priceValue);
      }
    }

    return FoodItem(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String?,
      mealTypeId: json['mealTypeId'] as String?,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      // Store cuisine & style as raw strings directly from API
      cuisine: json['cuisine'] as String?,
      style: json['style'] as String?,
      price: parsedPrice,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      deliveryMode: DeliveryMode.fromString(json['deliveryMode'] as String?) ??
          DeliveryMode.separate,
      deliverWith: _parseDeliverWith(json['deliverWith']),
      availableDays: (json['availableDays'] as List<dynamic>?)
              ?.map((e) => AvailableDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      availableLocations: pick(json, 'availableLocations').asListOrEmpty(
        (pick) => DeliveryLocation.fromJson(
          pick.asMapOrThrow<String, dynamic>(),
        ),
      ),
    );
  }

  /// Parse deliverWith field - handles both string and object formats
  static DeliverWith? _parseDeliverWith(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      // Full object with id, name, type
      return DeliverWith.fromJson(value);
    } else if (value is String) {
      // Just meal type string like "BREAKFAST"
      final mealType = MealType.fromString(value);
      if (mealType == null) return null;

      return DeliverWith(
        id: '', // Not provided by API
        name: value,
        type: mealType,
      );
    }

    return null;
  }

  /// Unique identifier
  final String id;

  /// Food item name
  final String name;

  /// Food item code
  final String? code;

  /// Meal type ID this food item belongs to
  final String? mealTypeId;

  /// Optional description
  final String? description;

  /// Optional image URL
  final String? imageUrl;

  /// Cuisine string as returned by API
  final String? cuisine;

  /// Style string as returned by API
  final String? style;

  /// Price
  final double? price;

  /// Whether the item is vegetarian
  final bool isVegetarian;

  /// Whether the item is vegan
  final bool isVegan;

  /// Delivery mode
  final DeliveryMode deliveryMode;

  /// Meal this item is delivered with (if deliveryMode is withOther)
  final DeliverWith? deliverWith;

  /// Days when this item is available
  final List<AvailableDay> availableDays;

  /// Locations where this item can be delivered
  final List<DeliveryLocation> availableLocations;

  /// Get list of DayOfWeek from availableDays
  List<DayOfWeek> get availableDaysOfWeek {
    return availableDays.map((e) => e.dayOfWeek).toList();
  }

  /// Check if item is available on a specific day
  bool isAvailableOn(DayOfWeek day) {
    return availableDaysOfWeek.contains(day);
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (code != null) 'code': code,
      'mealTypeId': mealTypeId,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (cuisine != null) 'cuisine': cuisine,
      if (style != null) 'style': style,
      if (price != null) 'price': price,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'deliveryMode': deliveryMode.toApiString(),
      if (deliverWith != null) 'deliverWith': deliverWith!.toJson(),
      'availableDays': availableDays.map((e) => e.toJson()).toList(),
      'availableLocations': availableLocations.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        mealTypeId,
        description,
        imageUrl,
        cuisine,
        style,
        price,
        isVegetarian,
        isVegan,
        deliveryMode,
        deliverWith,
        availableDays,
        availableLocations,
      ];
}
