import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_app/router/router.gr.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles navigation for banner redirect URLs
///
/// Supports three URL formats:
/// 1. External URLs: `https://example.com` - Opens in browser
/// 2. Internal routes: `/menu`, `/subscriptions`, `/profile` - App navigation
/// 3. Empty/null: No action (display only)
class BannerNavigationHandler {
  /// Handles banner tap and navigates based on redirect URL format
  static Future<void> handleBannerTap(
    StackRouter router,
    String? redirectUrl,
  ) async {
    if (redirectUrl == null || redirectUrl.trim().isEmpty) {
      debugPrint('BannerNavigationHandler: No redirect URL provided');
      return;
    }

    final url = redirectUrl.trim();
    debugPrint('BannerNavigationHandler: Processing URL: $url');

    // External URLs (http:// or https://)
    if (url.startsWith('http://') || url.startsWith('https://')) {
      await _handleExternalUrl(url);
      return;
    }

    // Internal routes (starts with /)
    if (url.startsWith('/')) {
      await _handleInternalRoute(router, url);
      return;
    }

    // Invalid format
    debugPrint('BannerNavigationHandler: Invalid URL format: $url');
  }

  /// Opens external URL in browser
  static Future<void> _handleExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        debugPrint('BannerNavigationHandler: Launched external URL: $url');
      } else {
        debugPrint('BannerNavigationHandler: Cannot launch URL: $url');
      }
    } catch (e) {
      debugPrint('BannerNavigationHandler: Error launching URL: $e');
    }
  }

  /// Navigates to internal app route
  static Future<void> _handleInternalRoute(
    StackRouter router,
    String path,
  ) async {
    // Remove leading slash for comparison
    final cleanPath = path.toLowerCase().replaceFirst('/', '');

    try {
      switch (cleanPath) {
        case 'menu':
          await router.push(MenuRoute());
          debugPrint('BannerNavigationHandler: Navigated to Menu');

        case 'subscriptions':
          await router.push(const SubscriptionsRoute());
          debugPrint('BannerNavigationHandler: Navigated to Subscriptions');

        case 'profile':
          await router.push(const ProfileRoute());
          debugPrint('BannerNavigationHandler: Navigated to Profile');

        case 'order-form':
        case 'orderform':
          await router.push(const OrderFormRoute());
          debugPrint('BannerNavigationHandler: Navigated to Order Form');

        case 'home':
        case '':
          await router.push(const HomeRoute());
          debugPrint('BannerNavigationHandler: Navigated to Home');

        default:
          debugPrint(
            'BannerNavigationHandler: Unknown internal route: $cleanPath',
          );
      }
    } catch (e) {
      debugPrint('BannerNavigationHandler: Navigation error: $e');
    }
  }

  /// Validates if a redirect URL is in a supported format
  static bool isValidRedirectUrl(String? url) {
    if (url == null || url.trim().isEmpty) {
      return true; // Empty is valid (no action)
    }

    final trimmed = url.trim();

    // Check external URL
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      try {
        Uri.parse(trimmed);
        return true;
      } catch (e) {
        return false;
      }
    }

    // Check internal route
    if (trimmed.startsWith('/')) {
      final cleanPath = trimmed.toLowerCase().replaceFirst('/', '');
      final validRoutes = [
        'menu',
        'subscriptions',
        'profile',
        'order-form',
        'orderform',
        'home',
        '',
      ];
      return validRoutes.contains(cleanPath);
    }

    return false;
  }

  /// Returns a user-friendly description of what the URL will do
  static String getUrlDescription(String? url) {
    if (url == null || url.trim().isEmpty) {
      return 'Display only (no action)';
    }

    final trimmed = url.trim();

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return 'Opens in browser: $trimmed';
    }

    if (trimmed.startsWith('/')) {
      final cleanPath = trimmed.toLowerCase().replaceFirst('/', '');
      switch (cleanPath) {
        case 'menu':
          return 'Opens Menu screen';
        case 'subscriptions':
          return 'Opens Subscriptions screen';
        case 'profile':
          return 'Opens Profile screen';
        case 'order-form':
        case 'orderform':
          return 'Opens Order Form screen';
        case 'home':
        case '':
          return 'Opens Home screen';
        default:
          return 'Unknown route: $cleanPath';
      }
    }

    return 'Invalid URL format';
  }
}
