import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';

/// {@template auth_guard}
/// Authentication guard that handles route protection and redirects
/// based on the current authentication state.
/// {@endtemplate}
class AuthGuard extends AutoRouteGuard {
  /// {@macro auth_guard}
  AuthGuard({required this.authBloc}) {
    log('AuthGuard: Created for routing protection');
  }

  /// Auth bloc to check authentication state
  final AuthBloc authBloc;

  @override
  Future<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final state = authBloc.state;
    final routeName = resolver.route.name;

    log('AuthGuard: $routeName | Auth: ${state.runtimeType}');
    // Use the root router to check the current top route so we can make
    // idempotent decisions (avoid double navigation).
    final root = router.root as StackRouter;
    final topName = root.topRoute.name;

    switch (state) {
      case Authenticated():
        // User is authenticated - allow access to protected routes

        // If trying to access login, signup, otp or splash, redirect to main
        if (routeName == LoginRoute.name ||
            routeName == SplashRoute.name ||
            routeName == SignupRoute.name ||
            routeName == OtpRoute.name) {
          const target = MainShellRoute();
          if (topName != target.routeName) {
            log(
              'AuthGuard: Redirecting to ${target.routeName} from $routeName',
            );
            await root.replaceAll(<PageRouteInfo>[target]);
            resolver.next(false);
          } else {
            log('AuthGuard: Already on main shell');
            resolver.next();
          }
        } else {
          // Allow navigation to any other route (Dashboard, Sales, etc.)
          log('AuthGuard: Allowing navigation to $routeName');
          resolver.next();
        }

      case Unauthenticated():
        const target = LoginRoute();
        final isPublicRoute =
            routeName == LoginRoute.name ||
            routeName == SignupRoute.name ||
            routeName == DeliveryAddressRoute.name ||
            routeName == OtpRoute.name;
        print('---isPublicRoute: $isPublicRoute');
        if (!isPublicRoute) {
          if (topName != target.routeName) {
            log('AuthGuard: Replacing stack with login (unauthenticated)');
            await root.replaceAll(<PageRouteInfo>[target]);
            resolver.next(false);
          } else {
            print('---resolver.next()');
            resolver.next();
          }
        } else {
          log('AuthGuard: Allowing access to $routeName (unauthenticated)');
          print('---resolver.next()');
          resolver.next();
        }

      case AuthInitial():
      case AuthLoading():
        // Auth state is temporary and resolving - don't redirect, just allow current route
        log(
          'AuthGuard: Auth state resolving (${state.runtimeType}), allowing current route',
        );
        resolver.next();
    }
  }
}
