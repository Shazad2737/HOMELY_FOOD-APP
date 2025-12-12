import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template ordering_rules}
/// Business rules for ordering
/// {@endtemplate}
class OrderingRules extends Equatable {
  /// {@macro ordering_rules}
  const OrderingRules({
    required this.minAdvanceOrderDays,
    required this.maxAdvanceOrderDays,
    required this.advanceOrderCutoffHour,
    required this.currentHour,
    required this.canOrderToday,
  });

  /// Creates OrderingRules from JSON
  factory OrderingRules.fromJson(Map<String, dynamic> json) {
    return OrderingRules(
      minAdvanceOrderDays: pick(json, 'minAdvanceOrderDays').asIntOrThrow(),
      maxAdvanceOrderDays: pick(json, 'maxAdvanceOrderDays').asIntOrThrow(),
      advanceOrderCutoffHour:
          pick(json, 'advanceOrderCutoffHour').asIntOrThrow(),
      currentHour: pick(json, 'currentHour').asIntOrThrow(),
      canOrderToday: pick(json, 'canOrderToday').asBoolOrThrow(),
    );
  }

  /// Minimum advance order days required
  final int minAdvanceOrderDays;

  /// Maximum advance order days allowed
  final int maxAdvanceOrderDays;

  /// Cutoff hour for advance orders
  final int advanceOrderCutoffHour;

  /// Current hour (server time)
  final int currentHour;

  /// Whether orders can be placed for today
  final bool canOrderToday;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'minAdvanceOrderDays': minAdvanceOrderDays,
      'maxAdvanceOrderDays': maxAdvanceOrderDays,
      'advanceOrderCutoffHour': advanceOrderCutoffHour,
      'currentHour': currentHour,
      'canOrderToday': canOrderToday,
    };
  }

  @override
  List<Object?> get props => [
        minAdvanceOrderDays,
        maxAdvanceOrderDays,
        advanceOrderCutoffHour,
        currentHour,
        canOrderToday,
      ];
}
