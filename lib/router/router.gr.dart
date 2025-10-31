// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i13;
import 'package:flutter/material.dart' as _i15;
import 'package:instamess_api/instamess_api.dart' as _i14;
import 'package:instamess_app/auth/delivery_address/view/delivery_address_screen.dart'
    as _i1;
import 'package:instamess_app/auth/login/view/login_screen.dart' as _i3;
import 'package:instamess_app/auth/login/view/otp_screen.dart' as _i8;
import 'package:instamess_app/auth/signup/view/signup_screen.dart' as _i10;
import 'package:instamess_app/home/view/home_screen.dart' as _i2;
import 'package:instamess_app/main_shell/view/main_shell_page.dart' as _i4;
import 'package:instamess_app/menu/view/menu_screen.dart' as _i5;
import 'package:instamess_app/order_form/view/order_form_screen.dart' as _i6;
import 'package:instamess_app/profile/orders/view/orders_screen.dart' as _i7;
import 'package:instamess_app/profile/view/profile_screen.dart' as _i9;
import 'package:instamess_app/splash/view/splash_page.dart' as _i11;
import 'package:instamess_app/subscriptions/view/subscriptions_screen.dart'
    as _i12;

/// generated route for
/// [_i1.DeliveryAddressPage]
class DeliveryAddressRoute extends _i13.PageRouteInfo<void> {
  const DeliveryAddressRoute({List<_i13.PageRouteInfo>? children})
    : super(DeliveryAddressRoute.name, initialChildren: children);

  static const String name = 'DeliveryAddressRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i1.DeliveryAddressPage();
    },
  );
}

/// generated route for
/// [_i2.HomeScreen]
class HomeRoute extends _i13.PageRouteInfo<void> {
  const HomeRoute({List<_i13.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i2.HomeScreen();
    },
  );
}

/// generated route for
/// [_i3.LoginPage]
class LoginRoute extends _i13.PageRouteInfo<void> {
  const LoginRoute({List<_i13.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i3.LoginPage();
    },
  );
}

/// generated route for
/// [_i4.MainShellPage]
class MainShellRoute extends _i13.PageRouteInfo<void> {
  const MainShellRoute({List<_i13.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i4.MainShellPage();
    },
  );
}

/// generated route for
/// [_i5.MenuScreen]
class MenuRoute extends _i13.PageRouteInfo<MenuRouteArgs> {
  MenuRoute({
    _i14.Category? category,
    _i15.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         MenuRoute.name,
         args: MenuRouteArgs(category: category, key: key),
         initialChildren: children,
       );

  static const String name = 'MenuRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MenuRouteArgs>(
        orElse: () => const MenuRouteArgs(),
      );
      return _i5.MenuScreen(category: args.category, key: args.key);
    },
  );
}

class MenuRouteArgs {
  const MenuRouteArgs({this.category, this.key});

  final _i14.Category? category;

  final _i15.Key? key;

  @override
  String toString() {
    return 'MenuRouteArgs{category: $category, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MenuRouteArgs) return false;
    return category == other.category && key == other.key;
  }

  @override
  int get hashCode => category.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i6.OrderFormScreen]
class OrderFormRoute extends _i13.PageRouteInfo<void> {
  const OrderFormRoute({List<_i13.PageRouteInfo>? children})
    : super(OrderFormRoute.name, initialChildren: children);

  static const String name = 'OrderFormRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i6.OrderFormScreen();
    },
  );
}

/// generated route for
/// [_i7.OrdersScreen]
class OrdersRoute extends _i13.PageRouteInfo<void> {
  const OrdersRoute({List<_i13.PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i7.OrdersScreen();
    },
  );
}

/// generated route for
/// [_i8.OtpPage]
class OtpRoute extends _i13.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String phone,
    _i15.Key? key,
    List<_i13.PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(phone: phone, key: key),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return _i8.OtpPage(phone: args.phone, key: args.key);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({required this.phone, this.key});

  final String phone;

  final _i15.Key? key;

  @override
  String toString() {
    return 'OtpRouteArgs{phone: $phone, key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return phone == other.phone && key == other.key;
  }

  @override
  int get hashCode => phone.hashCode ^ key.hashCode;
}

/// generated route for
/// [_i9.ProfileScreen]
class ProfileRoute extends _i13.PageRouteInfo<void> {
  const ProfileRoute({List<_i13.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i9.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i10.SignupPage]
class SignupRoute extends _i13.PageRouteInfo<void> {
  const SignupRoute({List<_i13.PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i10.SignupPage();
    },
  );
}

/// generated route for
/// [_i11.SplashPage]
class SplashRoute extends _i13.PageRouteInfo<void> {
  const SplashRoute({List<_i13.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i11.SplashPage();
    },
  );
}

/// generated route for
/// [_i12.SubscriptionsScreen]
class SubscriptionsRoute extends _i13.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i13.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i13.PageInfo page = _i13.PageInfo(
    name,
    builder: (data) {
      return const _i12.SubscriptionsScreen();
    },
  );
}
