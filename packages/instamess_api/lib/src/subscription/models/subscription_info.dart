import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/subscription/models/subscription_category.dart';
import 'package:instamess_api/src/subscription/models/subscription_meal_type.dart';
import 'package:instamess_api/src/subscription/models/subscription_plan.dart';

/// Subscription status enum
enum SubscriptionStatus {
  /// Active subscription
  active,

  /// Paused subscription
  paused,

  /// Expired subscription
  expired,

  /// Cancelled subscription
  cancelled,

  /// Unknown status
  unknown;

  /// Creates SubscriptionStatus from string
  static SubscriptionStatus fromString(String? value) {
    if (value == null) return SubscriptionStatus.unknown;
    return SubscriptionStatus.values.firstWhere(
      (e) => e.name.toUpperCase() == value.toUpperCase(),
      orElse: () => SubscriptionStatus.unknown,
    );
  }

  /// Returns display name
  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.paused:
        return 'Paused';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.unknown:
        return 'Unknown';
    }
  }

  /// Returns true if subscription is active
  bool get isActive => this == SubscriptionStatus.active;
}

/// {@template subscription_info}
/// Represents detailed subscription information
/// {@endtemplate}
class SubscriptionInfo extends Equatable {
  /// {@macro subscription_info}
  const SubscriptionInfo({
    required this.id,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.plan,
    required this.category,
    required this.mealTypes,
    this.notes,
  });

  /// Creates SubscriptionInfo from JSON
  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      id: pick(json, 'id').asStringOrThrow(),
      status: SubscriptionStatus.fromString(
        pick(json, 'status').asStringOrNull(),
      ),
      notes: pick(json, 'notes').asStringOrNull(),
      startDate: pick(json, 'startDate').asStringOrThrow(),
      endDate: pick(json, 'endDate').asStringOrThrow(),
      createdAt: pick(json, 'createdAt').asStringOrThrow(),
      plan: SubscriptionPlan.fromJson(
        pick(json, 'plan').asMapOrThrow<String, dynamic>(),
      ),
      category: SubscriptionCategory.fromJson(
        pick(json, 'category').asMapOrThrow<String, dynamic>(),
      ),
      mealTypes: pick(json, 'mealTypes').asListOrEmpty((pick) {
        return SubscriptionMealType.fromJson(
          pick.asMapOrThrow<String, dynamic>(),
        );
      }),
    );
  }

  /// Subscription unique ID
  final String id;

  /// Subscription status
  final SubscriptionStatus status;

  /// Subscription notes (nullable)
  final String? notes;

  /// Subscription start date (YYYY-MM-DD format)
  final String startDate;

  /// Subscription end date (YYYY-MM-DD format)
  final String endDate;

  /// Subscription creation date (YYYY-MM-DD format)
  final String createdAt;

  /// Subscription plan details
  final SubscriptionPlan plan;

  /// Subscription category details
  final SubscriptionCategory category;

  /// List of subscribed meal types
  final List<SubscriptionMealType> mealTypes;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name.toUpperCase(),
      if (notes != null) 'notes': notes,
      'startDate': startDate,
      'endDate': endDate,
      'createdAt': createdAt,
      'plan': plan.toJson(),
      'category': category.toJson(),
      'mealTypes': mealTypes.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns true if subscription is active
  bool get isActive => status.isActive;

  /// Formats date range for display (e.g., "03-December-2025 - 03-January-2026")
  String get formattedDateRange {
    return '$formattedStartDate - $formattedEndDate';
  }

  /// Formats start date for display (e.g., "03-Dec-2025")
  String get formattedStartDate {
    try {
      final start = DateTime.parse(startDate);
      return '${start.day.toString().padLeft(2, '0')}-${_monthNameShort(start.month)}-${start.year}';
    } catch (_) {
      return startDate;
    }
  }

  /// Formats end date for display (e.g., "03-Jan-2026")
  String get formattedEndDate {
    try {
      final end = DateTime.parse(endDate);
      return '${end.day.toString().padLeft(2, '0')}-${_monthNameShort(end.month)}-${end.year}';
    } catch (_) {
      return endDate;
    }
  }

  /// Returns remaining days in subscription
  int get remainingDays {
    try {
      final end = DateTime.parse(endDate);
      final now = DateTime.now();
      final difference = end.difference(now).inDays;
      return difference > 0 ? difference : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Returns meal type names joined as a string
  String get mealTypesDisplay {
    return mealTypes.map((m) => m.name).join(', ');
  }

  String _monthNameShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [
        id,
        status,
        notes,
        startDate,
        endDate,
        createdAt,
        plan,
        category,
        mealTypes,
      ];
}
