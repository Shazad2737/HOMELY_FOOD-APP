import 'package:equatable/equatable.dart';

/// {@template address_form_event}
/// Base class for all address form events
/// {@endtemplate}
sealed class AddressFormEvent extends Equatable {
  const AddressFormEvent();

  @override
  List<Object?> get props => [];
}

/// {@template address_form_loaded_event}
/// Event to load form data (locations)
/// {@endtemplate}
final class AddressFormLoadedEvent extends AddressFormEvent {
  const AddressFormLoadedEvent();
}

/// {@template address_form_type_changed_event}
/// Event when address type changes
/// {@endtemplate}
final class AddressFormTypeChangedEvent extends AddressFormEvent {
  const AddressFormTypeChangedEvent(this.type);

  final String type;

  @override
  List<Object?> get props => [type];
}

/// {@template address_form_location_changed_event}
/// Event when location is changed
/// {@endtemplate}
final class AddressFormLocationChangedEvent extends AddressFormEvent {
  const AddressFormLocationChangedEvent(this.locationId);

  final String locationId;

  @override
  List<Object?> get props => [locationId];
}

/// {@template address_form_area_changed_event}
/// Event when area is changed
/// {@endtemplate}
final class AddressFormAreaChangedEvent extends AddressFormEvent {
  const AddressFormAreaChangedEvent(this.areaId);

  final String areaId;

  @override
  List<Object?> get props => [areaId];
}

/// {@template address_form_name_changed_event}
/// Event when name is changed
/// {@endtemplate}
final class AddressFormNameChangedEvent extends AddressFormEvent {
  const AddressFormNameChangedEvent(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

/// {@template address_form_room_number_changed_event}
/// Event when room number is changed
/// {@endtemplate}
final class AddressFormRoomNumberChangedEvent extends AddressFormEvent {
  const AddressFormRoomNumberChangedEvent(this.roomNumber);

  final String roomNumber;

  @override
  List<Object?> get props => [roomNumber];
}

/// {@template address_form_building_name_changed_event}
/// Event when building name is changed
/// {@endtemplate}
final class AddressFormBuildingNameChangedEvent extends AddressFormEvent {
  const AddressFormBuildingNameChangedEvent(this.buildingName);

  final String buildingName;

  @override
  List<Object?> get props => [buildingName];
}

/// {@template address_form_zip_code_changed_event}
/// Event when zip code is changed
/// {@endtemplate}
final class AddressFormZipCodeChangedEvent extends AddressFormEvent {
  const AddressFormZipCodeChangedEvent(this.zipCode);

  final String zipCode;

  @override
  List<Object?> get props => [zipCode];
}

/// {@template address_form_mobile_changed_event}
/// Event when mobile is changed
/// {@endtemplate}
final class AddressFormMobileChangedEvent extends AddressFormEvent {
  const AddressFormMobileChangedEvent(this.mobile);

  final String mobile;

  @override
  List<Object?> get props => [mobile];
}

/// {@template address_form_is_default_changed_event}
/// Event when isDefault is changed
/// {@endtemplate}
final class AddressFormIsDefaultChangedEvent extends AddressFormEvent {
  const AddressFormIsDefaultChangedEvent(this.isDefault);

  final bool isDefault;

  @override
  List<Object?> get props => [isDefault];
}
