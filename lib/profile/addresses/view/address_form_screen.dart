import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart' hide Banner;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:homely_app/profile/addresses/view/banner/location_form_banner_cubit.dart';
import 'package:core/core.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_bloc.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_event.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_state.dart';
import 'package:homely_app/profile/addresses/view/bloc/address_form_bloc.dart';
import 'package:homely_app/profile/addresses/view/bloc/address_form_event.dart';
import 'package:homely_app/profile/addresses/view/bloc/address_form_state.dart';

@RoutePage()
class AddressFormScreen extends StatelessWidget {
  const AddressFormScreen({
    super.key,
    this.address,
  });

  /// Address to edit (null for creating new address)
  final CustomerAddress? address;

  bool get isEditing => address != null;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AddressFormBloc>(
          create: (context) => AddressFormBloc(
            cmsRepository: context.read<ICmsRepository>(),
            address: address,
          )..add(const AddressFormLoadedEvent()),
        ),
        BlocProvider<LocationFormBannerCubit>(
          create: (context) => LocationFormBannerCubit(
            cmsRepository: context.read<ICmsRepository>(),
          )..loadBanner(),
        ),
      ],
      child: MultiBlocListener(
        listeners: [
          // Listener for create operations
          BlocListener<AddressesBloc, AddressesState>(
            listenWhen: (previous, current) =>
                previous.createState != current.createState,
            listener: (context, state) {
              state.createState.maybeMap(
                orElse: () {},
                success: (_) {
                  AppSnackbar.showSuccessSnackbar(
                    context,
                    content: 'Address created successfully',
                  );
                  context.router.maybePop();
                },
                failure: (failure) {
                  AppSnackbar.showErrorSnackbar(
                    context,
                    content: failure.failure.message,
                  );
                },
              );
            },
          ),
          // Listener for update operations
          BlocListener<AddressesBloc, AddressesState>(
            listenWhen: (previous, current) =>
                previous.updateState != current.updateState,
            listener: (context, state) {
              state.updateState.maybeMap(
                orElse: () {},
                success: (_) {
                  AppSnackbar.showSuccessSnackbar(
                    context,
                    content: 'Address updated successfully',
                  );
                  context.router.maybePop();
                },
                failure: (failure) {
                  AppSnackbar.showErrorSnackbar(
                    context,
                    content: failure.failure.message,
                  );
                },
              );
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text(isEditing ? 'Edit Address' : 'Add Address'),
          ),
          body: SafeArea(
            child: AddressFormView(
              addressesBloc: context.read<AddressesBloc>(),
            ),
          ),
        ),
      ),
    );
  }
}

// Banner rendered inline via LocationFormBannerCubit

class AddressFormView extends StatefulWidget {
  const AddressFormView({required this.addressesBloc, super.key});

  final AddressesBloc addressesBloc;

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressesBloc, AddressesState>(
      builder: (context, addressesState) {
        final isSubmitting =
            addressesState.isCreating || addressesState.isUpdating;

        return BlocBuilder<AddressFormBloc, AddressFormState>(
          builder: (context, state) {
            if (state.isLoadingLocations) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.locationLoadError != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: 16),
                    const Text('Failed to load locations'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AddressFormBloc>().add(
                          const AddressFormLoadedEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppDims.screenPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Location form banner (optional)
                    BlocBuilder<LocationFormBannerCubit, DataState<Banner?>>(
                      builder: (context, bannerState) {
                        return bannerState.maybeMap(
                          orElse: () => const SizedBox.shrink(),
                          loading: (_) => const SizedBox(
                            height: 96,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          success: (s) {
                            final b = s.data;
                            if (b == null || b.images.isEmpty)
                              return const SizedBox.shrink();
                            final image = b.images.firstWhere(
                              (i) =>
                                  i.imageUrl != null && i.imageUrl!.isNotEmpty,
                              orElse: () => b.images.first,
                            );
                            if (image.imageUrl == null ||
                                image.imageUrl!.isEmpty)
                              return const SizedBox.shrink();
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: GestureDetector(
                                onTap: () async {
                                  final redirect = image.redirectUrl;
                                  if (redirect != null && redirect.isNotEmpty) {
                                    final uri = Uri.tryParse(redirect);
                                    if (uri != null) await launchUrl(uri);
                                  }
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 120,
                                    child: CachedNetworkImage(
                                      imageUrl: image.imageUrl!,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          Container(color: AppColors.grey100),
                                      errorWidget: (context, url, error) =>
                                          const ColoredBox(
                                            color: AppColors.grey100,
                                            child: Icon(Icons.broken_image),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Address Type
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: RequiredText(
                        'Address Type',
                        style: context.tsBodyMedium14,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: state.type,
                      style: context.tsBodyMedium14,
                      decoration: const InputDecoration(
                        hintText: 'Select Type',
                      ),
                      items: const [
                        DropdownMenuItem(value: 'HOME', child: Text('Home')),
                        DropdownMenuItem(value: 'WORK', child: Text('Work')),
                        DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          context.read<AddressFormBloc>().add(
                            AddressFormTypeChangedEvent(value),
                          );
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Type is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Location
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: RequiredText(
                        'Location',
                        style: context.tsBodyMedium14,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: state.locationId.isEmpty
                          ? null
                          : state.locationId,
                      decoration: InputDecoration(
                        hintText: 'Select Location',
                        hintStyle: context.tsBodySmall12,
                      ),
                      style: context.tsBodyMedium14,
                      items: state.locations.map((location) {
                        return DropdownMenuItem(
                          value: location.id,
                          child: Text(location.name ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: state.isLoadingAreas
                          ? null
                          : (value) {
                              if (value != null) {
                                context.read<AddressFormBloc>().add(
                                  AddressFormLocationChangedEvent(value),
                                );
                              }
                            },
                      validator: (value) =>
                          value == null ? 'Location is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Area
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: RequiredText(
                        'Area',
                        style: context.tsBodyMedium14,
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: state.areaId.isEmpty ? null : state.areaId,
                      style: context.tsBodyMedium14,
                      decoration: InputDecoration(
                        hintText: 'Select Area',
                        errorText: state.areaLoadError,
                      ),
                      items: state.areas.map((area) {
                        return DropdownMenuItem(
                          value: area.id,
                          child: Text(area.name),
                        );
                      }).toList(),
                      onChanged: state.isLoadingAreas
                          ? null
                          : (value) {
                              if (value != null) {
                                context.read<AddressFormBloc>().add(
                                  AddressFormAreaChangedEvent(value),
                                );
                              }
                            },
                      validator: (value) =>
                          value == null ? 'Area is required' : null,
                    ),
                    const SizedBox(height: 20),

                    // Name
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 8),
                      child: RequiredText(
                        'Address Name',
                        style: context.tsBodyMedium14,
                      ),
                    ),
                    TextFormField(
                      initialValue: state.name,
                      decoration: const InputDecoration(
                        hintText: 'e.g., My Home, Office',
                      ),
                      onChanged: (value) => context.read<AddressFormBloc>().add(
                        AddressFormNameChangedEvent(value),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Building and Room
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Building Name',
                                  style: context.tsBodyMedium14,
                                ),
                              ),
                              TextFormField(
                                initialValue: state.buildingName,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                ),
                                onChanged: (value) =>
                                    context.read<AddressFormBloc>().add(
                                      AddressFormBuildingNameChangedEvent(
                                        value,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Room Number',
                                  style: context.tsBodyMedium14,
                                ),
                              ),
                              TextFormField(
                                initialValue: state.roomNumber,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                ),
                                onChanged: (value) =>
                                    context.read<AddressFormBloc>().add(
                                      AddressFormRoomNumberChangedEvent(value),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Zip Code and Mobile
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Zip Code',
                                  style: context.tsBodyMedium14,
                                ),
                              ),
                              TextFormField(
                                initialValue: state.zipCode,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                ),
                                onChanged: (value) => context
                                    .read<AddressFormBloc>()
                                    .add(AddressFormZipCodeChangedEvent(value)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  bottom: 8,
                                ),
                                child: Text(
                                  'Mobile',
                                  style: context.tsBodyMedium14,
                                ),
                              ),
                              TextFormField(
                                initialValue: state.mobile,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  hintText: 'Optional',
                                ),
                                onChanged: (value) => context
                                    .read<AddressFormBloc>()
                                    .add(AddressFormMobileChangedEvent(value)),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return null;
                                  }
                                  final pattern = RegExp(r'^\+?[1-9]\d{1,14}$');
                                  if (!pattern.hasMatch(value.trim())) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Is Default
                    CheckboxListTile(
                      value: state.isDefault,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<AddressFormBloc>().add(
                            AddressFormIsDefaultChangedEvent(value),
                          );
                        }
                      },
                      title: const Text('Set as default address'),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryButton(
                        onPressed: isSubmitting || state.hasLocationError
                            ? null
                            : () {
                                if (!_formKey.currentState!.validate()) {
                                  AppSnackbar.showErrorSnackbar(
                                    context,
                                    content: 'Please fill all required fields',
                                  );
                                  return;
                                }

                                final addressFormBloc = context
                                    .read<AddressFormBloc>();

                                if (addressFormBloc.isEditing) {
                                  // Update existing address
                                  final request = UpdateAddressRequest(
                                    type: state.type,
                                    name: state.name,
                                    roomNumber: state.roomNumber.isEmpty
                                        ? null
                                        : state.roomNumber,
                                    buildingName: state.buildingName.isEmpty
                                        ? null
                                        : state.buildingName,
                                    zipCode: state.zipCode.isEmpty
                                        ? null
                                        : state.zipCode,
                                    mobile: state.mobile.isEmpty
                                        ? null
                                        : state.mobile,
                                    isDefault: state.isDefault,
                                    locationId: int.tryParse(state.locationId),
                                    areaId: int.tryParse(state.areaId),
                                  );

                                  widget.addressesBloc.add(
                                    AddressUpdatedEvent(
                                      addressFormBloc.address!.id,
                                      request,
                                    ),
                                  );
                                } else {
                                  // Create new address
                                  final request = CreateAddressRequest(
                                    type: state.type,
                                    name: state.name,
                                    roomNumber: state.roomNumber.isEmpty
                                        ? null
                                        : state.roomNumber,
                                    buildingName: state.buildingName.isEmpty
                                        ? null
                                        : state.buildingName,
                                    zipCode: state.zipCode.isEmpty
                                        ? null
                                        : state.zipCode,
                                    mobile: state.mobile.isEmpty
                                        ? null
                                        : state.mobile,
                                    isDefault: state.isDefault,
                                    locationId: state.locationId,
                                    areaId: state.areaId,
                                  );

                                  widget.addressesBloc.add(
                                    AddressCreatedEvent(request),
                                  );
                                }
                              },
                        text: isSubmitting
                            ? 'SAVING...'
                            : (context.read<AddressFormBloc>().isEditing
                                  ? 'UPDATE ADDRESS'
                                  : 'ADD ADDRESS'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
