import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/cms/models/banner.dart';
import 'package:homely_api/src/subscription/models/subscription_contact.dart';
import 'package:homely_api/src/subscription/models/subscription_info.dart';

/// {@template subscription_data}
/// Complete subscription page data
/// {@endtemplate}
class SubscriptionData extends Equatable {
  /// {@macro subscription_data}
  const SubscriptionData({
    required this.contact,
    this.subscription,
    this.banner,
  });

  /// Creates SubscriptionData from JSON
  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      subscription: pick(json, 'subscription').letOrNull((pick) {
        return SubscriptionInfo.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      banner: pick(json, 'banner').letOrNull((pick) {
        return Banner.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      contact: SubscriptionContact.fromJson(
        pick(json, 'contact').asMapOrThrow<String, dynamic>(),
      ),
    );
  }

  /// Active subscription details (nullable - null means no subscription)
  final SubscriptionInfo? subscription;

  /// Promotional banner for subscription page (nullable)
  final Banner? banner;

  /// Contact information for support
  final SubscriptionContact contact;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      if (subscription != null) 'subscription': subscription!.toJson(),
      'banner': banner?.toJson(),
      'contact': contact.toJson(),
    };
  }

  /// Returns true if user has an active subscription
  bool get hasActiveSubscription =>
      subscription != null && subscription!.isActive;

  /// Returns list of subscribed meal type names
  List<String> get subscribedMealTypes {
    if (subscription == null) return [];
    return subscription!.mealTypes.map((m) => m.type).toList();
  }

  /// Returns true if user has any subscribed meals
  /// (used for backward compatibility with order form logic)
  bool get hasSubscribedMeals =>
      subscription != null &&
      subscription!.isActive &&
      subscription!.mealTypes.isNotEmpty;

  @override
  List<Object?> get props => [subscription, banner, contact];
}
