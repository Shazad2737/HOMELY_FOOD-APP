import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/menu/models/day_of_week.dart';

/// {@template available_day}
/// Represents a day when a food item is available
/// {@endtemplate}
class AvailableDay extends Equatable {
  /// {@macro available_day}
  const AvailableDay({
    required this.dayOfWeek,
  });

  /// Parse from JSON
  factory AvailableDay.fromJson(Map<String, dynamic> json) {
    return AvailableDay(
      dayOfWeek: DayOfWeek.fromString(json['dayOfWeek'] as String?) ??
          DayOfWeek.monday,
    );
  }

  /// Day of the week
  final DayOfWeek dayOfWeek;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek.toApiString(),
    };
  }

  @override
  List<Object?> get props => [dayOfWeek];
}
