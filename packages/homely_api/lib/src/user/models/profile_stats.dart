import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template profile_stats}
/// Represents customer profile statistics
/// {@endtemplate}
class ProfileStats extends Equatable {
  /// {@macro profile_stats}
  const ProfileStats({
    required this.totalOrders,
    required this.activeSubscriptions,
    required this.savedAddresses,
  });

  /// Creates ProfileStats from JSON
  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      totalOrders: pick(json, 'totalOrders').asIntOrNull(),
      activeSubscriptions: pick(json, 'activeSubscriptions').asIntOrNull(),
      savedAddresses: pick(json, 'savedAddresses').asIntOrNull(),
    );
  }

  /// Total number of orders placed
  final int? totalOrders;

  /// Number of active subscriptions
  final int? activeSubscriptions;

  /// Number of saved addresses
  final int? savedAddresses;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'totalOrders': totalOrders,
      'activeSubscriptions': activeSubscriptions,
      'savedAddresses': savedAddresses,
    };
  }

  @override
  List<Object?> get props => [totalOrders, activeSubscriptions, savedAddresses];
}
