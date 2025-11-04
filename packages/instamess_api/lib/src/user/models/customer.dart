import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template customer}
/// Represents a customer with their details
/// {@endtemplate}
class Customer extends Equatable {
  /// {@macro customer}
  const Customer({
    required this.id,
    required this.name,
    required this.mobile,
    required this.customerCode,
  });

  /// Creates Customer from JSON
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      mobile: pick(json, 'mobile').asStringOrThrow(),
      customerCode: pick(json, 'customerCode').asStringOrThrow(),
    );
  }

  /// Customer ID
  final String id;

  /// Customer name
  final String name;

  /// Customer mobile number
  final String mobile;

  /// Customer code
  final String customerCode;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'customerCode': customerCode,
    };
  }

  @override
  List<Object?> get props => [id, name, mobile, customerCode];
}
