import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template drawer_item}
/// Model for a drawer menu item
/// {@endtemplate}
class DrawerItem {
  /// {@macro drawer_item}
  const DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });

  /// Icon for the menu item
  final IconData icon;

  /// Label for the menu item
  final String label;

  /// Callback when item is tapped
  final VoidCallback onTap;

  /// Whether this item is currently selected
  final bool isSelected;
}

/// {@template app_drawer}
/// Navigation drawer for the app with menu items
/// {@endtemplate}
class AppDrawer extends StatelessWidget {
  /// {@macro app_drawer}
  const AppDrawer({
    required this.items,
    this.currentRoute,
    this.onLogout,
    this.userName,
    this.userEmail,
    super.key,
  });

  /// List of drawer items
  final List<DrawerItem> items;

  /// Current active route
  final String? currentRoute;

  /// Callback for logout
  final VoidCallback? onLogout;

  /// User name to display in header
  final String? userName;

  /// User email to display in header
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _DrawerHeader(
              userName: userName,
              userEmail: userEmail,
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children:
                    items.map((item) => _DrawerMenuItem(item: item)).toList(),
              ),
            ),
            const Divider(height: 1),
            if (onLogout != null)
              _DrawerMenuItem(
                item: DrawerItem(
                  icon: Icons.logout,
                  label: 'Logout',
                  onTap: onLogout!,
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    this.userName,
    this.userEmail,
  });

  final String? userName;
  final String? userEmail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Panel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (userName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        userName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  const _DrawerMenuItem({
    required this.item,
  });

  final DrawerItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: item.isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w500,
            color: item.isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        selected: item.isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: item.onTap,
      ),
    );
  }
}
