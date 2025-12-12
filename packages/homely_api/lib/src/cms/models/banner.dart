import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// Banner placement enum
enum BannerPlacement {
  homePageTop,
  homePageMiddle1,
  homePageMiddle2,
  homePageBottom,
  subscriptionPage,
  locationForm;

  /// Creates BannerPlacement from string
  static BannerPlacement? fromString(String? value) {
    if (value == null) return null;
    switch (value.toUpperCase()) {
      case 'HOME_PAGE_TOP':
        return BannerPlacement.homePageTop;
      case 'HOME_PAGE_MIDDLE_1':
        return BannerPlacement.homePageMiddle1;
      case 'HOME_PAGE_MIDDLE_2':
        return BannerPlacement.homePageMiddle2;
      case 'HOME_PAGE_BOTTOM':
        return BannerPlacement.homePageBottom;
      case 'SUBSCRIPTION_PAGE':
        return BannerPlacement.subscriptionPage;
      case 'LOCATION_FORM':
        return BannerPlacement.locationForm;
      default:
        return null;
    }
  }

  /// Converts to string for API
  String toApiString() {
    switch (this) {
      case BannerPlacement.homePageTop:
        return 'HOME_PAGE_TOP';
      case BannerPlacement.homePageMiddle1:
        return 'HOME_PAGE_MIDDLE_1';
      case BannerPlacement.homePageMiddle2:
        return 'HOME_PAGE_MIDDLE_2';
      case BannerPlacement.homePageBottom:
        return 'HOME_PAGE_BOTTOM';
      case BannerPlacement.subscriptionPage:
        return 'SUBSCRIPTION_PAGE';
      case BannerPlacement.locationForm:
        return 'LOCATION_FORM';
    }
  }
}

/// {@template banner_image}
/// Banner image model
/// {@endtemplate}
class BannerImage extends Equatable {
  /// {@macro banner_image}
  const BannerImage({
    this.id,
    this.imageUrl,
    this.redirectUrl,
    this.caption,
    this.sortOrder,
  });

  /// Creates a BannerImage from Json map
  factory BannerImage.fromJson(Map<String, dynamic> json) {
    return BannerImage(
      id: pick(json, 'id').asStringOrNull(),
      imageUrl: pick(json, 'imageUrl').asStringOrNull(),
      redirectUrl: pick(json, 'redirectUrl').asStringOrNull(),
      caption: pick(json, 'caption').asStringOrNull(),
      sortOrder: pick(json, 'sortOrder').asIntOrNull() ?? 0,
    );
  }

  /// Converts BannerImage to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'caption': caption,
      'sortOrder': sortOrder,
    };
  }

  /// Image id
  final String? id;

  /// Image URL
  final String? imageUrl;

  /// Redirect URL when image is tapped
  final String? redirectUrl;

  /// Image caption
  final String? caption;

  /// Sort order
  final int? sortOrder;

  @override
  List<Object?> get props => [id, imageUrl, redirectUrl, caption, sortOrder];
}

/// {@template banner}
/// Banner model
/// {@endtemplate}
class Banner extends Equatable {
  /// {@macro banner}
  const Banner({
    this.id,
    this.title,
    this.description,
    this.placement,
    this.sortOrder,
    this.images = const [],
  });

  /// Creates a Banner from Json map
  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: pick(json, 'id').asStringOrNull(),
      title: pick(json, 'title').asStringOrNull(),
      description: pick(json, 'description').asStringOrNull(),
      placement: BannerPlacement.fromString(
        pick(json, 'placement').asStringOrNull(),
      ),
      sortOrder: pick(json, 'sortOrder').asIntOrNull() ?? 0,
      images: pick(json, 'images').asListOrEmpty((pick) {
        return BannerImage.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
    );
  }

  /// Converts Banner to Json map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'placement': placement?.toApiString(),
      'sortOrder': sortOrder,
      'images': images.map((e) => e.toJson()).toList(),
    };
  }

  /// Banner id
  final String? id;

  /// Banner title
  final String? title;

  /// Banner description
  final String? description;

  /// Banner placement
  final BannerPlacement? placement;

  /// Sort order
  final int? sortOrder;

  /// Banner images
  final List<BannerImage> images;

  @override
  List<Object?> get props =>
      [id, title, description, placement, sortOrder, images];
}
