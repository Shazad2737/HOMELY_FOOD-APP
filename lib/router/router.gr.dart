// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i20;
import 'package:flutter/material.dart' as _i21;
import 'package:homely_api/homely_api.dart' as _i22;
import 'package:homely_app/auth/delivery_address/view/delivery_address_screen.dart'
    as _i3;
import 'package:homely_app/auth/forgot_password/view/forgot_password_screen.dart'
    as _i4;
import 'package:homely_app/auth/login/view/login_screen.dart' as _i6;
import 'package:homely_app/auth/login/view/otp_screen.dart' as _i13;
import 'package:homely_app/auth/signup/view/signup_screen.dart' as _i16;
import 'package:homely_app/home/view/home_screen.dart' as _i5;
import 'package:homely_app/main_shell/view/main_shell_page.dart' as _i7;
import 'package:homely_app/menu/view/menu_screen.dart' as _i8;
import 'package:homely_app/notifications/view/notifications_screen.dart' as _i9;
import 'package:homely_app/onboarding/view/onboarding_page.dart' as _i10;
import 'package:homely_app/order_form/view/order_form_screen.dart' as _i11;
import 'package:homely_app/profile/addresses/view/address_form_screen.dart'
    as _i1;
import 'package:homely_app/profile/addresses/view/addresses_screen.dart' as _i2;
import 'package:homely_app/profile/orders/view/orders_screen.dart' as _i12;
import 'package:homely_app/profile/terms/terms_and_conditions_screen.dart'
    as _i19;
import 'package:homely_app/profile/view/profile_detail_screen.dart' as _i14;
import 'package:homely_app/profile/view/profile_screen.dart' as _i15;
import 'package:homely_app/splash/view/splash_page.dart' as _i17;
import 'package:homely_app/subscriptions/view/subscriptions_screen.dart'
    as _i18;

/// generated route for
/// [_i1.AddressFormScreen]
class AddressFormRoute extends _i20.PageRouteInfo<AddressFormRouteArgs> {
  AddressFormRoute({
    _i21.Key? key,
    _i22.CustomerAddress? address,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         AddressFormRoute.name,
         args: AddressFormRouteArgs(key: key, address: address),
         initialChildren: children,
       );

  static const String name = 'AddressFormRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AddressFormRouteArgs>(
        orElse: () => const AddressFormRouteArgs(),
      );
      return _i1.AddressFormScreen(key: args.key, address: args.address);
    },
  );
}

class AddressFormRouteArgs {
  const AddressFormRouteArgs({this.key, this.address});

  final _i21.Key? key;

  final _i22.CustomerAddress? address;

  @override
  String toString() {
    return 'AddressFormRouteArgs{key: $key, address: $address}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AddressFormRouteArgs) return false;
    return key == other.key && address == other.address;
  }

  @override
  int get hashCode => key.hashCode ^ address.hashCode;
}

/// generated route for
/// [_i2.AddressesScreen]
class AddressesRoute extends _i20.PageRouteInfo<void> {
  const AddressesRoute({List<_i20.PageRouteInfo>? children})
    : super(AddressesRoute.name, initialChildren: children);

  static const String name = 'AddressesRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i2.AddressesScreen();
    },
  );
}

/// generated route for
/// [_i3.DeliveryAddressPage]
class DeliveryAddressRoute extends _i20.PageRouteInfo<void> {
  const DeliveryAddressRoute({List<_i20.PageRouteInfo>? children})
    : super(DeliveryAddressRoute.name, initialChildren: children);

  static const String name = 'DeliveryAddressRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i3.DeliveryAddressPage();
    },
  );
}

/// generated route for
/// [_i4.ForgotPasswordPage]
class ForgotPasswordRoute extends _i20.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i20.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i4.ForgotPasswordPage();
    },
  );
}

/// generated route for
/// [_i5.HomeScreen]
class HomeRoute extends _i20.PageRouteInfo<void> {
  const HomeRoute({List<_i20.PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomeScreen();
    },
  );
}

/// generated route for
/// [_i6.LoginPage]
class LoginRoute extends _i20.PageRouteInfo<void> {
  const LoginRoute({List<_i20.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i6.LoginPage();
    },
  );
}

/// generated route for
/// [_i7.MainShellPage]
class MainShellRoute extends _i20.PageRouteInfo<void> {
  const MainShellRoute({List<_i20.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i7.MainShellPage();
    },
  );
}

/// generated route for
/// [_i8.MenuScreen]
class MenuRoute extends _i20.PageRouteInfo<MenuRouteArgs> {
  MenuRoute({
    _i22.Category? category,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         MenuRoute.name,
         args: MenuRouteArgs(category: category, key: key),
         initialChildren: children,
       );

  static const String name = 'MenuRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MenuRouteArgs>(
        orElse: () => const MenuRouteArgs(),
      );
      return _i8.MenuScreen(category: args.category, key: args.key);
    },
  );
}

class MenuRouteArgs {
  const MenuRouteArgs({this.category, this.key});

  final _i22.Category? category;

  final _i21.Key? key;

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
/// [_i9.NotificationsScreen]
class NotificationsRoute extends _i20.PageRouteInfo<void> {
  const NotificationsRoute({List<_i20.PageRouteInfo>? children})
    : super(NotificationsRoute.name, initialChildren: children);

  static const String name = 'NotificationsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i9.NotificationsScreen();
    },
  );
}

/// generated route for
/// [_i10.OnboardingPage]
class OnboardingRoute extends _i20.PageRouteInfo<void> {
  const OnboardingRoute({List<_i20.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i10.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i11.OrderFormScreen]
class OrderFormRoute extends _i20.PageRouteInfo<void> {
  const OrderFormRoute({List<_i20.PageRouteInfo>? children})
    : super(OrderFormRoute.name, initialChildren: children);

  static const String name = 'OrderFormRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i11.OrderFormScreen();
    },
  );
}

/// generated route for
/// [_i12.OrdersScreen]
class OrdersRoute extends _i20.PageRouteInfo<void> {
  const OrdersRoute({List<_i20.PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i12.OrdersScreen();
    },
  );
}

/// generated route for
/// [_i13.OtpPage]
class OtpRoute extends _i20.PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    required String phone,
    _i21.Key? key,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(phone: phone, key: key),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return _i13.OtpPage(phone: args.phone, key: args.key);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({required this.phone, this.key});

  final String phone;

  final _i21.Key? key;

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
/// [_i14.ProfileDetailScreen]
class ProfileDetailRoute extends _i20.PageRouteInfo<void> {
  const ProfileDetailRoute({List<_i20.PageRouteInfo>? children})
    : super(ProfileDetailRoute.name, initialChildren: children);

  static const String name = 'ProfileDetailRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i14.ProfileDetailScreen();
    },
  );
}

/// generated route for
/// [_i15.ProfileScreen]
class ProfileRoute extends _i20.PageRouteInfo<void> {
  const ProfileRoute({List<_i20.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i15.ProfileScreen();
    },
  );
}

/// generated route for
/// [_i16.SignupPage]
class SignupRoute extends _i20.PageRouteInfo<void> {
  const SignupRoute({List<_i20.PageRouteInfo>? children})
    : super(SignupRoute.name, initialChildren: children);

  static const String name = 'SignupRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i16.SignupPage();
    },
  );
}

/// generated route for
/// [_i17.SplashPage]
class SplashRoute extends _i20.PageRouteInfo<void> {
  const SplashRoute({List<_i20.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i17.SplashPage();
    },
  );
}

/// generated route for
/// [_i18.SubscriptionsScreen]
class SubscriptionsRoute extends _i20.PageRouteInfo<void> {
  const SubscriptionsRoute({List<_i20.PageRouteInfo>? children})
    : super(SubscriptionsRoute.name, initialChildren: children);

  static const String name = 'SubscriptionsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      return const _i18.SubscriptionsScreen();
    },
  );
}

/// generated route for
/// [_i19.TermsAndConditionsScreen]
class TermsAndConditionsRoute
    extends _i20.PageRouteInfo<TermsAndConditionsRouteArgs> {
  TermsAndConditionsRoute({
    _i21.Key? key,
    bool isPrivacyPolicy = false,
    List<_i20.PageRouteInfo>? children,
  }) : super(
         TermsAndConditionsRoute.name,
         args: TermsAndConditionsRouteArgs(
           key: key,
           isPrivacyPolicy: isPrivacyPolicy,
         ),
         initialChildren: children,
       );

  static const String name = 'TermsAndConditionsRoute';

  static _i20.PageInfo page = _i20.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TermsAndConditionsRouteArgs>(
        orElse: () => const TermsAndConditionsRouteArgs(),
      );
      return _i19.TermsAndConditionsScreen(
        key: args.key,
        isPrivacyPolicy: args.isPrivacyPolicy,
      );
    },
  );
}

class TermsAndConditionsRouteArgs {
  const TermsAndConditionsRouteArgs({this.key, this.isPrivacyPolicy = false});

  final _i21.Key? key;

  final bool isPrivacyPolicy;

  @override
  String toString() {
    return 'TermsAndConditionsRouteArgs{key: $key, isPrivacyPolicy: $isPrivacyPolicy}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TermsAndConditionsRouteArgs) return false;
    return key == other.key && isPrivacyPolicy == other.isPrivacyPolicy;
  }

  @override
  int get hashCode => key.hashCode ^ isPrivacyPolicy.hashCode;
}
