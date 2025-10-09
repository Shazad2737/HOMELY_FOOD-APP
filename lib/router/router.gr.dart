// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter/material.dart' as _i10;
import 'package:instamess_app/auth/login/view/login_screen.dart' as _i2;
import 'package:instamess_app/auth/login/view/otp_screen.dart' as _i5;
import 'package:instamess_app/auth/login/view/signup_screen.dart' as _i7;
import 'package:instamess_app/home/view/home_screen.dart' as _i1;
import 'package:instamess_app/main_shell/view/main_shell_page.dart' as _i3;
import 'package:instamess_app/menu/view/menu_screen.dart' as _i4;
import 'package:instamess_app/profile/view/profile_screen.dart' as _i6;
import 'package:instamess_app/splash/view/splash_page.dart' as _i8;

/// generated route for
/// [_i1.HomeScreen]
class HomeRoute extends _i9.PageRouteInfo<void> {
  const HomeRoute({List<_i9.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.HomeScreen();
    },
  );
}

/// generated route for
/// [_i2.LoginPage]
class LoginRoute extends _i9.PageRouteInfo<void> {
  const LoginRoute({List<_i9.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.LoginPage();
    },
  );
}

/// generated route for
/// [_i3.MainShellPage]
class MainShellRoute extends _i9.PageRouteInfo<void> {
  const MainShellRoute({List<_i9.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.MainShellPage();
    },
  );
}

/// generated route for
/// [_i4.MenuScreen]
class MenuRoute extends _i9.PageRouteInfo<void> {
  const MenuRoute({List<_i9.PageRouteInfo>? children})
    : super(MenuRoute.name, initialChildren: children);

  static const String name = 'MenuRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i4.MenuScreen();
    },
  );
}

/// generated route for
/// [_i5.OtpPage]
class OtpRoute extends _i9.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String phone,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(phone: phone, key: key),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return _i5.OtpPage(phone: args.phone, key: args.key);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({required this.phone, this.key});

  final String phone;

  final _i10.Key? key;

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
/// [_i6.ProfileScreen]
class ProfileRoute extends _i9.PageRouteInfo<void> {
  const ProfileRoute({List<_i9.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i7.SignupPage]
class SignupRoute extends _i9.PageRouteInfo<void> {
  const SignupRoute({List<_i9.PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i7.SignupPage();
    },
  );
}

/// generated route for
/// [_i8.SplashPage]
class SplashRoute extends _i9.PageRouteInfo<void> {
  const SplashRoute({List<_i9.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i8.SplashPage();
    },
  );
}
