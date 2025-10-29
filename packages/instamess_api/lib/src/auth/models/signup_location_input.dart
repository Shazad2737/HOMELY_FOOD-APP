import 'package:equatable/equatable.dart';

/// {@template signup_location_input}
/// Location input for signup
/// {@endtemplate}
class SignupLocationInput extends Equatable {
  /// {@macro signup_location_input}
  const SignupLocationInput({
    required this.type,
    required this.name,
    required this.roomNumber,
    required this.buildingName,
    required this.zipCode,
    required this.mobile,
    required this.latitude,
    required this.longitude,
    required this.countryId,
    required this.locationId,
    required this.areaId,
    required this.isDefault,
  });

  /// Location type (HOME, WORK, OTHER)
  final String type;

  /// Location name
  final String name;

  /// Room number
  final String roomNumber;

  /// Building name
  final String buildingName;

  /// Zip code
  final String zipCode;

  /// Mobile number
  final String mobile;

  /// Latitude
  final String latitude;

  /// Longitude
  final String longitude;

  /// Country ID
  final String countryId;

  /// Location ID
  final String locationId;

  /// Area ID
  final String areaId;

  /// Is default location
  final bool isDefault;

  /// Converts to JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'roomNumber': roomNumber,
      'buildingName': buildingName,
      'zipCode': zipCode,
      'mobile': mobile,
      'latitude': latitude,
      'longitude': longitude,
      'countryId': countryId,
      'locationId': locationId,
      'areaId': areaId,
      'isDefault': isDefault,
    };
  }

  @override
  List<Object?> get props => [
        type,
        name,
        roomNumber,
        buildingName,
        zipCode,
        mobile,
        latitude,
        longitude,
        countryId,
        locationId,
        areaId,
        isDefault,
      ];
}
