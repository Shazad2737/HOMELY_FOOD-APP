import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/onboarding/i_onboarding_repository.dart';

/// {@template onboarding_repository}
/// Implementation of [IOnboardingRepository] using secure storage.
/// {@endtemplate}
class OnboardingRepository implements IOnboardingRepository {
  /// {@macro onboarding_repository}
  OnboardingRepository({
    required IStorageController storageController,
  }) : _storageController = storageController;

  final IStorageController _storageController;

  @override
  TaskOption<bool> isOnboardingCompleted() {
    return TaskOption(() async {
      try {
        final result = await _storageController.get(
          key: StorageKey.onboardingCompleted,
        );

        return result.fold(
          (failure) {
            log('Failed to get onboarding status: $failure');
            return const None();
          },
          (value) => Some(value),
        );
      } catch (e, s) {
        log('Error checking onboarding status: $e', stackTrace: s);
        return const None();
      }
    });
  }

  @override
  TaskEither<String, Unit> markOnboardingCompleted() {
    return TaskEither(() async {
      try {
        final result = await _storageController.save(
          key: StorageKey.onboardingCompleted,
          value: true,
        );

        return result.fold(
          (failure) => left('Failed to save onboarding status: ${failure.message}'),
          (_) => right(unit),
        );
      } catch (e, s) {
        log('Error marking onboarding complete: $e', stackTrace: s);
        return left('Failed to mark onboarding complete: $e');
      }
    });
  }
}
