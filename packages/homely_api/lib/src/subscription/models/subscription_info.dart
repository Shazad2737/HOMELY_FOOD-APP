import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/subscription/models/subscription_category.dart';
import 'package:homely_api/src/subscription/models/subscription_meal_type.dart';
import 'package:homely_api/src/subscription/models/subscription_plan.dart';

/// Subscription status enum
enum SubscriptionStatus {
  /// Active subscription
  active,

  /// Expired subscription
  expired,

  /// Cancelled subscription
  cancelled,

  /// Subscription is assigned but not started/approved
  pending,

  /// Upcoming subscription
  upcoming,

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
      case SubscriptionStatus.pending:
        return 'Pending';
      case SubscriptionStatus.expired:
        return 'Expired';
      case SubscriptionStatus.cancelled:
        return 'Cancelled';
      case SubscriptionStatus.upcoming:
        return 'Upcoming';
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

  /// Returns true if subscription is currently active based on dates.
  ///
  /// Active means today is within [startDate, endDate] inclusive.
  bool get isActive => effectiveStatus == SubscriptionStatus.active;

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

  /// Returns the effective subscription status based on the API-provided status
  /// and the local date check.
  ///
  /// Business rules:
  /// - Subscription becomes Active on the Start Date
  /// - It stays active for the entire End Date
  /// - It becomes Expired the next day automatically
  SubscriptionStatus get effectiveStatus {
    // Non-active API statuses pass through unchanged
    if (!status.isActive) return status;

    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      final now = DateTime.now();

      // Normalize to date-only comparison (ignore time component)
      final todayDate = DateTime(now.year, now.month, now.day);
      final startDateOnly = DateTime(start.year, start.month, start.day);
      final endDateOnly = DateTime(end.year, end.month, end.day);

      if (todayDate.isBefore(startDateOnly)) {
        // Today is before start date → Upcoming
        return SubscriptionStatus.upcoming;
      } else if (todayDate.isAfter(endDateOnly)) {
        // Today is after end date → Expired
        return SubscriptionStatus.expired;
      } else {
        // Today is within [start, end] inclusive → Active
        return SubscriptionStatus.active;
      }
    } catch (_) {
      // Fallback to API status on parse errors
      return status;
    }
  }

  /// Returns a display name for the effective subscription status.
  ///
  /// This accounts for the local date check so the UI displays the correct
  /// status (e.g., "Upcoming" instead of "Active" if start date is in future).
  String get effectiveStatusDisplayName => effectiveStatus.displayName;

  /// Returns remaining days in subscription. Returns null if start date is in
  /// future or end date is invalid.
  int? get remainingDays {
    try {
      if (DateTime.parse(startDate).isAfter(DateTime.now()) ||
          endDate.isEmpty ||
          DateTime.parse(endDate).isBefore(DateTime.now())) {
        return null;
      }
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
