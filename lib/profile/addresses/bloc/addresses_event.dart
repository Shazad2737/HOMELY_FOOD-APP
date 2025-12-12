import 'package:equatable/equatable.dart';
import 'package:homely_api/homely_api.dart';

/// {@template addresses_event}
/// Base class for all addresses events
/// {@endtemplate}
sealed class AddressesEvent extends Equatable {
  const AddressesEvent();

  @override
  List<Object?> get props => [];
}

/// {@template addresses_loaded_event}
/// Event to load addresses
/// {@endtemplate}
final class AddressesLoadedEvent extends AddressesEvent {
  const AddressesLoadedEvent();
}

/// {@template addresses_refreshed_event}
/// Event to refresh addresses
/// {@endtemplate}
final class AddressesRefreshedEvent extends AddressesEvent {
  const AddressesRefreshedEvent();
}

/// {@template address_created_event}
/// Event to create a new address
/// {@endtemplate}
final class AddressCreatedEvent extends AddressesEvent {
  const AddressCreatedEvent(this.request);

  /// Create address request
  final CreateAddressRequest request;

  @override
  List<Object?> get props => [request];
}

/// {@template address_updated_event}
/// Event to update an existing address
/// {@endtemplate}
final class AddressUpdatedEvent extends AddressesEvent {
  const AddressUpdatedEvent(this.addressId, this.request);

  /// ID of address to update
  final String addressId;

  /// Update address request
  final UpdateAddressRequest request;

  @override
  List<Object?> get props => [addressId, request];
}

/// {@template address_deleted_event}
/// Event to delete an address
/// {@endtemplate}
final class AddressDeletedEvent extends AddressesEvent {
  const AddressDeletedEvent(this.addressId);

  /// ID of address to delete
  final String addressId;

  @override
  List<Object?> get props => [addressId];
}

/// {@template address_set_default_event}
/// Event to set an address as default
/// {@endtemplate}
final class AddressSetDefaultEvent extends AddressesEvent {
  const AddressSetDefaultEvent(this.addressId);

  /// ID of address to set as default
  final String addressId;

  @override
  List<Object?> get props => [addressId];
}
