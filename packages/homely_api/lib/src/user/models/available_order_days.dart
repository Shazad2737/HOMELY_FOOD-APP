import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/user/models/customer.dart';
import 'package:homely_api/src/user/models/delivery_location.dart';
import 'package:homely_api/src/user/models/order_day.dart';
import 'package:homely_api/src/user/models/ordering_rules.dart';
import 'package:homely_api/src/user/models/subscription.dart';

/// {@template available_order_days}
/// Complete response for available order days
/// {@endtemplate}
class AvailableOrderDays extends Equatable {
  /// {@macro available_order_days}
  const AvailableOrderDays({
    required this.customer,
    required this.subscription,
    required this.orderingRules,
    required this.days,
    required this.locations,
  });

  /// Creates AvailableOrderDays from JSON
  factory AvailableOrderDays.fromJson(Map<String, dynamic> json) {
    return AvailableOrderDays(
      customer: Customer.fromJson(
        pick(json, 'customer').asMapOrThrow<String, dynamic>(),
      ),
      subscription: Subscription.fromJson(
        pick(json, 'subscription').asMapOrThrow<String, dynamic>(),
      ),
      orderingRules: OrderingRules.fromJson(
        pick(json, 'orderingRules').asMapOrThrow<String, dynamic>(),
      ),
      days: pick(json, 'days').asListOrEmpty((pick) {
        return OrderDay.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      locations: pick(json, 'locations').asListOrEmpty((pick) {
        return DeliveryLocation.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Customer information
  final Customer customer;

  /// Subscription information
  final Subscription subscription;

  /// Ordering rules
  final OrderingRules orderingRules;

  /// List of available days
  final List<OrderDay> days;

  /// Available delivery locations
  final List<DeliveryLocation> locations;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'customer': customer.toJson(),
      'subscription': subscription.toJson(),
      'orderingRules': orderingRules.toJson(),
      'days': days.map((e) => e.toJson()).toList(),
      'locations': locations.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [customer, subscription, orderingRules, days, locations];
}
