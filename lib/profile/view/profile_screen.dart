import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDims.screenPadding),
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, color: AppColors.white, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Text('Katty Berry', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 4),
                  Text(
                    '+971 78900078',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _Tile(icon: Icons.person_outline, title: 'My Profile'),
            const _Tile(icon: Icons.receipt_long_outlined, title: 'My Orders'),
            const _Tile(
              icon: Icons.location_on_outlined,
              title: 'Delivery Address',
            ),
            const _Tile(icon: Icons.settings_outlined, title: 'Setting'),
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
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.grey700),
        title: Text(title, style: AppTextStyles.bodyLarge),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
