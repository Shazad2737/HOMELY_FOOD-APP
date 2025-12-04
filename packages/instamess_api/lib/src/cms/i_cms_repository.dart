import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/cms/models/models.dart';

/// {@template cms_facade_interface}
/// Interface for CMS operations
/// {@endtemplate}
abstract class ICmsRepository {
  /// Get locations
  Future<Either<Failure, List<Location>>> getLocations();

  /// Get areas by location ID
  Future<Either<Failure, List<Area>>> getAreas(String locationId);

  /// Get home page data
  Future<Either<Failure, HomePageData>> getHomePage();

  /// Get categories (cached for performance)
  Future<Either<Failure, List<Category>>> getCategories();

  /// Get banner for location form (nullable)
  Future<Either<Failure, Banner?>> getLocationFormBanner();

  /// Get latest Terms & Conditions
  Future<Either<Failure, Terms>> getTerms();
}
