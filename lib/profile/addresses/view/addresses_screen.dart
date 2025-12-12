import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_bloc.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_event.dart';
import 'package:homely_app/profile/addresses/bloc/addresses_state.dart';
import 'package:homely_app/router/router.gr.dart';

@RoutePage()
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    // Load addresses when screen is first displayed
    context.read<AddressesBloc>().add(const AddressesLoadedEvent());
  }

  @override
  Widget build(BuildContext context) {
    // AddressesBloc is provided at the app level (see app/view/bloc_providers.dart),
    // so the screen can directly use the existing instance.
    return const AddressesView();
  }
}

class AddressesView extends StatelessWidget {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Addresses'),
      ),
      body: SafeArea(
        child: BlocConsumer<AddressesBloc, AddressesState>(
          listenWhen: (previous, current) =>
              previous.deleteState != current.deleteState ||
              previous.setDefaultState != current.setDefaultState,
          listener: (context, state) {
            // Show success message when address is deleted
            state.deleteState.maybeMap(
              orElse: () {},
              success: (_) {
                AppSnackbar.showSuccessSnackbar(
                  context,
                  content: 'Address deleted successfully',
                );
              },
              failure: (failure) {
                AppSnackbar.showErrorSnackbar(
                  context,
                  content: failure.failure.message,
                );
              },
            );

            // Show success message when default is set
            state.setDefaultState.maybeMap(
              orElse: () {},
              success: (_) {
                AppSnackbar.showSuccessSnackbar(
                  context,
                  content: 'Default address updated',
                );
              },
              failure: (failure) {
                AppSnackbar.showErrorSnackbar(
                  context,
                  content: failure.failure.message,
                );
              },
            );
          },
          builder: (context, state) {
            return state.addressesState.map(
              initial: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              success: (success) => _AddressesList(
                addressesResponse: success.data,
                isOperationInProgress: state.isOperationInProgress,
              ),
              failure: (failure) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load addresses',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        failure.failure.message,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AddressesBloc>().add(
                          const AddressesLoadedEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              refreshing: (refreshing) => _AddressesList(
                addressesResponse: refreshing.currentData,
                isOperationInProgress: state.isOperationInProgress,
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.router.push(AddressFormRoute());
        },
        child: const Icon(Icons.add),
        // label: const Text('Add Address'),
      ),
    );
  }
}

class _AddressesList extends StatelessWidget {
  const _AddressesList({
    required this.addressesResponse,
    required this.isOperationInProgress,
  });

  final AddressesResponse addressesResponse;
  final bool isOperationInProgress;

  @override
  Widget build(BuildContext context) {
    if (addressesResponse.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'No addresses yet',
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your delivery address to get started',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AddressesBloc>().add(const AddressesRefreshedEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDims.screenPadding),
        itemCount: addressesResponse.addresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final address = addressesResponse.addresses[index];
          return _AddressCard(
            address: address,
            isOperationInProgress: isOperationInProgress,
          );
        },
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.isOperationInProgress,
  });

  final CustomerAddress address;
  final bool isOperationInProgress;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    address.type.toUpperCase(),
                    style: context.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'DEFAULT',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                PopupMenuButton<String>(
                  enabled: !isOperationInProgress,
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.router.push(
                          AddressFormRoute(address: address),
                        );
                      case 'default':
                        context.read<AddressesBloc>().add(
                          AddressSetDefaultEvent(address.id),
                        );
                      case 'delete':
                        _showDeleteConfirmation(context);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 20),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 12),
                            Text('Set as Default'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 20),
                          SizedBox(width: 12),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.displayName,
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              address.fullAddress,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.grey600,
              ),
            ),
            if (address.mobile != null && address.mobile!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: AppColors.grey600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    address.mobile!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text(
          'Are you sure you want to delete this address? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<AddressesBloc>().add(
                AddressDeletedEvent(address.id),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
