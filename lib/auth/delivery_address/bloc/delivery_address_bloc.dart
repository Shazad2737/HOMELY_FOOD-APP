// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'delivery_address_event.dart';
part 'delivery_address_state.dart';

class DeliveryAddressBloc
    extends Bloc<DeliveryAddressEvent, DeliveryAddressState> {
  DeliveryAddressBloc({
    required this.cmsFacade,
    required this.authFacade,
  }) : super(DeliveryAddressState.initial()) {
    on<DeliveryAddressEvent>((event, emit) async {
      switch (event) {
        case DeliveryAddressLoadedEvent():
          await _onLoadedEvent(event, emit);
        case DeliveryAddressLocationChangedEvent():
          await _onLocationChangedEvent(event, emit);
        case DeliveryAddressAreaChangedEvent():
          _onAreaChangedEvent(event, emit);
        case DeliveryAddressNameChangedEvent():
          _onNameChangedEvent(event, emit);
        case DeliveryAddressDeliveryTypeChangedEvent():
          _onDeliveryTypeChangedEvent(event, emit);
        case DeliveryAddressMealTypeChangedEvent():
          _onMealTypeChangedEvent(event, emit);
        case DeliveryAddressRoomNumberChangedEvent():
          _onRoomNumberChangedEvent(event, emit);
        case DeliveryAddressBuildingNameChangedEvent():
          _onBuildingNameChangedEvent(event, emit);
        case DeliveryAddressZipCodeChangedEvent():
          _onZipCodeChangedEvent(event, emit);
        case DeliveryAddressCountryChangedEvent():
          _onCountryChangedEvent(event, emit);
        case DeliveryAddressPhoneNumberChangedEvent():
          _onPhoneNumberChangedEvent(event, emit);
        case _:
          break;
      }
    });
    on<DeliveryAddressSubmittedEvent>(_onSubmitEvent);
  }

  final ICmsRepository cmsFacade;
  final IAuthFacade authFacade;

  Future<void> _onLoadedEvent(
    DeliveryAddressLoadedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) async {
    emit(state.copyWith(isLoadingLocations: true));

    final result = await cmsFacade.getLocations();

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingLocations: false));
      },
      (locations) {
        emit(
          state.copyWith(
            locations: locations,
            isLoadingLocations: false,
          ),
        );
      },
    );
  }

  Future<void> _onLocationChangedEvent(
    DeliveryAddressLocationChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) async {
    emit(
      state.copyWith(
        locationId: event.locationId,
        area: '', // Reset area when location changes
        areas: [], // Clear areas list
        isLoadingAreas: true,
      ),
    );

    // Fetch areas for the selected location
    final result = await cmsFacade.getAreas(event.locationId);

    result.fold(
      (failure) {
        emit(state.copyWith(isLoadingAreas: false));
      },
      (areas) {
        emit(
          state.copyWith(
            areas: areas,
            isLoadingAreas: false,
          ),
        );
      },
    );
  }

  void _onAreaChangedEvent(
    DeliveryAddressAreaChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(area: event.area));
  }

  void _onNameChangedEvent(
    DeliveryAddressNameChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onDeliveryTypeChangedEvent(
    DeliveryAddressDeliveryTypeChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(deliveryType: event.deliveryType));
  }

  void _onMealTypeChangedEvent(
    DeliveryAddressMealTypeChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(mealType: event.mealType));
  }

  void _onRoomNumberChangedEvent(
    DeliveryAddressRoomNumberChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(roomNumber: event.roomNumber));
  }

  void _onBuildingNameChangedEvent(
    DeliveryAddressBuildingNameChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(buildingName: event.buildingName));
  }

  void _onZipCodeChangedEvent(
    DeliveryAddressZipCodeChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(zipCode: event.zipCode));
  }

  void _onCountryChangedEvent(
    DeliveryAddressCountryChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(country: event.country));
  }

  void _onPhoneNumberChangedEvent(
    DeliveryAddressPhoneNumberChangedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) {
    emit(state.copyWith(phoneNumber: event.phoneNumber));
  }

  Future<void> _onSubmitEvent(
    DeliveryAddressSubmittedEvent event,
    Emitter<DeliveryAddressState> emit,
  ) async {
    emit(
      state.copyWith(signupState: DataState.loading()),
    );

    // Create location input from form data
    final locationInput = SignupLocationInput(
      type: state.deliveryType,
      name: state.name,
      roomNumber: state.roomNumber,
      buildingName: state.buildingName,
      zipCode: state.zipCode,
      mobile: state.phoneNumber,
      latitude: '0.0', // TODO: Get from location service
      longitude: '0.0', // TODO: Get from location service
      countryId: 'default', // TODO: Get actual country ID
      locationId: state.locationId,
      areaId: state.area,
      isDefault: true,
    );

    // Call signup API - Backend will send OTP to user's phone
    final result = await authFacade.signUp(
      name: event.name,
      mobile: event.mobile,
      password: event.password,
      confirmPassword: event.confirmPassword,
      locations: [locationInput],
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            signupState: DataState.failure(failure),
          ),
        );
      },
      (user) {
        emit(
          state.copyWith(
            signupState: DataState.success(user),
          ),
        );
      },
    );
  }
}
