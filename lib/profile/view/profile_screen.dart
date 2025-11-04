import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/profile/bloc/profile_bloc.dart';
import 'package:instamess_app/profile/bloc/profile_event.dart';
import 'package:instamess_app/profile/bloc/profile_state.dart';
import 'package:instamess_app/router/router.gr.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileBloc is provided at the app level (see app/view/bloc_providers.dart),
    // so the screen can directly use the existing instance.
    return const ProfileView();
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return state.profileState.map(
              initial: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              loading: (_) => const Center(
                child: CircularProgressIndicator(),
              ),
              success: (success) => _ProfileContent(
                profile: success.data,
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
              refreshing: (refreshing) => _ProfileContent(
                profile: refreshing.currentData,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.profile});

  final CustomerProfile profile;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileRefreshedEvent());
      },
      child: ListView(
        padding: const EdgeInsets.all(AppDims.screenPadding),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profile.profileUrl != null
                      ? NetworkImage(profile.profileUrl!)
                      : null,
                  child: profile.profileUrl == null
                      ? const Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: 44,
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  profile.name ?? 'N/A',
                  style: context.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  profile.mobile ?? 'N/A',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
                if (profile.email != null && profile.email!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    profile.email!,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                _Tile(
                  icon: Icons.person_outline,
                  title: 'My Profile',
                  onTap: () {
                    context.router.push(const ProfileDetailRoute());
                  },
                ),
                _Tile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () {
                    context.router.push(const OrdersRoute());
                  },
                ),
                _Tile(
                  icon: Icons.location_on_outlined,
                  title: 'Delivery Address',
                  onTap: () {
                    context.router.push(const AddressesRoute());
                  },
                ),
                const _Tile(icon: Icons.settings_outlined, title: 'Setting'),
              ],
            ),
          ),
          const Divider(height: 32),
          const _Tile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
          ),
          const _Tile(icon: Icons.help_outline, title: 'Help Center'),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Log Out',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.error,
              ),
            ),
            onTap: () {
              context.read<AuthBloc>().add(AuthLogOutRequestedEvent());
            },
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title, this.onTap});
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.grey700),
      title: Text(title, style: context.textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
