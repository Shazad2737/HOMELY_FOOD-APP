import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/menu/models/available_day.dart';
import 'package:homely_api/src/menu/models/day_of_week.dart';
import 'package:homely_api/src/menu/models/deliver_with.dart';
import 'package:homely_api/src/menu/models/delivery_mode.dart';
// Keep cuisine/style as raw strings (no enums)
import 'package:homely_api/src/menu/models/meal_type.dart';
import 'package:homely_api/src/user/models/delivery_location.dart';

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
    this.deliveryTime,
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
      deliveryTime:
          DeliveryTime.fromJson(json['deliveryTime'] as Map<String, dynamic>?),
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

  /// Delivery time information
  final DeliveryTime? deliveryTime;

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
      if (deliveryTime != null) 'deliveryTime': deliveryTime!.toJson(),
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
        deliveryTime,
        availableDays,
        availableLocations,
      ];
}

class DeliveryTime extends Equatable {
  const DeliveryTime({
    required this.start,
    required this.end,
  });

  /// Parse from JSON
  factory DeliveryTime.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryTime(
        start: '00:00',
        end: '00:00',
      );
    }

    if (json['start'] == null || json['end'] == null) {
      return const DeliveryTime(
        start: '00:00',
        end: '00:00',
      );
    }

    if (json['start'] is String? && json['end'] is String?) {
      return DeliveryTime(
        start: json['start'] as String? ?? '00:00',
        end: json['end'] as String? ?? '00:00',
      );
    }

    if (json['start'] is num? && json['end'] is num?) {
      // "deliveryTime": {start: 17:00, end: 20:00},
      return DeliveryTime(
        start: (json['start'] as num?).toString(),
        end: (json['end'] as num?).toString(),
      );
    }

    return DeliveryTime(
      start: json['start'] as String? ?? '00:00',
      end: json['end'] as String? ?? '00:00',
    );
  }

  /// Start time in HH:mm format
  final String start;

  /// End time in HH:mm format
  final String end;

  // times will be in 24-hour HH:mm format, we need to convert them to a more
  //user-friendly format
  // eg 17:00 - 20:00 -> 5:00 PM - 8:00 PM
  String get displayString {
    String formatTime(String time) {
      final parts = time.split(':');
      if (parts.length != 2) return time;

      var hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) {
        hour -= 12;
      } else if (hour == 0) {
        hour = 12;
      }

      return '$hour:$minute $period';
    }

    final formattedStart = formatTime(start);
    final formattedEnd = formatTime(end);
    return '$formattedStart - $formattedEnd';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
    };
  }

  @override
  List<Object?> get props => [
        start,
        end,
      ];
}
