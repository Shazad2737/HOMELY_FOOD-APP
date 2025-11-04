import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template address_country}
/// Represents a country reference in an address
/// {@endtemplate}
class AddressCountry extends Equatable {
  /// {@macro address_country}
  const AddressCountry({
    required this.id,
    required this.name,
    required this.code,
  });

  /// Creates AddressCountry from JSON
  factory AddressCountry.fromJson(Map<String, dynamic> json) {
    return AddressCountry(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      code: pick(json, 'code').asStringOrThrow(),
    );
  }

  /// Country ID
  final String id;

  /// Country name
  final String name;

  /// Country code
  final String code;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  @override
  List<Object?> get props => [id, name, code];
}

/// {@template address_location}
/// Represents a location/emirate reference in an address
/// {@endtemplate}
class AddressLocation extends Equatable {
  /// {@macro address_location}
  const AddressLocation({
    required this.id,
    required this.name,
    required this.code,
  });

  /// Creates AddressLocation from JSON
  factory AddressLocation.fromJson(Map<String, dynamic> json) {
    return AddressLocation(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      code: pick(json, 'code').asStringOrThrow(),
    );
  }

  /// Location ID
  final String id;

  /// Location name
  final String name;

  /// Location code
  final String code;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  @override
  List<Object?> get props => [id, name, code];
}

/// {@template address_area}
/// Represents an area reference in an address
/// {@endtemplate}
class AddressArea extends Equatable {
  /// {@macro address_area}
  const AddressArea({
    required this.id,
    required this.name,
  });

  /// Creates AddressArea from JSON
  factory AddressArea.fromJson(Map<String, dynamic> json) {
    return AddressArea(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
    );
  }

  /// Area ID
  final String id;

  /// Area name
  final String name;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}

/// {@template customer_address}
/// Represents a customer's delivery address
/// {@endtemplate}
class CustomerAddress extends Equatable {
  /// {@macro customer_address}
  const CustomerAddress({
    required this.id,
    required this.type,
    required this.name,
    this.roomNumber,
    this.buildingName,
    this.zipCode,
    this.mobile,
    this.latitude,
    this.longitude,
    this.isDefault = false,
    this.country,
    this.location,
    this.area,
  });

  /// Creates CustomerAddress from JSON
  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: pick(json, 'id').asStringOrThrow(),
      type: pick(json, 'type').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      roomNumber: pick(json, 'roomNumber').asStringOrNull(),
      buildingName: pick(json, 'buildingName').asStringOrNull(),
      zipCode: pick(json, 'zipCode').asStringOrNull(),
      mobile: pick(json, 'mobile').asStringOrNull(),
      latitude: pick(json, 'latitude').asDoubleOrNull(),
      longitude: pick(json, 'longitude').asDoubleOrNull(),
      isDefault: pick(json, 'isDefault').asBoolOrFalse(),
      country: pick(json, 'country').asMapOrNull() != null
          ? AddressCountry.fromJson(pick(json, 'country').asMapOrThrow())
          : null,
      location: pick(json, 'location').asMapOrNull() != null
          ? AddressLocation.fromJson(pick(json, 'location').asMapOrThrow())
          : null,
      area: pick(json, 'area').asMapOrNull() != null
          ? AddressArea.fromJson(pick(json, 'area').asMapOrThrow())
          : null,
    );
  }

  /// Address ID
  final String id;

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

  /// Contact mobile number for this address
  final String? mobile;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Whether this is the default address
  final bool isDefault;

  /// Country reference
  final AddressCountry? country;

  /// Location/Emirate reference
  final AddressLocation? location;

  /// Area reference
  final AddressArea? area;

  /// Display name for UI
  String get displayName {
    final parts = <String>[name];
    if (buildingName != null && buildingName!.isNotEmpty) {
      parts.add(buildingName!);
    }
    if (area != null) {
      parts.add(area!.name);
    }
    return parts.join(', ');
  }

  /// Full address string for display
  String get fullAddress {
    final parts = <String>[];

    if (roomNumber != null && roomNumber!.isNotEmpty) {
      parts.add('Room $roomNumber');
    }
    if (buildingName != null && buildingName!.isNotEmpty) {
      parts.add(buildingName!);
    }
    parts.add(name);
    if (area != null) {
      parts.add(area!.name);
    }
    if (location != null) {
      parts.add(location!.name);
    }
    if (zipCode != null && zipCode!.isNotEmpty) {
      parts.add(zipCode!);
    }

    return parts.join(', ');
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      if (roomNumber != null) 'roomNumber': roomNumber,
      if (buildingName != null) 'buildingName': buildingName,
      if (zipCode != null) 'zipCode': zipCode,
      if (mobile != null) 'mobile': mobile,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'isDefault': isDefault,
      if (country != null) 'country': country!.toJson(),
      if (location != null) 'location': location!.toJson(),
      if (area != null) 'area': area!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        name,
        roomNumber,
        buildingName,
        zipCode,
        mobile,
        latitude,
        longitude,
        isDefault,
        country,
        location,
        area,
      ];
}
