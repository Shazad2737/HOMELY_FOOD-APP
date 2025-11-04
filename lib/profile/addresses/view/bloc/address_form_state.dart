import 'package:equatable/equatable.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template address_form_state}
/// State for address form
/// {@endtemplate}
class AddressFormState extends Equatable {
  /// {@macro address_form_state}
  const AddressFormState({
    required this.type,
    required this.locationId,
    required this.areaId,
    required this.name,
    required this.roomNumber,
    required this.buildingName,
    required this.zipCode,
    required this.mobile,
    required this.isDefault,
    required this.locations,
    required this.areas,
    required this.isLoadingLocations,
    required this.isLoadingAreas,
    this.locationLoadError,
    this.areaLoadError,
  });

  /// Factory for initial state
  factory AddressFormState.initial() => const AddressFormState(
        type: 'HOME',
        locationId: '',
        areaId: '',
        name: '',
        roomNumber: '',
        buildingName: '',
        zipCode: '',
        mobile: '',
        isDefault: false,
        locations: [],
        areas: [],
        isLoadingLocations: false,
        isLoadingAreas: false,
      );

  /// Factory for editing state with existing address
  factory AddressFormState.fromAddress(CustomerAddress address) =>
      AddressFormState(
        type: address.type,
        locationId: address.location?.id ?? '',
        areaId: address.area?.id ?? '',
        name: address.name,
        roomNumber: address.roomNumber ?? '',
        buildingName: address.buildingName ?? '',
        zipCode: address.zipCode ?? '',
        mobile: address.mobile ?? '',
        isDefault: address.isDefault,
        locations: [],
        areas: [],
        isLoadingLocations: false,
        isLoadingAreas: false,
      );

  final String type;
  final String locationId;
  final String areaId;
  final String name;
  final String roomNumber;
  final String buildingName;
  final String zipCode;
  final String mobile;
  final bool isDefault;

  final List<Location> locations;
  final List<Area> areas;

  final bool isLoadingLocations;
  final bool isLoadingAreas;

  final String? locationLoadError;
  final String? areaLoadError;

  bool get hasLocationError => locationLoadError != null;
  bool get hasAreaError => areaLoadError != null;

  /// Creates a copy with updated fields
  AddressFormState copyWith({
    String? type,
    String? locationId,
    String? areaId,
    String? name,
    String? roomNumber,
    String? buildingName,
    String? zipCode,
    String? mobile,
    bool? isDefault,
    List<Location>? locations,
    List<Area>? areas,
    bool? isLoadingLocations,
    bool? isLoadingAreas,
    String? locationLoadError,
    String? areaLoadError,
    bool clearLocationError = false,
    bool clearAreaError = false,
    bool clearAreas = false,
  }) {
    return AddressFormState(
      type: type ?? this.type,
      locationId: locationId ?? this.locationId,
      areaId: areaId ?? this.areaId,
      name: name ?? this.name,
      roomNumber: roomNumber ?? this.roomNumber,
      buildingName: buildingName ?? this.buildingName,
      zipCode: zipCode ?? this.zipCode,
      mobile: mobile ?? this.mobile,
      isDefault: isDefault ?? this.isDefault,
      locations: locations ?? this.locations,
      areas: clearAreas ? [] : (areas ?? this.areas),
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      locationLoadError: clearLocationError
          ? null
          : (locationLoadError ?? this.locationLoadError),
      areaLoadError:
          clearAreaError ? null : (areaLoadError ?? this.areaLoadError),
    );
  }

  @override
  List<Object?> get props => [
        type,
        locationId,
        areaId,
        name,
        roomNumber,
        buildingName,
        zipCode,
        mobile,
        isDefault,
        locations,
        areas,
        isLoadingLocations,
        isLoadingAreas,
        locationLoadError,
        areaLoadError,
      ];
}
