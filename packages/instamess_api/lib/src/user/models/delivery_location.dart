import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template delivery_location}
/// Represents a delivery location
/// {@endtemplate}
class DeliveryLocation extends Equatable {
  /// {@macro delivery_location}
  const DeliveryLocation({
    required this.id,
    required this.name,
    required this.type,
  });

  /// Creates DeliveryLocation from JSON
  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      type: pick(json, 'type').asStringOrThrow(),
    );
  }

  /// Location ID
  final String id;

  /// Location name
  final String name;

  /// Location type
  final String type;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
    };
  }

  @override
  List<Object?> get props => [id, name, type];
}
