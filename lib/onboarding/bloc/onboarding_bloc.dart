// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

/// {@template onboarding_bloc}
/// Manages onboarding flow state including page navigation and completion.
/// {@endtemplate}
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  /// {@macro onboarding_bloc}
  OnboardingBloc({
    required this.onboardingRepository,
  }) : super(OnboardingState.initial()) {
    on<OnboardingEvent>((event, emit) async {
      switch (event) {
        case OnboardingPageChangedEvent():
          _onPageChanged(event, emit);
        case OnboardingCompletedEvent():
          await _onCompleted(event, emit);
      }
    });
  }

  /// Repository for persisting onboarding status.
  final IOnboardingRepository onboardingRepository;

  void _onPageChanged(
    OnboardingPageChangedEvent event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  Future<void> _onCompleted(
    OnboardingCompletedEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(isCompleting: true));

    final result = await onboardingRepository.markOnboardingCompleted().run();

    result.fold(
      (error) => emit(state.copyWith(isCompleting: false, error: error)),
      (_) => emit(state.copyWith(isCompleting: false, isCompleted: true)),
    );
  }
}
