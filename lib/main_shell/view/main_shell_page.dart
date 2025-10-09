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

/// {@template main_shell_view}
/// View for the main shell page
/// {@endtemplate}
class MainShellView extends StatelessWidget {
  /// {@macro main_shell_view}
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: const [
        HomeRoute(),
        MenuRoute(),
        ProfileRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        final index = tabsRouter.activeIndex;
        return Scaffold(
          // appBar: AppBar(
          //   title: Text(_getPageTitle(index)),
          //   centerTitle: false,
          //   actions: [
          //     IconButton(
          //       icon: const Icon(Icons.notifications_outlined),
          //       onPressed: () {},
          //     ),
          //     const SizedBox(width: 8),
          //   ],
          // ),
          body: child,
          bottomNavigationBar: FoodBottomNavBar(
            currentIndex: index,
            onTap: tabsRouter.setActiveIndex,
          ),
        );
      },
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return 'Home';
      case 1:
        return 'Menu';
      case 2:
        return 'Orders';
      case 3:
        return 'Account';
      default:
        return 'InstaMess';
    }
  }
}
