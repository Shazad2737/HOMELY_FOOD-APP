import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/menu/models/models.dart';

/// {@template menu_repository_interface}
/// Interface for Menu operations
/// {@endtemplate}
abstract class IMenuRepository {
  /// Get menu for a specific category
  ///
  /// [categoryId] - Required category ID
  /// [planId] - Optional plan ID to filter menu items
  /// [search] - Optional search query for item names, descriptions, or codes
  Future<Either<Failure, MenuData>> getMenu({
    required String categoryId,
    String? planId,
    String? search,
  });
}
