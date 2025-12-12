import 'package:app_ui/app_ui.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

/// Bottom navigation bar styled for the food app
class FoodBottomNavBar extends StatelessWidget {
  const FoodBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return FlashyTabBar(
      selectedIndex: currentIndex,
      items: [
        // FlashyTabBarItem(
        //   icon: const Icon(
        //     SolarIconsOutline.home,
        //     key: ValueKey('home_outlined'),
        //   ),
        //   title: const Icon(SolarIconsBold.home, key: ValueKey('home_bold')),
        // ),
        _navItem(
          icon: SolarIconsOutline.home,
          boldIcon: SolarIconsBold.home,
        ),
        _navItem(
          icon: SolarIconsOutline.widget,
          boldIcon: SolarIconsBold.widget,
        ),
        _navItem(
          icon: SolarIconsOutline.documentText,
          boldIcon: SolarIconsBold.documentText,
        ),
        _navItem(
          icon: SolarIconsOutline.wallet,
          boldIcon: SolarIconsBold.wallet,
        ),
        _navItem(
          icon: SolarIconsOutline.user,
          boldIcon: SolarIconsBold.user,
        ),
      ],
      onItemSelected: onTap,
    );
  }
}

FlashyTabBarItem _navItem({
  required IconData icon,
  required IconData boldIcon,
}) {
  return FlashyTabBarItem(
    icon: Icon(
      icon,
      key: ValueKey('$icon'),
      color: AppColors.grey600,
    ),
    title: Icon(
      icon,
      color: AppColors.appRed,
      key: ValueKey('$boldIcon'),
    ),
    activeColor: AppColors.appRed,
    inactiveColor: AppColors.grey600,
  );
}
