import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template dashboard_repo}
/// Repository which manages dashboard related requests.
/// {@endtemplate}
class DashboardRepo {
  /// {@macro dashboard_repo}
  DashboardRepo(this._apiClient);

  final ApiClient _apiClient;

  /// Get details for the dashboard
  Future<Either<Failure, DashboardResponse>> getDashboard() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'supervisor/dashboard',
      );

      return response.fold(
        left,
        (r) {
          if (r.statusCode == 200) {
            if (r.data == null) {
              log('No data in DashboardRepo.getDashboard');
              return left(
                const UnknownApiFailure(
                  500,
                  'No data',
                ),
              );
            }
            return Right(DashboardResponse.fromJson(r.data!));
          } else {
            log('Unknown error in DashboardRepo.getDashboard $r');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 500,
                r.statusMessage ?? 'Unknown error',
                apiErrorMessage: r.data?['error'] as String?,
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Unknown error in DashboardRepo.getDashboard $e',
        error: e,
        stackTrace: s,
      );
      return left(
        const UnknownFailure(),
      );
    }
  }
}
