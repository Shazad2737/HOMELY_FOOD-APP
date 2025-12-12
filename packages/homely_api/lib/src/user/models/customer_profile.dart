import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:homely_api/src/user/models/customer_address.dart';
import 'package:homely_api/src/user/models/profile_stats.dart';

/// {@template customer_profile}
/// Represents a customer's complete profile with stats and default address
/// {@endtemplate}
class CustomerProfile extends Equatable {
  /// {@macro customer_profile}
  const CustomerProfile({
    required this.id,
    required this.name,
    required this.mobile,
    required this.customerCode,
    required this.stats,
    this.email,
    this.profileUrl,
    this.status,
    this.isVerified = false,
    this.defaultAddress,
  });

  /// Creates CustomerProfile from JSON
  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrNull(),
      mobile: pick(json, 'mobile').asStringOrNull(),
      customerCode: pick(json, 'customerCode').asStringOrNull(),
      email: pick(json, 'email').asStringOrNull(),
      profileUrl: pick(json, 'profileUrl').asStringOrNull(),
      status: pick(json, 'status').asStringOrNull(),
      isVerified: pick(json, 'isVerified').asBoolOrFalse(),
      defaultAddress: pick(json, 'defaultAddress').asMapOrNull() != null
          ? CustomerAddress.fromJson(
              pick(json, 'defaultAddress').asMapOrEmpty(),
            )
          : null,
      stats: ProfileStats.fromJson(
        pick(json, 'stats').asMapOrEmpty(),
      ),
    );
  }

  /// Customer ID
  final String? id;

  /// Customer name
  final String? name;

  /// Customer email
  final String? email;

  /// Customer mobile number
  final String? mobile;

  /// Profile picture URL
  final String? profileUrl;

  /// Customer code
  final String? customerCode;

  /// Customer account status
  final String? status;

  /// Whether customer is verified
  final bool isVerified;

  /// Default delivery address
  final CustomerAddress? defaultAddress;

  /// Customer statistics
  final ProfileStats stats;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'customerCode': customerCode,
      if (email != null) 'email': email,
      if (profileUrl != null) 'profileUrl': profileUrl,
      if (status != null) 'status': status,
      'isVerified': isVerified,
      if (defaultAddress != null) 'defaultAddress': defaultAddress!.toJson(),
      'stats': stats.toJson(),
    };
  }

  /// Creates a copy with updated fields
  CustomerProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? mobile,
    String? profileUrl,
    String? customerCode,
    String? status,
    bool? isVerified,
    CustomerAddress? defaultAddress,
    bool clearDefaultAddress = false,
    ProfileStats? stats,
  }) {
    return CustomerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      profileUrl: profileUrl ?? this.profileUrl,
      customerCode: customerCode ?? this.customerCode,
      status: status ?? this.status,
      isVerified: isVerified ?? this.isVerified,
      defaultAddress:
          clearDefaultAddress ? null : (defaultAddress ?? this.defaultAddress),
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        mobile,
        profileUrl,
        customerCode,
        status,
        isVerified,
        defaultAddress,
        stats,
      ];
}
