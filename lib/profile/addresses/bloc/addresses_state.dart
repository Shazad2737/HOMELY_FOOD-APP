import 'package:api_client/api_client.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/homely_api.dart';

/// {@template addresses_state}
/// State for addresses management
/// {@endtemplate}
class AddressesState extends Equatable {
  /// {@macro addresses_state}
  const AddressesState({
    required this.addressesState,
    this.createState = const DataStateInitial(),
    this.updateState = const DataStateInitial(),
    this.deleteState = const DataStateInitial(),
    this.setDefaultState = const DataStateInitial(),
  });

  /// Factory for initial state
  factory AddressesState.initial() => const AddressesState(
    addressesState: DataStateInitial(),
  );

  /// Addresses list data state
  final DataState<AddressesResponse> addressesState;

  /// Create address state
  final DataState<CustomerAddress> createState;

  /// Update address state
  final DataState<CustomerAddress> updateState;

  /// Delete address state
  final DataState<Unit> deleteState;

  /// Set default address state
  final DataState<CustomerAddress> setDefaultState;

  /// Whether addresses are loading
  bool get isLoading => addressesState.isLoading;

  /// Whether an address is being created
  bool get isCreating => createState.isLoading;

  /// Whether an address is being updated
  bool get isUpdating => updateState.isLoading;

  /// Whether an address is being deleted
  bool get isDeleting => deleteState.isLoading;

  /// Whether default is being set
  bool get isSettingDefault => setDefaultState.isLoading;

  /// Whether any operation is in progress
  bool get isOperationInProgress =>
      isCreating || isUpdating || isDeleting || isSettingDefault;

  /// Creates a copy with updated fields
  AddressesState copyWith({
    DataState<AddressesResponse>? addressesState,
    DataState<CustomerAddress>? createState,
    DataState<CustomerAddress>? updateState,
    DataState<Unit>? deleteState,
    DataState<CustomerAddress>? setDefaultState,
  }) {
    return AddressesState(
      addressesState: addressesState ?? this.addressesState,
      createState: createState ?? this.createState,
      updateState: updateState ?? this.updateState,
      deleteState: deleteState ?? this.deleteState,
      setDefaultState: setDefaultState ?? this.setDefaultState,
    );
  }

  @override
  List<Object?> get props => [
    addressesState,
    createState,
    updateState,
    deleteState,
    setDefaultState,
  ];
}
