part of 'delivery_address_bloc.dart';

@immutable
class DeliveryAddressState with FormzMixin {
  DeliveryAddressState({
    required this.signupState,
    RequiredString? locationId,
    RequiredString? area,
    Name? name,
    this.deliveryType = 'HOME',
    this.roomNumber = '',
    this.buildingName = '',
    this.zipCode = '',
    this.country = '',
    Phone? phone,
    List<Location>? locations,
    List<Area>? areas,
    this.isLoadingLocations = false,
    this.isLoadingAreas = false,
    this.showErrorMessages = false,
    this.locationLoadError,
    this.areaLoadError,
  }) : locationId = locationId ?? RequiredString.pure(),
       area = area ?? RequiredString.pure(),
       name = name ?? Name.pure(),
       phone = phone ?? Phone.pure(),
       locations = locations ?? const [],
       areas = areas ?? const [];

  factory DeliveryAddressState.initial() {
    return DeliveryAddressState(
      signupState: DataState.initial(),
    );
  }

  final RequiredString locationId;
  final RequiredString area;
  final Name name;
  final String deliveryType;
  final String roomNumber;
  final String buildingName;
  final String zipCode;
  final String country;
  final Phone phone;
  final List<Location> locations;
  final List<Area> areas;
  final bool isLoadingLocations;
  final bool isLoadingAreas;
  final bool showErrorMessages;
  final DataState<SignupResponse> signupState;
  final String? locationLoadError;
  final String? areaLoadError;

  bool get isSubmitting => signupState.isLoading;
  bool get hasLocationError => locationLoadError != null;

  @override
  List<FormzInput<dynamic, dynamic>> get inputs => [
    locationId,
    area,
    name,
  ];

  DeliveryAddressState copyWith({
    RequiredString? locationId,
    RequiredString? area,
    Name? name,
    String? deliveryType,
    String? roomNumber,
    String? buildingName,
    String? zipCode,
    String? country,
    Phone? phone,
    List<Location>? locations,
    List<Area>? areas,
    bool? isLoadingLocations,
    bool? isLoadingAreas,
    bool? showErrorMessages,
    DataState<SignupResponse>? signupState,
    String? Function()? locationLoadError,
    String? Function()? areaLoadError,
  }) {
    return DeliveryAddressState(
      locationId: locationId ?? this.locationId,
      area: area ?? this.area,
      name: name ?? this.name,
      deliveryType: deliveryType ?? this.deliveryType,
      roomNumber: roomNumber ?? this.roomNumber,
      buildingName: buildingName ?? this.buildingName,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      locations: locations ?? this.locations,
      areas: areas ?? this.areas,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      showErrorMessages: showErrorMessages ?? this.showErrorMessages,
      signupState: signupState ?? this.signupState,
      locationLoadError: locationLoadError != null
          ? locationLoadError()
          : this.locationLoadError,
      areaLoadError: areaLoadError != null
          ? areaLoadError()
          : this.areaLoadError,
    );
  }

  @override
  String toString() =>
      '''
DeliveryAddressState {
locationId: ${locationId.value},
area: ${area.value},
name: ${name.value},
deliveryType: $deliveryType,
roomNumber: $roomNumber,
buildingName: $buildingName,
zipCode: $zipCode,
country: $country,
phoneNumber: ${phone.value},
locations: ${locations.length} items,
areas: ${areas.length} items,
isLoadingLocations: $isLoadingLocations,
isLoadingAreas: $isLoadingAreas,
isSubmitting: $isSubmitting,
showErrorMessages: $showErrorMessages,

locationLoadError: $locationLoadError,
areaLoadError: $areaLoadError
}
''';
}
