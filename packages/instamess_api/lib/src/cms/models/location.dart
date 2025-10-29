import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template location}
/// Location model
/// {@endtemplate}
class Location extends Equatable {
  /// {@macro location}
  const Location({
    this.id,
    this.name,
    this.code,
    this.latitude,
    this.longitude,
    this.countryId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.roomNumber,
    this.type,
    this.buildingName,
    this.zipCode,
    this.mobile,
  });

  /// Creates a Location from Json map
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: pick(json, 'id').asStringOrNull(),
      name: pick(json, 'name').asStringOrNull(),
      code: pick(json, 'code').asStringOrNull(),
      latitude: pick(json, 'latitude').asStringOrNull(),
      longitude: pick(json, 'longitude').asStringOrNull(),
      countryId: pick(json, 'countryId').asStringOrNull(),
      isActive: pick(json, 'isActive').asBoolOrNull() ?? false,
      createdAt:
          DateTime.tryParse(pick(json, 'createdAt').asStringOrNull() ?? ''),
      updatedAt:
          DateTime.tryParse(pick(json, 'updatedAt').asStringOrNull() ?? ''),
      roomNumber: pick(json, 'roomNumber').asStringOrNull(),
      type: LocationType.values
          .where(
            (e) =>
                e.toString().split('.').last.toUpperCase() ==
                (pick(json, 'type').asStringOrNull() ?? '').toUpperCase(),
          )
          .firstOrNull,
      buildingName: pick(json, 'buildingName').asStringOrNull(),
      zipCode: pick(json, 'zipCode').asStringOrNull(),
      mobile: pick(json, 'mobile').asStringOrNull(),
    );
  }

  /// Converts Location to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'latitude': latitude,
      'longitude': longitude,
      'countryId': countryId,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Location id
  final String? id;

  /// Location name
  final String? name;

  /// Room number
  final String? roomNumber;

  /// Location type
  final LocationType? type;

  /// Building name
  final String? buildingName;

  /// Zip code
  final String? zipCode;

  /// Mobile number
  final String? mobile;

  /// Location code
  final String? code;

  /// Latitude
  final String? latitude;

  /// Longitude
  final String? longitude;

  /// Country id
  final String? countryId;

  /// Is active
  final bool? isActive;

  /// Created at
  final DateTime? createdAt;

  /// Updated at
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        latitude,
        longitude,
        countryId,
        isActive,
        createdAt,
        updatedAt,
      ];
}

enum LocationType {
  work,
  home,
  other,
}
