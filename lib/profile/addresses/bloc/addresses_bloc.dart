import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_event.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_state.dart';

/// {@template addresses_bloc}
/// Business logic component for addresses management
/// {@endtemplate}
class AddressesBloc extends Bloc<AddressesEvent, AddressesState> {
  /// {@macro addresses_bloc}
  AddressesBloc({
    required IUserRepository userRepository,
  })  : _userRepository = userRepository,
        super(AddressesState.initial()) {
    on<AddressesLoadedEvent>(_onLoaded);
    on<AddressesRefreshedEvent>(_onRefreshed);
    on<AddressCreatedEvent>(_onAddressCreated);
    on<AddressUpdatedEvent>(_onAddressUpdated);
    on<AddressDeletedEvent>(_onAddressDeleted);
    on<AddressSetDefaultEvent>(_onAddressSetDefault);
  }

  final IUserRepository _userRepository;

  Future<void> _onLoaded(
    AddressesLoadedEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Loading addresses');
    emit(state.copyWith(addressesState: DataState.loading()));

    final result = await _userRepository.getAddresses();

    result.fold(
      (failure) {
        log('AddressesBloc: Failed to load addresses - ${failure.message}');
        emit(state.copyWith(addressesState: DataState.failure(failure)));
      },
      (addressesResponse) {
        log('AddressesBloc: Addresses loaded successfully');
        emit(
          state.copyWith(
            addressesState: DataState.success(addressesResponse),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshed(
    AddressesRefreshedEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Refreshing addresses');

    // If we have existing data, use refreshing state
    if (state.addressesState is DataStateSuccess<AddressesResponse>) {
      final currentAddresses =
          (state.addressesState as DataStateSuccess<AddressesResponse>).data;
      emit(
        state.copyWith(
          addressesState: DataState.refreshing(currentAddresses),
        ),
      );
    } else {
      emit(state.copyWith(addressesState: DataState.loading()));
    }

    final result = await _userRepository.getAddresses();

    result.fold(
      (failure) {
        log('AddressesBloc: Failed to refresh addresses - ${failure.message}');
        emit(state.copyWith(addressesState: DataState.failure(failure)));
      },
      (addressesResponse) {
        log('AddressesBloc: Addresses refreshed successfully');
        emit(
          state.copyWith(
            addressesState: DataState.success(addressesResponse),
          ),
        );
      },
    );
  }

  Future<void> _onAddressCreated(
    AddressCreatedEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Creating address');
    emit(state.copyWith(createState: DataState.loading()));

    final result = await _userRepository.createAddress(event.request);

    result.fold(
      (failure) {
        log('AddressesBloc: Failed to create address - ${failure.message}');
        emit(state.copyWith(createState: DataState.failure(failure)));
      },
      (address) {
        log('AddressesBloc: Address created successfully');
        emit(state.copyWith(createState: DataState.success(address)));

        // Reload addresses after successful creation
        add(const AddressesLoadedEvent());
      },
    );
  }

  Future<void> _onAddressUpdated(
    AddressUpdatedEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Updating address ${event.addressId}');
    emit(state.copyWith(updateState: DataState.loading()));

    final result = await _userRepository.updateAddress(
      event.addressId,
      event.request,
    );

    result.fold(
      (failure) {
        log('AddressesBloc: Failed to update address - ${failure.message}');
        emit(state.copyWith(updateState: DataState.failure(failure)));
      },
      (address) {
        log('AddressesBloc: Address updated successfully');
        emit(state.copyWith(updateState: DataState.success(address)));

        // Reload addresses after successful update
        add(const AddressesLoadedEvent());
      },
    );
  }

  Future<void> _onAddressDeleted(
    AddressDeletedEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Deleting address ${event.addressId}');
    emit(state.copyWith(deleteState: DataState.loading()));

    final result = await _userRepository.deleteAddress(event.addressId);

    result.fold(
      (failure) {
        log('AddressesBloc: Failed to delete address - ${failure.message}');
        emit(state.copyWith(deleteState: DataState.failure(failure)));
      },
      (unit) {
        log('AddressesBloc: Address deleted successfully');
        emit(state.copyWith(deleteState: DataState.success(unit)));

        // Reload addresses after successful deletion
        add(const AddressesLoadedEvent());
      },
    );
  }

  Future<void> _onAddressSetDefault(
    AddressSetDefaultEvent event,
    Emitter<AddressesState> emit,
  ) async {
    log('AddressesBloc: Setting default address ${event.addressId}');
    emit(state.copyWith(setDefaultState: DataState.loading()));

    final result = await _userRepository.setDefaultAddress(event.addressId);

    result.fold(
      (failure) {
        log(
          'AddressesBloc: Failed to set default address - ${failure.message}',
        );
        emit(state.copyWith(setDefaultState: DataState.failure(failure)));
      },
      (address) {
        log('AddressesBloc: Default address set successfully');
        emit(state.copyWith(setDefaultState: DataState.success(address)));

        // Reload addresses after setting default
        add(const AddressesLoadedEvent());
      },
    );
  }
}
