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
    this.buildingName,
    this.areaId,
    this.locationId,
    this.isDefault = false,
  });

  /// Creates DeliveryLocation from JSON
  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      type: pick(json, 'type').asStringOrThrow(),
      buildingName: pick(json, 'buildingName').asStringOrNull(),
      areaId: pick(json, 'areaId').asStringOrNull(),
      locationId: pick(json, 'locationId').asStringOrNull(),
      isDefault: pick(json, 'isDefault').asBoolOrFalse(),
    );
  }

  /// Location ID
  final String id;

  /// Location name
  final String name;

  /// Location type (e.g., "HOME", "OFFICE", "OTHER")
  final String type;

  /// Building name (optional)
  final String? buildingName;

  /// Area ID
  final String? areaId;

  /// Location ID reference
  final String? locationId;

  /// Whether this is the default location
  final bool isDefault;

  /// Display name for UI (includes building if available)
  String get displayName =>
      buildingName != null ? '$name - $buildingName' : name;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      if (buildingName != null) 'buildingName': buildingName,
      if (areaId != null) 'areaId': areaId,
      if (locationId != null) 'locationId': locationId,
      'isDefault': isDefault,
    };
  }

  @override
  List<Object?> get props =>
      [id, name, type, buildingName, areaId, locationId, isDefault];
}
