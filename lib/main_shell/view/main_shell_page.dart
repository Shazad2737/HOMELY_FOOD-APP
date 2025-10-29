import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:instamess_app/router/router.gr.dart';

/// {@template main_shell_page}
/// Main shell page that contains the drawer and nested routes
/// {@endtemplate}
@RoutePage()
class MainShellPage extends StatelessWidget {
  /// {@macro main_shell_page}
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainShellView();
  }
}

final List<PageRouteInfo<void>> _routes = [
  const HomeRoute(),
  MenuRoute(),
  const OrderFormRoute(),
  const SubscriptionsRoute(),
  const ProfileRoute(),
];

/// {@template main_shell_view}
/// View for the main shell page
/// {@endtemplate}
class MainShellView extends StatelessWidget {
  /// {@macro main_shell_view}
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: _routes,
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final index = tabsRouter.activeIndex;
        return Scaffold(
          body: child,
          bottomNavigationBar: FoodBottomNavBar(
            currentIndex: index,
            onTap: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }
}
