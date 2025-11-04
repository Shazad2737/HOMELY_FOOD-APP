import 'package:equatable/equatable.dart';

/// {@template create_address_request}
/// Request body for POST /customer/addresses
/// {@endtemplate}
class CreateAddressRequest extends Equatable {
  /// {@macro create_address_request}
  const CreateAddressRequest({
    required this.type,
    required this.name,
    required this.locationId,
    required this.areaId,
    this.roomNumber,
    this.buildingName,
    this.zipCode,
    this.mobile,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.countryId,
  });

  /// Address type (e.g., 'HOME', 'WORK', 'OTHER')
  final String type;

  /// Address name/label
  final String name;

  /// Room number
  final String? roomNumber;

  /// Building name
  final String? buildingName;

  /// Zip/Postal code
  final String? zipCode;

  /// Contact mobile number
  final String? mobile;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Whether this is the default address
  final bool isDefault;

  /// Country ID (integer on backend)
  final String? countryId;

  /// Location/Emirate ID (integer on backend, required)
  final String locationId;

  /// Area ID (integer on backend, required)
  final String areaId;

  /// Converts to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      if (roomNumber != null && roomNumber!.isNotEmpty)
        'roomNumber': roomNumber,
      if (buildingName != null && buildingName!.isNotEmpty)
        'buildingName': buildingName,
      if (zipCode != null && zipCode!.isNotEmpty) 'zipCode': zipCode,
      if (mobile != null && mobile!.isNotEmpty) 'mobile': mobile,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
      if (countryId != null) 'countryId': countryId,
      'locationId': locationId,
      'areaId': areaId,
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
        isDefault,
        countryId,
        locationId,
        areaId,
      ];
}
