import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/menu/menu_repository_interface.dart';
import 'package:instamess_api/src/menu/models/models.dart';

/// {@template menu_repository}
/// Repository for menu-related operations
/// {@endtemplate}
class MenuRepository implements IMenuRepository {
  /// {@macro menu_repository}
  const MenuRepository({
    required this.apiClient,
  });

  /// Api client
  final ApiClient apiClient;

  @override
  Future<Either<Failure, MenuData>> getMenu({
    required String categoryId,
    String? planId,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (planId != null && planId.isNotEmpty) {
        queryParams['planId'] = planId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await apiClient.get<Map<String, dynamic>>(
        'menu/$categoryId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.fold(
        (apiFailure) {
          log('Error fetching menu: $apiFailure');
          return left(apiFailure);
        },
        (response) {
          final body = response.data;
          if (body == null) {
            return left(
              const UnknownApiFailure(
                0,
                'No menu data received',
              ),
            );
          }

          try {
            final success = body['success'] as bool? ?? false;
            if (!success) {
              final message =
                  body['message'] as String? ?? 'Failed to fetch menu';
              return left(UnknownApiFailure(response.statusCode ?? 0, message));
            }

            final data = body['data'] as Map<String, dynamic>?;
            if (data == null) {
              return left(
                const UnknownApiFailure(0, 'No menu data in response'),
              );
            }

            final menuData = MenuData.fromJson(data);
            return right(menuData);
          } catch (e, s) {
            log('Error parsing menu response: $e', stackTrace: s);
            return left(
              const UnknownApiFailure(
                0,
                'Failed to parse menu data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log('Unexpected error in getMenu: $e', stackTrace: s);
      return left(
        const UnknownFailure(
          message: 'An unexpected error occurred',
        ),
      );
    }
  }
}
