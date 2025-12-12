part of 'onboarding_bloc.dart';

/// {@template onboarding_state}
/// State for [OnboardingBloc].
/// {@endtemplate}
@immutable
class OnboardingState {
  /// {@macro onboarding_state}
  const OnboardingState({
    required this.currentPage,
    required this.totalPages,
    this.isCompleting = false,
    this.isCompleted = false,
    this.error,
  });

  /// Initial state with first page selected.
  factory OnboardingState.initial() {
    return const OnboardingState(
      currentPage: 0,
      totalPages: 4,
    );
  }

  /// Current page index (0-indexed).
  final int currentPage;

  /// Total number of onboarding pages.
  final int totalPages;

  /// Whether the completion is in progress.
  final bool isCompleting;

  /// Whether onboarding has been completed.
  final bool isCompleted;

  /// Error message if completion failed.
  final String? error;

  /// Returns true if currently on the last page.
  bool get isLastPage => currentPage == totalPages - 1;

  /// Creates a copy of this state with the given fields replaced.
  OnboardingState copyWith({
    int? currentPage,
    int? totalPages,
    bool? isCompleting,
    bool? isCompleted,
    String? error,
  }) {
    return OnboardingState(
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isCompleting: isCompleting ?? this.isCompleting,
      isCompleted: isCompleted ?? this.isCompleted,
      error: error ?? this.error,
    );
  }

  @override
  String toString() => '''
OnboardingState {
  currentPage: $currentPage,
  totalPages: $totalPages,
  isLastPage: $isLastPage,
  isCompleting: $isCompleting,
  isCompleted: $isCompleted,
  error: $error
}
''';
}
