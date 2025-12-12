import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/subscription/models/models.dart'
    as subscription_models;
import 'package:homely_api/src/user/models/models.dart';
import 'package:homely_api/src/user/user_repository_interface.dart';

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

  @override
  Future<Either<Failure, AvailableOrderDays>> getAvailableOrderDays() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/order/available',
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.getAvailableOrderDays');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message = body['message'] as String? ??
                'Failed to fetch available order days';
            log('Error in UserRepository.getAvailableOrderDays: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.getAvailableOrderDays');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final availableOrderDays = AvailableOrderDays.fromJson(data);
            return right(availableOrderDays);
          } catch (e, s) {
            log(
              'Error parsing available order days response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse available order days data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.getAvailableOrderDays',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CreateOrderResponse>> createOrder(
    CreateOrderRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/order/create',
        body: request.toJson(),
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.createOrder');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to create order';
            log('Error in UserRepository.createOrder: $message');

            // Handle validation errors
            if (r.statusCode == 422 || r.statusCode == 400) {
              try {
                return left(ApiValidationFailure.fromJson(body));
              } catch (e) {
                log('Failed to parse validation error: $e');
              }
            }

            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.createOrder');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final createOrderResponse = CreateOrderResponse.fromJson(data);
            return right(createOrderResponse);
          } catch (e, s) {
            log(
              'Error parsing create order response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse order data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.createOrder',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  // Profile operations

  @override
  Future<Either<Failure, CustomerProfile>> getProfile() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/customers/profile',
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.getProfile');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to fetch profile';
            log('Error in UserRepository.getProfile: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.getProfile');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final profile = CustomerProfile.fromJson(data);
            return right(profile);
          } catch (e, s) {
            log(
              'Error parsing profile response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse profile data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.getProfile',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerProfile>> updateProfilePicture(
    MultipartFile file,
  ) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/customers/profile-picture',
        body: {
          'profilePicture': file,
        },
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.updateProfilePicture');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message = body['message'] as String? ??
                'Failed to update profile picture';
            log('Error in UserRepository.updateProfilePicture: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.updateProfilePicture');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            // Backend returns CustomerBasicInfoResource which has subset of fields
            // We'll parse it as CustomerProfile for consistency
            final profile = CustomerProfile.fromJson(data);
            return right(profile);
          } catch (e, s) {
            log(
              'Error parsing profile picture update response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse response',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.updateProfilePicture',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  // Address operations

  @override
  Future<Either<Failure, AddressesResponse>> getAddresses() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/customers/addresses',
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.getAddresses');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to fetch addresses';
            log('Error in UserRepository.getAddresses: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.getAddresses');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final addressesResponse = AddressesResponse.fromJson(data);
            return right(addressesResponse);
          } catch (e, s) {
            log(
              'Error parsing addresses response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse addresses data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.getAddresses',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> createAddress(
    CreateAddressRequest request,
  ) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '/customers/addresses',
        body: request.toJson(),
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.createAddress');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to create address';
            log('Error in UserRepository.createAddress: $message');

            // Handle validation errors
            if (r.statusCode == 422 || r.statusCode == 400) {
              try {
                return left(ApiValidationFailure.fromJson(body));
              } catch (e) {
                log('Failed to parse validation error: $e');
              }
            }

            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.createAddress');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final address = CustomerAddress.fromJson(data);
            return right(address);
          } catch (e, s) {
            log(
              'Error parsing create address response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse address data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.createAddress',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> updateAddress(
    String addressId,
    UpdateAddressRequest request,
  ) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/customers/addresses/$addressId',
        body: request.toJson(),
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.updateAddress');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to update address';
            log('Error in UserRepository.updateAddress: $message');

            // Handle validation errors
            if (r.statusCode == 422 || r.statusCode == 400) {
              try {
                return left(ApiValidationFailure.fromJson(body));
              } catch (e) {
                log('Failed to parse validation error: $e');
              }
            }

            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.updateAddress');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final address = CustomerAddress.fromJson(data);
            return right(address);
          } catch (e, s) {
            log(
              'Error parsing update address response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse address data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.updateAddress',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteAddress(String addressId) async {
    try {
      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/customers/addresses/$addressId',
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.deleteAddress');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to delete address';
            log('Error in UserRepository.deleteAddress: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          return right(unit);
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.deleteAddress',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> setDefaultAddress(
    String addressId,
  ) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/customers/addresses/$addressId/set-default',
      );

      return response.fold(
        left,
        (r) {
          final body = r.data;
          if (body == null) {
            log('No response body in UserRepository.setDefaultAddress');
            return left(const UnknownApiFailure(0, 'No response body'));
          }

          final success = body['success'] as bool? ?? false;
          if (!success) {
            final message =
                body['message'] as String? ?? 'Failed to set default address';
            log('Error in UserRepository.setDefaultAddress: $message');
            return left(
              UnknownApiFailure(r.statusCode ?? 0, message),
            );
          }

          final data = body['data'] as Map<String, dynamic>?;
          if (data == null) {
            log('No data in UserRepository.setDefaultAddress');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'No data in response',
              ),
            );
          }

          try {
            final address = CustomerAddress.fromJson(data);
            return right(address);
          } catch (e, s) {
            log(
              'Error parsing set default address response',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 0,
                'Failed to parse address data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Exception in UserRepository.setDefaultAddress',
        error: e,
        stackTrace: s,
      );
      return left(UnknownFailure(message: e.toString()));
    }
  }
}
