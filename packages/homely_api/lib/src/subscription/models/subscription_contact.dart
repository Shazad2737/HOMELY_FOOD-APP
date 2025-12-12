import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription_contact}
/// Contact information for subscription support
/// {@endtemplate}
class SubscriptionContact extends Equatable {
  /// {@macro subscription_contact}
  const SubscriptionContact({
    required this.whatsapp,
    required this.phone,
  });

  /// Creates SubscriptionContact from JSON
  factory SubscriptionContact.fromJson(Map<String, dynamic> json) {
    return SubscriptionContact(
      whatsapp: pick(json, 'whatsapp').asStringOrNull(),
      phone: pick(json, 'phone').asStringOrNull(),
    );
  }

  /// WhatsApp number with country code (e.g., "+971501234567")
  final String? whatsapp;

  /// Phone number with country code (e.g., "+971501234567")
  final String? phone;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'whatsapp': whatsapp,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [whatsapp, phone];
}
