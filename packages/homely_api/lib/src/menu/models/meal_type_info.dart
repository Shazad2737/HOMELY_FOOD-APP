import 'package:equatable/equatable.dart';
import 'package:homely_api/src/menu/models/meal_type.dart';

/// {@template meal_type_info}
/// Information about a meal type (breakfast, lunch, dinner)
/// {@endtemplate}
class MealTypeInfo extends Equatable {
  /// {@macro meal_type_info}
  const MealTypeInfo({
    required this.id,
    required this.type,
    required this.name,
    required this.sortOrder,
    this.description,
    this.startTime,
    this.endTime,
  });

  /// Parse from JSON
  factory MealTypeInfo.fromJson(Map<String, dynamic> json) {
    // Parse sortOrder - handle both string and numeric values
    var parsedSortOrder = 0;
    final sortOrderValue = json['sortOrder'];
    if (sortOrderValue != null) {
      if (sortOrderValue is num) {
        parsedSortOrder = sortOrderValue.toInt();
      } else if (sortOrderValue is String) {
        parsedSortOrder = int.tryParse(sortOrderValue) ?? 0;
      }
    }

    return MealTypeInfo(
      id: json['id'] as String,
      type: MealType.fromString(json['type'] as String?) ?? MealType.breakfast,
      name: json['name'] as String,
      description: json['description'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      sortOrder: parsedSortOrder,
    );
  }

  /// Unique identifier
  final String id;

  /// Type of meal
  final MealType type;

  /// Display name
  final String name;

  /// Optional description
  final String? description;

  /// Start time (e.g., "07:00 AM")
  final String? startTime;

  /// End time (e.g., "09:00 AM")
  final String? endTime;

  /// Sort order for display
  final int sortOrder;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'name': name,
      if (description != null) 'description': description,
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
      'sortOrder': sortOrder,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        description,
        startTime,
        endTime,
        sortOrder,
      ];
}
