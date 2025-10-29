part of 'delivery_address_bloc.dart';

@immutable
sealed class DeliveryAddressEvent {}

class DeliveryAddressLoadedEvent extends DeliveryAddressEvent {}

class DeliveryAddressLocationChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressLocationChangedEvent(this.locationId);

  final String locationId;
}

class DeliveryAddressAreaChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressAreaChangedEvent(this.area);

  final String area;
}

class DeliveryAddressNameChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressNameChangedEvent(this.name);

  final String name;
}

class DeliveryAddressDeliveryTypeChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressDeliveryTypeChangedEvent(this.deliveryType);

  final String deliveryType;
}

class DeliveryAddressMealTypeChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressMealTypeChangedEvent(this.mealType);

  final String mealType;
}

class DeliveryAddressRoomNumberChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressRoomNumberChangedEvent(this.roomNumber);

  final String roomNumber;
}

class DeliveryAddressBuildingNameChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressBuildingNameChangedEvent(this.buildingName);

  final String buildingName;
}

class DeliveryAddressZipCodeChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressZipCodeChangedEvent(this.zipCode);

  final String zipCode;
}

class DeliveryAddressCountryChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressCountryChangedEvent(this.country);

  final String country;
}

class DeliveryAddressPhoneNumberChangedEvent extends DeliveryAddressEvent {
  DeliveryAddressPhoneNumberChangedEvent(this.phoneNumber);

  final String phoneNumber;
}

class DeliveryAddressSubmittedEvent extends DeliveryAddressEvent {
  DeliveryAddressSubmittedEvent({
    required this.name,
    required this.mobile,
    required this.password,
    required this.confirmPassword,
  });

  final String name;
  final String mobile;
  final String password;
  final String confirmPassword;
}
