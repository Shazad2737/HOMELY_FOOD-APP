import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart';
import 'package:instamess_api/src/subscription/subscription_facade_interface.dart';

/// {@template subscription_repository}
/// Repository which manages subscription related requests.
/// {@endtemplate}
class SubscriptionRepository implements ISubscriptionRepository {
  /// {@macro subscription_repository}
  SubscriptionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, SubscriptionData>> getSubscription() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'subscription',
      );

      return response.fold(
        left,
        (r) {
          // Check for null response body
          if (r.data == null) {
            log('No response body in SubscriptionRepository.getSubscription');
            return left(
              const UnknownApiFailure(
                500,
                'No response data received',
              ),
            );
          }

          final body = r.data!;
          final success = body['success'] as bool? ?? false;

          // Check success flag
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to fetch subscription';
            log('API returned success: false - $message');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 500,
                message,
              ),
            );
          }

          // Parse data field
          final data = body['data'];
          if (data == null) {
            log('No data field in response');
            return left(
              const UnknownApiFailure(
                500,
                'No subscription data in response',
              ),
            );
          }

          // Parse and return subscription data
          try {
            return Right(
              SubscriptionData.fromJson(data as Map<String, dynamic>),
            );
          } catch (e, s) {
            log(
              'Failed to parse subscription data: $e',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 500,
                'Failed to parse subscription data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Unknown error in SubscriptionRepository.getSubscription: $e',
        error: e,
        stackTrace: s,
      );
      return left(const UnknownFailure());
    }
  }
}
