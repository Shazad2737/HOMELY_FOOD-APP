import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/profile/bloc/profile_bloc.dart';
import 'package:homely_app/profile/bloc/profile_event.dart';
import 'package:homely_app/profile/bloc/profile_state.dart';

@RoutePage()
class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SafeArea(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.profilePictureUpdateState !=
              current.profilePictureUpdateState,
          listener: (context, state) {
            state.profilePictureUpdateState.maybeMap(
              orElse: () {},
              success: (_) {
                AppSnackbar.showSuccessSnackbar(
                  context,
                  content: 'Profile picture updated successfully',
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
            return state.profileState.map(
              initial: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              success: (success) => _ProfileDetailContent(
                profile: success.data,
                isUploadingPicture: state.isUploadingPicture,
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
                      'Failed to load profile',
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      failure.failure.message,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(
                          const ProfileLoadedEvent(),
                        );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              refreshing: (refreshing) => _ProfileDetailContent(
                profile: refreshing.currentData,
                isUploadingPicture: state.isUploadingPicture,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileDetailContent extends StatelessWidget {
  const _ProfileDetailContent({
    required this.profile,
    required this.isUploadingPicture,
  });

  final CustomerProfile profile;
  final bool isUploadingPicture;

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();

    // Show options: Camera or Gallery
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,

      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    try {
      final image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // Convert XFile to MultipartFile
      final multipartFile = await xFileToMultiPartFile(
        file: image,
        name: 'profilePicture',
      );

      if (multipartFile == null) {
        if (context.mounted) {
          AppSnackbar.showErrorSnackbar(
            context,
            content: 'Failed to process image',
          );
        }
        return;
      }

      // Dispatch event to update profile picture
      if (context.mounted) {
        context.read<ProfileBloc>().add(
          ProfilePictureUpdatedEvent(multipartFile),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showErrorSnackbar(
          context,
          content: 'Failed to pick image: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDims.screenPadding),
      child: Column(
        children: [
          // Profile Picture Section
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppColors.primary,
                backgroundImage: profile.profileUrl != null
                    ? NetworkImage(profile.profileUrl!)
                    : null,
                child: profile.profileUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.white,
                        size: 60,
                      )
                    : null,
              ),
              if (isUploadingPicture)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: isUploadingPicture
                      ? null
                      : () => _pickAndUploadImage(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Profile Information Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Information',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Name',
                    value: profile.name ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Mobile',
                    value: profile.mobile ?? 'N/A',
                  ),
                  if (profile.email != null && profile.email!.isNotEmpty) ...[
                    const Divider(height: 24),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email!,
                    ),
                  ],
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'Customer Code',
                    value: profile.customerCode ?? 'N/A',
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.verified_outlined,
                    label: 'Status',
                    value: profile.isVerified ? 'Verified' : 'Not Verified',
                    valueColor: profile.isVerified
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Statistics Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'Total Orders',
                        value: '${profile.stats.totalOrders}',
                      ),
                      _StatItem(
                        icon: Icons.subscriptions_outlined,
                        label: 'Subscriptions',
                        value: '${profile.stats.activeSubscriptions}',
                      ),
                      _StatItem(
                        icon: Icons.location_on_outlined,
                        label: 'Addresses',
                        value: '${profile.stats.savedAddresses}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
