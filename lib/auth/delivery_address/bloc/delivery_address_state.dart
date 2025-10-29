part of 'delivery_address_bloc.dart';

@immutable
class DeliveryAddressState {
  const DeliveryAddressState({
    required this.locationId,
    required this.area,
    required this.name,
    required this.deliveryType,
    required this.mealType,
    required this.roomNumber,
    required this.buildingName,
    required this.zipCode,
    required this.country,
    required this.phoneNumber,
    required this.locations,
    required this.areas,
    required this.isLoadingLocations,
    required this.isLoadingAreas,
    required this.showErrorMessages,
    required this.signupState,
  });

  factory DeliveryAddressState.initial() {
    return DeliveryAddressState(
      locationId: '',
      area: '',
      name: '',
      deliveryType: 'Home',
      mealType: 'Breakfast',
      roomNumber: '',
      buildingName: '',
      zipCode: '',
      country: '',
      phoneNumber: '',
      locations: const [],
      areas: const [],
      isLoadingLocations: false,
      isLoadingAreas: false,
      showErrorMessages: false,
      signupState: DataState.initial(),
    );
  }

  final String locationId;
  final String area;
  final String name;
  final String deliveryType;
  final String mealType;
  final String roomNumber;
  final String buildingName;
  final String zipCode;
  final String country;
  final String phoneNumber;
  final List<Location> locations;
  final List<Area> areas;
  final bool isLoadingLocations;
  final bool isLoadingAreas;
  final bool showErrorMessages;
  final DataState<User> signupState;

  bool get isSubmitting => signupState.isLoading;

  DeliveryAddressState copyWith({
    String? locationId,
    String? area,
    String? name,
    String? deliveryType,
    String? mealType,
    String? roomNumber,
    String? buildingName,
    String? zipCode,
    String? country,
    String? phoneNumber,
    List<Location>? locations,
    List<Area>? areas,
    bool? isLoadingLocations,
    bool? isLoadingAreas,
    bool? showErrorMessages,
    DataState<User>? signupState,
  }) {
    return DeliveryAddressState(
      locationId: locationId ?? this.locationId,
      area: area ?? this.area,
      name: name ?? this.name,
      deliveryType: deliveryType ?? this.deliveryType,
      mealType: mealType ?? this.mealType,
      roomNumber: roomNumber ?? this.roomNumber,
      buildingName: buildingName ?? this.buildingName,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      locations: locations ?? this.locations,
      areas: areas ?? this.areas,
      isLoadingLocations: isLoadingLocations ?? this.isLoadingLocations,
      isLoadingAreas: isLoadingAreas ?? this.isLoadingAreas,
      showErrorMessages: showErrorMessages ?? this.showErrorMessages,
      signupState: signupState ?? this.signupState,
    );
  }

  @override
  String toString() =>
      '''
DeliveryAddressState {
locationId: $locationId,
area: $area,
name: $name,
deliveryType: $deliveryType,
mealType: $mealType,
roomNumber: $roomNumber,
buildingName: $buildingName,
zipCode: $zipCode,
country: $country,
phoneNumber: $phoneNumber,
locations: ${locations.length} items,
areas: ${areas.length} items,
isLoadingLocations: $isLoadingLocations,
isLoadingAreas: $isLoadingAreas,
isSubmitting: $isSubmitting,
showErrorMessages: $showErrorMessages,
signupState: $signupState
}
''';
}
