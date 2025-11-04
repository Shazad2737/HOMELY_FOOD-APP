import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/user/models/customer_address.dart';

/// {@template addresses_response}
/// Response from GET /customer/addresses endpoint
/// {@endtemplate}
class AddressesResponse extends Equatable {
  /// {@macro addresses_response}
  const AddressesResponse({
    required this.addresses,
    required this.total,
    this.defaultAddressId,
  });

  /// Creates AddressesResponse from JSON
  factory AddressesResponse.fromJson(Map<String, dynamic> json) {
    final addressesList = pick(json, 'addresses').asListOrEmpty<Map<String, dynamic>>(
      (p0) => p0.asMapOrThrow(),
    );

    return AddressesResponse(
      addresses: addressesList
          .map((addressJson) => CustomerAddress.fromJson(addressJson))
          .toList(),
      total: pick(json, 'total').asIntOrThrow(),
      defaultAddressId: pick(json, 'defaultAddress').asStringOrNull(),
    );
  }

  /// List of customer addresses
  final List<CustomerAddress> addresses;

  /// Total number of addresses
  final int total;

  /// ID of the default address
  final String? defaultAddressId;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'addresses': addresses.map((a) => a.toJson()).toList(),
      'total': total,
      if (defaultAddressId != null) 'defaultAddress': defaultAddressId,
    };
  }

  @override
  List<Object?> get props => [addresses, total, defaultAddressId];
}
