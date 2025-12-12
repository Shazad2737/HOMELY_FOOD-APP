import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/cms/i_cms_repository.dart';
import 'package:homely_api/src/cms/models/models.dart';

/// {@template cms_facade}
/// CMS facade implementation
///
/// This class is responsible for handling all CMS related tasks
/// such as fetching locations, areas, and other configuration data.
/// {@endtemplate}
class CmsRepository implements ICmsRepository {
  /// {@macro cms_facade}
  CmsRepository({
    required this.apiClient,
  });

  /// Api client
  final ApiClient apiClient;

  // In-memory cache for categories
  List<Category>? _categoriesCache;
  DateTime? _categoriesCacheTime;
  static const _cacheValidDuration = Duration(minutes: 30);

  @override
  Future<Either<Failure, List<Location>>> getLocations() async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'location',
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching locations: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'Unknown error occurred while fetching locations',
            ),
          );
        }

        try {
          final success = body['success'] as bool? ?? false;
          if (!success) {
            return left(
              const UnknownApiFailure(0, 'Failed to fetch locations'),
            );
          }

          final data = body['data'] as List<dynamic>?;
          if (data == null) {
            return left(
              const UnknownApiFailure(0, 'No location data received'),
            );
          }

          final locations = data
              .map((json) => Location.fromJson(json as Map<String, dynamic>))
              .toList();

          return right(locations);
        } catch (e, s) {
          log('Error parsing locations response: $e', stackTrace: s);
          return left(
            const UnknownApiFailure(0, 'Failed to parse locations response'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<Area>>> getAreas(String locationId) async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'location/area/$locationId',
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching areas: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'Unknown error occurred while fetching areas',
            ),
          );
        }

        try {
          final success = body['success'] as bool? ?? false;
          if (!success) {
            return left(
              const UnknownApiFailure(0, 'Failed to fetch areas'),
            );
          }

          final data = body['data'] as List<dynamic>?;
          if (data == null) {
            return left(
              const UnknownApiFailure(0, 'No area data received'),
            );
          }

          final areas = data
              .map((json) => Area.fromJson(json as Map<String, dynamic>))
              .toList();

          return right(areas);
        } catch (e, s) {
          log('Error parsing areas response: $e', stackTrace: s);
          return left(
            const UnknownApiFailure(0, 'Failed to parse areas response'),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, HomePageData>> getHomePage() async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'home',
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching home page data: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'Unknown error occurred while fetching home page data',
            ),
          );
        }

        try {
          final success = body['success'] as bool? ?? false;
          if (!success) {
            return left(
              const UnknownApiFailure(0, 'Failed to fetch home page data'),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            return left(
              const UnknownApiFailure(0, 'No home page data received'),
            );
          }

          final homePageData = HomePageData.fromJson(data);

          return right(homePageData);
        } catch (e, s) {
          log('Error parsing home page response: $e', stackTrace: s);
          return left(
            const UnknownApiFailure(
              0,
              'Failed to parse home page response',
            ),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, Banner?>> getLocationFormBanner() async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'location/banner',
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching location form banner: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'Unknown error occurred while fetching location banner',
            ),
          );
        }

        try {
          final success = body['success'] as bool? ?? false;
          if (!success) {
            return left(
              const UnknownApiFailure(0, 'Failed to fetch location banner'),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            // No banner present - return null success
            return right(null);
          }

          final banner = Banner.fromJson(data);

          return right(banner);
        } catch (e, s) {
          log('Error parsing location banner response: $e', stackTrace: s);
          return left(
            const UnknownApiFailure(
              0,
              'Failed to parse location banner response',
            ),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, Terms>> getTerms() async {
    final resEither = await apiClient.get<Map<String, dynamic>>(
      'terms',
    );

    return resEither.fold(
      (apiFailure) async {
        log('Error fetching terms: $apiFailure');
        return left(apiFailure);
      },
      (response) async {
        final body = response.data;
        if (body == null) {
          return left(
            const UnknownApiFailure(
              0,
              'Unknown error occurred while fetching terms',
            ),
          );
        }

        try {
          final success = body['success'] as bool? ?? false;
          if (!success) {
            return left(
              const UnknownApiFailure(0, 'Failed to fetch terms'),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            return left(
              const UnknownApiFailure(0, 'No terms data received'),
            );
          }

          final terms = Terms.fromJson(data);

          return right(terms);
        } catch (e, s) {
          log('Error parsing terms response: $e', stackTrace: s);
          return left(
            const UnknownApiFailure(
              0,
              'Failed to parse terms response',
            ),
          );
        }
      },
    );
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    // Return cached categories if valid
    if (_categoriesCache != null && _isCacheValid()) {
      log('Returning cached categories');
      return right(_categoriesCache!);
    }

    log('Fetching categories from API');

    // Fetch from home page endpoint (categories are part of home data)
    final homePageResult = await getHomePage();

    return homePageResult.fold(
      (failure) {
        log('Error fetching categories: $failure');
        return left(failure);
      },
      (homePageData) {
        // Cache the categories
        _categoriesCache = homePageData.categories;
        _categoriesCacheTime = DateTime.now();
        log('Cached ${_categoriesCache?.length ?? 0} categories');
        return right(homePageData.categories);
      },
    );
  }

  /// Check if the categories cache is still valid
  bool _isCacheValid() {
    if (_categoriesCacheTime == null) return false;
    final age = DateTime.now().difference(_categoriesCacheTime!);
    return age < _cacheValidDuration;
  }
}
