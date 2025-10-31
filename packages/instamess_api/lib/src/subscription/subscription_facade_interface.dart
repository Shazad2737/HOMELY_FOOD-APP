import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart';

/// {@template subscription_facade_interface}
/// Interface for subscription operations
/// {@endtemplate}
abstract class ISubscriptionRepository {
  /// Get subscription data including meal types, banner, and contact info
  Future<Either<Failure, SubscriptionData>> getSubscription();
}
