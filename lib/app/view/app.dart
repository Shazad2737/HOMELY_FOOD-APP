import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart' as instamess_api;
import 'package:instamess_app/app/view/bloc_providers.dart';
import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/router/router.dart';

enum ReleaseMode {
  staging,
  production,
  development;

  String get label {
    switch (this) {
      case staging:
        return 'STG';
      case production:
        return 'PROD';
      case development:
        return 'DEV';
    }
  }
}

class App extends StatefulWidget {
  const App({
    required this.api,
    required this.releaseMode,
    super.key,
  });

  final instamess_api.IInstaMessApi api;

  final ReleaseMode releaseMode;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc(widget.api.authFacade, widget.api.sessionManager);
    appRouter = AppRouter(authBloc);
  }

  late final AuthBloc authBloc;

  late final AppRouter appRouter;

  @override
  void dispose() {
    authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final multiBlocProvider = MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => widget.api.cmsRepository,
        ),
        RepositoryProvider(
          create: (context) => widget.api.authFacade,
        ),
        RepositoryProvider(
          create: (context) => widget.api.menuRepository,
        ),
        RepositoryProvider(
          create: (context) => widget.api.notificationRepository,
        ),
        RepositoryProvider(
          create: (context) => widget.api.userRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: getBlocProviders(widget.api, authBloc),
        child: Builder(
          builder: (context) {
            return MaterialApp.router(
              theme: _theme,
              // theme: AppTheme.standard,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                if (child == null) {
                  return const SizedBox();
                }
                final childWithBanner = switch (widget.releaseMode) {
                  ReleaseMode.development || ReleaseMode.staging => Banner(
                    message: widget.releaseMode.label,
                    location: BannerLocation.topEnd,
                    child: child,
                  ),
                  ReleaseMode.production => child,
                };
                // wraps child in a banner if in development mode or staging
                return childWithBanner;
              },
              routerConfig: appRouter.config(
                rebuildStackOnDeepLink: true,
                navigatorObservers: () {
                  return [
                    RouteLogObserver(),
                    AutoRouteObserver(),
                  ];
                },

                // deepLinkBuilder: (PlatformDeepLink deeplink) {
                //   // Handle deep links based on auth state
                //   final authState = authBloc.state;
                //   switch (authState) {
                //     case Authenticated(:final selectedRole):
                //       // User is authenticated, go to their home route
                //       return DeepLink([selectedRole.homeRoute]);
                //     case Unauthenticated():
                //       // User is not authenticated, go to login
                //       return const DeepLink([LoginRoute()]);
                //     case AuthLoggedIn():
                //       // User logged in but no role selected, go to role selection
                //       return DeepLink([
                //         SelectRoleRoute(roles: authState.user.roles),
                //       ]);
                //     default:
                //       // Auth state unknown, go to login and let auth resolve
                //       return const DeepLink([LoginRoute()]);
                //   }
                // },
                reevaluateListenable: BlocToChangeNotifier<AuthBloc, AuthState>(
                  context.read<AuthBloc>(),
                ),
              ),
            );
          },
        ),
      ),
    );
    // Expose the API instance to the widget tree
    return multiBlocProvider;
  }

  ThemeData get _theme => AppTheme.standard;
}
