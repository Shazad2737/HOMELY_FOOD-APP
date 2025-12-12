part of 'onboarding_bloc.dart';

/// Events for [OnboardingBloc].
@immutable
sealed class OnboardingEvent {}

/// Event when user swipes to a different page.
class OnboardingPageChangedEvent extends OnboardingEvent {
  /// Creates an [OnboardingPageChangedEvent] with the given [page] index.
  OnboardingPageChangedEvent({required this.page});

  /// The new page index (0-indexed).
  final int page;
}

/// Event when user completes onboarding by tapping "Get Started".
class OnboardingCompletedEvent extends OnboardingEvent {}
