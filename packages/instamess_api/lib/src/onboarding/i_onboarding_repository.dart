import 'package:fpdart/fpdart.dart';

/// {@template i_onboarding_repository}
/// Interface for managing onboarding status.
/// {@endtemplate}
abstract class IOnboardingRepository {
  /// Checks if the user has completed onboarding.
  ///
  /// Returns `true` if onboarding is completed, `false` otherwise.
  TaskOption<bool> isOnboardingCompleted();

  /// Marks onboarding as completed.
  ///
  /// Returns [TaskEither] with [Unit] on success or error message on failure.
  TaskEither<String, Unit> markOnboardingCompleted();
}
