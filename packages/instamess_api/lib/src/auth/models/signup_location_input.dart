import 'package:equatable/equatable.dart';

/// {@template signup_location_input}
/// Location input for signup
/// {@endtemplate}
class SignupLocationInput extends Equatable {
  /// {@macro signup_location_input}
  const SignupLocationInput({
    required this.type,
    required this.name,
    required this.countryId,
    required this.locationId,
    required this.areaId,
    required this.isDefault,
    this.roomNumber,
    this.buildingName,
    this.zipCode,
    this.mobile,
    this.latitude,
    this.longitude,
  });

  /// Location type (HOME, WORK, OTHER)
  final String type;

  /// Location name
  final String name;

  /// Room number
  final String? roomNumber;

  /// Building name
  final String? buildingName;

  /// Zip code
  final String? zipCode;

  /// Mobile number
  final String? mobile;

  /// Latitude
  final String? latitude;

  /// Longitude
  final String? longitude;

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
      if (type.isNotEmpty) 'type': type,
      'name': name,
      if (roomNumber != null && roomNumber!.isNotEmpty)
        'roomNumber': roomNumber,
      if (buildingName != null && buildingName!.isNotEmpty)
        'buildingName': buildingName,
      if (zipCode != null && zipCode!.isNotEmpty) 'zipCode': zipCode,
      if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile,
      if (latitude != null && latitude!.isNotEmpty) 'latitude': latitude,
      if (longitude != null && longitude!.isNotEmpty) 'longitude': longitude,
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
