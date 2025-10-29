import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/router/guards/auth_guard.dart';
import 'package:instamess_app/router/router.gr.dart';

/// App router
///
/// This class is used to define the routes for the app
@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  /// Constructs an [AppRouter]
  AppRouter(this.authBloc) {
    log('AppRouter: Constructor called with AuthBloc state: ${authBloc.state}');
  }

  /// Auth bloc
  ///
  /// Used to check the authentication state of the user
  final AuthBloc authBloc;

  @override
  List<AutoRouteGuard> get guards {
    return [AuthGuard(authBloc: authBloc)];
  }

  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: SplashRoute.page,
      initial: true,
    ),
    AutoRoute(
      page: LoginRoute.page,
    ),
    AutoRoute(
      page: SignupRoute.page,
    ),
    AutoRoute(
      page: OtpRoute.page,
    ),
    AutoRoute(
      page: DeliveryAddressRoute.page,
    ),
    AutoRoute(
      page: MainShellRoute.page,
      children: [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
        ),
        AutoRoute(page: MenuRoute.page),
        AutoRoute(page: OrderFormRoute.page),
        AutoRoute(page: SubscriptionsRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),
  ];
}
