import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/auth/delivery_address/bloc/delivery_address_bloc.dart';
import 'package:instamess_app/auth/models/auth_error_classifier.dart';
import 'package:instamess_app/auth/models/validation_error_groups.dart';
import 'package:instamess_app/auth/signup/bloc/signup_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';

@RoutePage()
class DeliveryAddressPage extends StatelessWidget {
  const DeliveryAddressPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DeliveryAddressBloc(
        cmsRepository: context.read<ICmsRepository>(),
        authFacade: context.read<IAuthFacade>(),
      )..add(DeliveryAddressLoadedEvent()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _MobileWidget(
            phone: context.read<SignupBloc>().state.phone.value,
          ),
        ),
      ),
    );
  }
}

class _MobileWidget extends StatelessWidget {
  const _MobileWidget({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                onPressed: () => context.router.maybePop(),
                icon: const Icon(Icons.arrow_back),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Text(
                'Delivery Address',
                style: context.tsTitleMedium18,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.appRed,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'We offer Best Food in the Word',
                          style: context.tsTitleMedium18.bold.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lorem ipsam lorem ipsam',
                          style: context.tsBodyMedium14.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _DeliveryAddressForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryAddressForm extends StatefulWidget {
  const _DeliveryAddressForm();

  @override
  State<_DeliveryAddressForm> createState() => _DeliveryAddressFormState();
}

class _DeliveryAddressFormState extends State<_DeliveryAddressForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeliveryAddressBloc, DeliveryAddressState>(
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location loading error banner
              if (state.locationLoadError != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Failed to load locations',
                              style: context.tsBodyMedium14.semiBold.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              state.locationLoadError!,
                              style: context.tsBodySmall12,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TextButton(
                        onPressed: () {
                          context.read<DeliveryAddressBloc>().add(
                            DeliveryAddressLoadedEvent(),
                          );
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: RequiredText(
                  'Location',
                  style: context.tsBodyMedium14,
                ),
              ),
              DropdownButtonFormField<String>(
                style: context.tsBodyMedium14.grey600,
                icon: RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    Icons.chevron_left,
                    color: state.isLoadingAreas
                        ? AppColors.grey400
                        : AppColors.grey600,
                  ),
                ),
                selectedItemBuilder: (context) {
                  return state.locations.map((location) {
                    return Text(
                      location.name ?? '',
                      style: context.tsBodyMedium14.semiBold,
                    );
                  }).toList();
                },
                decoration: const InputDecoration(
                  hintText: 'Select Location',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location ID (emirate) is required';
                  }
                  return null;
                },
                initialValue: state.locationId.isEmpty
                    ? null
                    : state.locationId,
                items: state.locations.map((location) {
                  return DropdownMenuItem(
                    value: location.id,
                    child: Text(location.name ?? 'Unknown'),
                  );
                }).toList(),
                onChanged: state.isLoadingLocations || state.hasLocationError
                    ? null
                    : (value) {
                        if (value != null) {
                          context.read<DeliveryAddressBloc>().add(
                            DeliveryAddressLocationChangedEvent(value),
                          );
                        }
                      },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: RequiredText(
                  'Area',
                  style: context.tsBodyMedium14,
                ),
              ),
              DropdownButtonFormField<String>(
                style: context.tsBodyMedium14.grey600,
                icon: RotatedBox(
                  quarterTurns: 3,
                  child: Icon(
                    Icons.chevron_left,
                    color: state.isLoadingAreas
                        ? AppColors.grey400
                        : AppColors.grey600,
                  ),
                ),
                selectedItemBuilder: (context) {
                  return state.areas.map((area) {
                    return Text(
                      area.name,
                      style: context.tsBodyMedium14.semiBold,
                    );
                  }).toList();
                },
                decoration: InputDecoration(
                  hintText: 'Select Area',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  errorText: state.areaLoadError,
                  suffixIcon: state.areaLoadError != null
                      ? IconButton(
                          icon: const Icon(Icons.refresh, size: 20),
                          onPressed: state.locationId.isNotEmpty
                              ? () {
                                  context.read<DeliveryAddressBloc>().add(
                                    DeliveryAddressLocationChangedEvent(
                                      state.locationId,
                                    ),
                                  );
                                }
                              : null,
                        )
                      : null,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Area ID is required';
                  }
                  return null;
                },
                initialValue: state.area.isEmpty ? null : state.area,
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
                          context.read<DeliveryAddressBloc>().add(
                            DeliveryAddressAreaChangedEvent(value),
                          );
                        }
                      },
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: RequiredText(
                  'Name',
                  style: context.tsBodyMedium14,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter Name',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                initialValue: state.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location name is required';
                  }
                  return null;
                },
                onChanged: (value) => context.read<DeliveryAddressBloc>().add(
                  DeliveryAddressNameChangedEvent(value),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Choose Delivery Type',
                  style: context.tsBodyMedium14,
                ),
              ),
              DropdownButtonFormField<String>(
                style: context.tsBodyMedium14.grey600,
                icon: const RotatedBox(
                  quarterTurns: 3,
                  child: Icon(Icons.chevron_left, color: AppColors.grey600),
                ),
                decoration: const InputDecoration(
                  hintText: 'Select Type',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                initialValue: state.deliveryType,
                items: const [
                  DropdownMenuItem(value: 'HOME', child: Text('Home')),
                  DropdownMenuItem(value: 'WORK', child: Text('Work')),
                  DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<DeliveryAddressBloc>().add(
                      DeliveryAddressDeliveryTypeChangedEvent(value),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Room Number',
                            style: context.tsBodyMedium14,
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Room Number',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          initialValue: state.roomNumber,
                          onChanged: (value) =>
                              context.read<DeliveryAddressBloc>().add(
                                DeliveryAddressRoomNumberChangedEvent(value),
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
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Building Name',
                            style: context.tsBodyMedium14,
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Building Name',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          initialValue: state.buildingName,
                          onChanged: (value) =>
                              context.read<DeliveryAddressBloc>().add(
                                DeliveryAddressBuildingNameChangedEvent(
                                  value,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Zip Code',
                            style: context.tsBodyMedium14,
                          ),
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            hintText: 'Enter Zip Code',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          initialValue: state.zipCode,
                          onChanged: (value) =>
                              context.read<DeliveryAddressBloc>().add(
                                DeliveryAddressZipCodeChangedEvent(value),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 8),
                child: Text(
                  'Phone Number',
                  style: context.tsBodyMedium14,
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Enter Number',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) {
                  // Mobile is optional, but when provided must match E.164-like pattern
                  if (value == null || value.trim().isEmpty) return null;
                  final pattern = RegExp(r'^\+?[1-9]\d{1,14}$');
                  if (!pattern.hasMatch(value.trim())) {
                    return 'Invalid mobile number format';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
                initialValue: state.phoneNumber,
                onChanged: (value) => context.read<DeliveryAddressBloc>().add(
                  DeliveryAddressPhoneNumberChangedEvent(value),
                ),
              ),
              const SizedBox(height: 32),
              BlocListener<DeliveryAddressBloc, DeliveryAddressState>(
                listenWhen: (previous, current) =>
                    previous.signupState != current.signupState,
                listener: (context, state) {
                  state.signupState.maybeMap(
                    orElse: () => null,
                    failure: (failure) {
                      // Check if it's a validation failure with errors
                      if (failure.failure is ApiValidationFailure) {
                        final validationFailure =
                            failure.failure as ApiValidationFailure;

                        // Group errors by domain using classifier
                        final errorGroups = AuthErrorClassifier.groupAuthErrors(
                          validationFailure.errors,
                        );

                        // If there are signup errors, show dialog and navigate back
                        if (errorGroups.hasSignupErrors) {
                          _showSignupErrorsDialog(context, errorGroups);
                        } else {
                          // Only delivery errors - show as snackbar
                          AppSnackbar.showErrorSnackbar(
                            context,
                            content: failure.failure.message,
                          );
                        }
                      } else {
                        // Non-validation error - show generic message
                        AppSnackbar.showErrorSnackbar(
                          context,
                          content: failure.failure.message,
                        );
                      }
                    },
                    success: (signupResponse) {
                      // Navigate to OTP screen on success
                      // Backend has sent OTP to user's phone
                      context.router.push(
                        OtpRoute(
                          phone: signupResponse.data.mobile,
                        ),
                      );
                    },
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: state.isSubmitting || state.hasLocationError
                        ? null
                        : () {
                            // Validate form
                            if (!_formKey.currentState!.validate()) {
                              AppSnackbar.showErrorSnackbar(
                                context,
                                content: 'Please fill all required fields',
                              );
                              return;
                            }

                            // Get signup data from SignupBloc
                            final signupState = context
                                .read<SignupBloc>()
                                .state;

                            // Call signup API with delivery address
                            context.read<DeliveryAddressBloc>().add(
                              DeliveryAddressSubmittedEvent(
                                name: signupState.name.value,
                                mobile: signupState.phone.value,
                                password: signupState.password.value,
                                confirmPassword:
                                    signupState.confirmPassword.value,
                              ),
                            );
                          },
                    text: state.isSubmitting
                        ? 'SIGNING UP...'
                        : 'SAVE LOCATION',
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  /// Shows a dialog listing signup validation errors
  /// and navigates back to signup screen when dismissed
  void _showSignupErrorsDialog(
    BuildContext context,
    ValidationErrorGroups errorGroups,
  ) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.error_outline,
          color: AppColors.error,
          size: 48,
        ),
        title: const Text('Please Fix Signup Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'There are issues with your signup information:',
            ),
            const SizedBox(height: 16),
            ...errorGroups.signupErrors.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      size: 20,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AuthErrorClassifier.formatError(entry.key, entry.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Close dialog
              Navigator.of(dialogContext).pop();

              // Navigate back to signup screen
              context.router.maybePop();

              // Optionally: Set errors in SignupBloc
              context.read<SignupBloc>().add(
                SignupServerValidationErrorsEvent(
                  errorGroups.signupErrors,
                ),
              );
            },
            child: const Text('GO BACK AND FIX'),
          ),
        ],
      ),
    );
  }
}
