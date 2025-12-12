import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/auth/bloc/auth_bloc.dart';
import 'package:homely_app/router/router.gr.dart';

/// {@template auth_guard}
/// Authentication guard that handles route protection and redirects
/// based on the current authentication state and onboarding status.
/// {@endtemplate}
class AuthGuard extends AutoRouteGuard {
  /// {@macro auth_guard}
  AuthGuard({
    required this.authBloc,
    required this.onboardingRepository,
  }) {
    log('AuthGuard: Created for routing protection');
  }

  /// Auth bloc to check authentication state
  final AuthBloc authBloc;

  /// Repository to check onboarding completion status
  final IOnboardingRepository onboardingRepository;

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

    // Check if onboarding is completed
    final onboardingResult = await onboardingRepository
        .isOnboardingCompleted()
        .run();
    final onboardingCompleted = onboardingResult.match(
      () => false,
      (value) => value,
    );

    // If onboarding not completed, handle separately
    if (!onboardingCompleted) {
      // Allow access to OnboardingRoute and SplashRoute
      if (routeName == OnboardingRoute.name || routeName == SplashRoute.name) {
        log(
          'AuthGuard: Allowing access to $routeName (onboarding not completed)',
        );
        resolver.next();
        return;
      }
      // Redirect to onboarding from any other route
      log('AuthGuard: Onboarding not completed, redirecting to onboarding');
      const target = OnboardingRoute();
      if (topName != target.routeName) {
        await root.replaceAll(<PageRouteInfo>[target]);
        resolver.next(false);
      } else {
        resolver.next();
      }
      return;
    }

    // Onboarding is completed, proceed with auth checks
    switch (state) {
      case Authenticated():
        // User is authenticated - allow access to protected routes

        // If trying to access login, signup, otp, splash or onboarding, redirect to main
        if (routeName == LoginRoute.name ||
            routeName == SplashRoute.name ||
            routeName == SignupRoute.name ||
            routeName == OtpRoute.name ||
            routeName == OnboardingRoute.name) {
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
            routeName == OtpRoute.name ||
            routeName == SplashRoute.name ||
            routeName == OnboardingRoute.name;
        if (!isPublicRoute) {
          if (topName != target.routeName) {
            log('AuthGuard: Replacing stack with login (unauthenticated)');
            await root.replaceAll(<PageRouteInfo>[target]);
            resolver.next(false);
          } else {
            resolver.next();
          }
        } else {
          log('AuthGuard: Allowing access to $routeName (unauthenticated)');
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
