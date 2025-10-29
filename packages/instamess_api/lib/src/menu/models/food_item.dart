import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/available_day.dart';
import 'package:instamess_api/src/menu/models/cuisine.dart';
import 'package:instamess_api/src/menu/models/day_of_week.dart';
import 'package:instamess_api/src/menu/models/deliver_with.dart';
import 'package:instamess_api/src/menu/models/delivery_mode.dart';
import 'package:instamess_api/src/menu/models/food_style.dart';

/// {@template food_item}
/// Represents a food item in the menu
/// {@endtemplate}
class FoodItem extends Equatable {
  /// {@macro food_item}
  const FoodItem({
    required this.id,
    required this.name,
    required this.code,
    required this.isVegetarian,
    required this.isVegan,
    required this.deliveryMode,
    required this.availableDays,
    this.description,
    this.imageUrl,
    this.cuisine,
    this.style,
    this.price,
    this.deliverWith,
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
      code: json['code'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      cuisine: Cuisine.fromString(json['cuisine'] as String?),
      style: FoodStyle.fromString(json['style'] as String?),
      price: parsedPrice,
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      deliveryMode: DeliveryMode.fromString(json['deliveryMode'] as String?) ??
          DeliveryMode.separate,
      deliverWith: json['deliverWith'] != null
          ? DeliverWith.fromJson(json['deliverWith'] as Map<String, dynamic>)
          : null,
      availableDays: (json['availableDays'] as List<dynamic>?)
              ?.map((e) => AvailableDay.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Unique identifier
  final String id;

  /// Food item name
  final String name;

  /// Food item code
  final String code;

  /// Optional description
  final String? description;

  /// Optional image URL
  final String? imageUrl;

  /// Type of cuisine
  final Cuisine? cuisine;

  /// Food style
  final FoodStyle? style;

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
      'code': code,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (cuisine != null) 'cuisine': cuisine!.toApiString(),
      if (style != null) 'style': style!.toApiString(),
      if (price != null) 'price': price,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'deliveryMode': deliveryMode.toApiString(),
      if (deliverWith != null) 'deliverWith': deliverWith!.toJson(),
      'availableDays': availableDays.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        code,
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
      ];
}
