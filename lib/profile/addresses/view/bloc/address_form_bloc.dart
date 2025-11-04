import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/addresses/view/bloc/address_form_event.dart';
import 'package:instamess_app/profile/addresses/view/bloc/address_form_state.dart';

/// {@template address_form_bloc}
/// Business logic component for address form
/// {@endtemplate}
class AddressFormBloc extends Bloc<AddressFormEvent, AddressFormState> {
  /// {@macro address_form_bloc}
  AddressFormBloc({
    required ICmsRepository cmsRepository,
    this.address,
  }) : _cmsRepository = cmsRepository,
       super(
         address != null
             ? AddressFormState.fromAddress(address)
             : AddressFormState.initial(),
       ) {
    on<AddressFormLoadedEvent>(_onLoaded);
    on<AddressFormTypeChangedEvent>(_onTypeChanged);
    on<AddressFormLocationChangedEvent>(_onLocationChanged);
    on<AddressFormAreaChangedEvent>(_onAreaChanged);
    on<AddressFormNameChangedEvent>(_onNameChanged);
    on<AddressFormRoomNumberChangedEvent>(_onRoomNumberChanged);
    on<AddressFormBuildingNameChangedEvent>(_onBuildingNameChanged);
    on<AddressFormZipCodeChangedEvent>(_onZipCodeChanged);
    on<AddressFormMobileChangedEvent>(_onMobileChanged);
    on<AddressFormIsDefaultChangedEvent>(_onIsDefaultChanged);
  }

  final ICmsRepository _cmsRepository;

  /// Address being edited (null for new address)
  final CustomerAddress? address;

  /// Whether this is editing mode
  bool get isEditing => address != null;

  Future<void> _onLoaded(
    AddressFormLoadedEvent event,
    Emitter<AddressFormState> emit,
  ) async {
    log('AddressFormBloc: Loading locations');
    emit(state.copyWith(isLoadingLocations: true, clearLocationError: true));

    final result = await _cmsRepository.getLocations();

    result.fold(
      (failure) {
        log('AddressFormBloc: Failed to load locations - ${failure.message}');
        emit(
          state.copyWith(
            isLoadingLocations: false,
            locationLoadError: failure.message,
          ),
        );
      },
      (locations) {
        log('AddressFormBloc: Locations loaded successfully');
        emit(
          state.copyWith(
            locations: locations,
            isLoadingLocations: false,
            clearLocationError: true,
          ),
        );

        // If editing and has location ID, load areas
        if (isEditing && state.locationId.isNotEmpty) {
          add(AddressFormLocationChangedEvent(state.locationId));
        }
      },
    );
  }

  void _onTypeChanged(
    AddressFormTypeChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  Future<void> _onLocationChanged(
    AddressFormLocationChangedEvent event,
    Emitter<AddressFormState> emit,
  ) async {
    log('AddressFormBloc: Loading areas for location ${event.locationId}');
    emit(
      state.copyWith(
        locationId: event.locationId,
        areaId: '', // Clear selected area when location changes
        isLoadingAreas: true,
        clearAreas: true,
        clearAreaError: true,
      ),
    );

    final result = await _cmsRepository.getAreas(event.locationId);

    result.fold(
      (failure) {
        log('AddressFormBloc: Failed to load areas - ${failure.message}');
        emit(
          state.copyWith(
            isLoadingAreas: false,
            areaLoadError: failure.message,
          ),
        );
      },
      (areas) {
        log('AddressFormBloc: Areas loaded successfully');
        emit(
          state.copyWith(
            areas: areas,
            isLoadingAreas: false,
            clearAreaError: true,
          ),
        );
      },
    );
  }

  void _onAreaChanged(
    AddressFormAreaChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(areaId: event.areaId));
  }

  void _onNameChanged(
    AddressFormNameChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(name: event.name));
  }

  void _onRoomNumberChanged(
    AddressFormRoomNumberChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(roomNumber: event.roomNumber));
  }

  void _onBuildingNameChanged(
    AddressFormBuildingNameChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(buildingName: event.buildingName));
  }

  void _onZipCodeChanged(
    AddressFormZipCodeChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(zipCode: event.zipCode));
  }

  void _onMobileChanged(
    AddressFormMobileChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(mobile: event.mobile));
  }

  void _onIsDefaultChanged(
    AddressFormIsDefaultChangedEvent event,
    Emitter<AddressFormState> emit,
  ) {
    emit(state.copyWith(isDefault: event.isDefault));
  }
}
