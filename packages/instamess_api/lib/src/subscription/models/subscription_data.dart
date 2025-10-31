import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/cms/models/banner.dart';
import 'package:instamess_api/src/subscription/models/meal_subscription.dart';
import 'package:instamess_api/src/subscription/models/subscription_contact.dart';

/// {@template subscription_data}
/// Complete subscription page data
/// {@endtemplate}
class SubscriptionData extends Equatable {
  /// {@macro subscription_data}
  const SubscriptionData({
    required this.mealSubscriptions,
    required this.contact,
    this.banner,
  });

  /// Creates SubscriptionData from JSON
  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      mealSubscriptions: pick(json, 'mealTypes').asListOrEmpty((pick) {
        return MealSubscription.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      banner: pick(json, 'banner').letOrNull((pick) {
        return Banner.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      contact: SubscriptionContact.fromJson(
        pick(json, 'contact').asMapOrThrow<String, dynamic>(),
      ),
    );
  }

  /// List of meal subscriptions with status
  final List<MealSubscription> mealSubscriptions;

  /// Promotional banner for subscription page (nullable)
  final Banner? banner;

  /// Contact information for support
  final SubscriptionContact contact;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'mealTypes': mealSubscriptions.map((e) => e.toJson()).toList(),
      'banner': banner?.toJson(),
      'contact': contact.toJson(),
    };
  }

  /// Returns only subscribed meals
  List<MealSubscription> get subscribedMeals {
    return mealSubscriptions.where((meal) => meal.isSubscribed).toList();
  }

  /// Returns available meals for subscription
  List<MealSubscription> get availableMeals {
    return mealSubscriptions.where((meal) => meal.isAvailable).toList();
  }

  @override
  List<Object?> get props => [mealSubscriptions, banner, contact];
}
