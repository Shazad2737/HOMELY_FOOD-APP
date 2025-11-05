import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/notifications/bloc/notifications_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';

/// {@template main_shell_page}
/// Main shell page that contains the drawer and nested routes
/// {@endtemplate}
@RoutePage()
class MainShellPage extends StatefulWidget {
  /// {@macro main_shell_page}
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register as lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister lifecycle observer to prevent memory leaks
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only refresh when app comes to foreground (resumed)
    if (state == AppLifecycleState.resumed) {
      // Use mounted check to prevent calling after disposal
      if (mounted) {
        // Trigger smart refresh (only fetches if data is stale)
        context.read<NotificationsBloc>().add(
          NotificationsSmartRefreshedEvent(),
        );
      }
    }
  }

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
