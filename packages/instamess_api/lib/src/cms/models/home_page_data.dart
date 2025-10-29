import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/cms/models/banner.dart';
import 'package:instamess_api/src/cms/models/category.dart';

/// {@template home_page_data}
/// Home page data model
/// {@endtemplate}
class HomePageData extends Equatable {
  /// {@macro home_page_data}
  const HomePageData({
    this.banners = const [],
    this.categories = const [],
    this.hasUnreadNotifications = false,
    this.unreadCount = 0,
  });

  /// Creates a HomePageData from Json map
  factory HomePageData.fromJson(Map<String, dynamic> json) {
    return HomePageData(
      banners: pick(json, 'banners').asListOrEmpty((pick) {
        return Banner.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      categories: pick(json, 'categories').asListOrEmpty((pick) {
        return Category.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      hasUnreadNotifications:
          pick(json, 'hasUnreadNotifications').asBoolOrNull() ?? false,
      unreadCount: pick(json, 'unreadCount').asIntOrNull() ?? 0,
    );
  }

  /// Converts HomePageData to Json map
  Map<String, dynamic> toJson() {
    return {
      'banners': banners.map((e) => e.toJson()).toList(),
      'categories': categories.map((e) => e.toJson()).toList(),
      'hasUnreadNotifications': hasUnreadNotifications,
      'unreadCount': unreadCount,
    };
  }

  /// List of banners
  final List<Banner> banners;

  /// List of categories
  final List<Category> categories;

  /// Whether there are unread notifications
  final bool hasUnreadNotifications;

  /// Number of unread notifications
  final int unreadCount;

  /// Get banners by placement
  List<Banner> getBannersByPlacement(BannerPlacement placement) {
    return banners.where((banner) => banner.placement == placement).toList()
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
  }

  @override
  List<Object?> get props =>
      [banners, categories, hasUnreadNotifications, unreadCount];
}
