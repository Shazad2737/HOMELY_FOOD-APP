import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// Meal type enum
enum MealTypeEnum {
  breakfast,
  lunch,
  dinner;

  /// Creates MealTypeEnum from string
  static MealTypeEnum? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'BREAKFAST':
        return MealTypeEnum.breakfast;
      case 'LUNCH':
        return MealTypeEnum.lunch;
      case 'DINNER':
        return MealTypeEnum.dinner;
      default:
        return null;
    }
  }
}

/// {@template meal_type}
/// Represents a meal type with timing information
/// {@endtemplate}
class MealType extends Equatable {
  /// {@macro meal_type}
  const MealType({
    required this.id,
    required this.name,
    required this.type,
    this.startTime,
    this.endTime,
  });

  /// Creates MealType from JSON
  factory MealType.fromJson(Map<String, dynamic> json) {
    return MealType(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      type: MealTypeEnum.fromString(pick(json, 'type').asStringOrNull()) ??
          MealTypeEnum.breakfast,
      startTime: pick(json, 'startTime').asStringOrNull(),
      endTime: pick(json, 'endTime').asStringOrNull(),
    );
  }

  /// Meal type ID
  final String id;

  /// Meal type name
  final String name;

  /// Meal type enum
  final MealTypeEnum type;

  /// Start time (HH:mm format) - optional
  final String? startTime;

  /// End time (HH:mm format) - optional
  final String? endTime;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name.toUpperCase(),
      if (startTime != null) 'startTime': startTime,
      if (endTime != null) 'endTime': endTime,
    };
  }

  @override
  List<Object?> get props => [id, name, type, startTime, endTime];
}
