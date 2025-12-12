import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template area}
/// Area model representing a specific area within a location
/// {@endtemplate}
class Area extends Equatable {
  /// {@macro area}
  const Area({
    required this.id,
    required this.name,
    required this.locationId,
    this.latitude,
    this.longitude,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates an Area from Json map
  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      locationId: pick(json, 'locationId').asStringOrThrow(),
      latitude: pick(json, 'latitude').asStringOrNull(),
      longitude: pick(json, 'longitude').asStringOrNull(),
      isActive: pick(json, 'isActive').asBoolOrNull() ?? true,
      createdAt:
          DateTime.tryParse(pick(json, 'createdAt').asStringOrNull() ?? ''),
      updatedAt:
          DateTime.tryParse(pick(json, 'updatedAt').asStringOrNull() ?? ''),
    );
  }

  final String id;
  final String name;
  final String locationId;
  final String? latitude;
  final String? longitude;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Converts Area to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'locationId': locationId,
      'latitude': latitude,
      'longitude': longitude,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        locationId,
        latitude,
        longitude,
        isActive,
        createdAt,
        updatedAt,
      ];
}
