import 'package:equatable/equatable.dart';

/// {@template update_address_request}
/// Request body for PATCH /customer/addresses/:addressId
/// All fields are optional for partial updates
/// {@endtemplate}
class UpdateAddressRequest extends Equatable {
  /// {@macro update_address_request}
  const UpdateAddressRequest({
    this.type,
    this.name,
    this.roomNumber,
    this.buildingName,
    this.zipCode,
    this.mobile,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.countryId,
    this.locationId,
    this.areaId,
  });

  /// Address type (e.g., 'HOME', 'WORK', 'OTHER')
  final String? type;

  /// Address name/label
  final String? name;

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
  final bool? isDefault;

  /// Country ID
  final int? countryId;

  /// Location/Emirate ID
  final int? locationId;

  /// Area ID
  final int? areaId;

  /// Converts to JSON for API request
  /// Only includes non-null fields for partial updates
  Map<String, dynamic> toJson() {
    return {
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (buildingName != null) 'buildingName': buildingName,
      if (zipCode != null) 'zipCode': zipCode,
      if (mobile != null) 'mobile': mobile,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (isDefault != null) 'isDefault': isDefault,
      if (countryId != null) 'countryId': countryId,
      if (locationId != null) 'locationId': locationId,
      if (areaId != null) 'areaId': areaId,
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
