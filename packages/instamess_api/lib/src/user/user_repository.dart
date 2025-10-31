import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart'
    as subscription_models;
import 'package:instamess_api/src/user/models/models.dart';
import 'package:instamess_api/src/user/user_repository_interface.dart';

/// {@template user_repository}
/// Repository which manages user-related requests (orders, subscriptions, profile).
/// {@endtemplate}
class UserRepository implements IUserRepository {
  /// {@macro user_repository}
  UserRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, OrdersResponse>> getOrders({
    required OrderType type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/order',
        queryParameters: {
          'type': type.toQueryParam(),
          'page': page,
          'limit': limit,
        },
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in OrdersRepository.getOrders');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to fetch orders';
            log('Error in OrdersRepository.getOrders: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in OrdersRepository.getOrders');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final ordersResponse = OrdersResponse.fromJson(data);
            return right(ordersResponse);
          } catch (e, s) {
            log(
              'Error parsing orders response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse orders data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in OrdersRepository.getOrders',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, subscription_models.SubscriptionData>>
      getSubscription() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'subscription',
      );

      return response.fold(
        left,
        (r) {
          // Check for null response body
          if (r.data == null) {
            log('No response body in UserRepository.getSubscription');
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
              subscription_models.SubscriptionData.fromJson(
                data as Map<String, dynamic>,
              ),
            );
          } catch (e, s) {
            log(
              'Failed to parse subscription data',
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
        'Exception in UserRepository.getSubscription',
        error: e,
        stackTrace: s,
      );
      return left(const UnknownFailure());
    }
  }
}
