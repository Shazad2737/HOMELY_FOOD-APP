import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/profile/bloc/profile_event.dart';
import 'package:instamess_app/profile/bloc/profile_state.dart';

/// {@template profile_bloc}
/// Business logic component for profile management
/// {@endtemplate}
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  /// {@macro profile_bloc}
  ProfileBloc({
    required IUserRepository userRepository,
  })  : _userRepository = userRepository,
        super(ProfileState.initial()) {
    on<ProfileLoadedEvent>(_onLoaded);
    on<ProfileRefreshedEvent>(_onRefreshed);
    on<ProfilePictureUpdatedEvent>(_onProfilePictureUpdated);
  }

  final IUserRepository _userRepository;

  Future<void> _onLoaded(
    ProfileLoadedEvent event,
    Emitter<ProfileState> emit,
  ) async {
    log('ProfileBloc: Loading profile');
    emit(state.copyWith(profileState: DataState.loading()));

    final result = await _userRepository.getProfile();

    result.fold(
      (failure) {
        log('ProfileBloc: Failed to load profile - ${failure.message}');
        emit(state.copyWith(profileState: DataState.failure(failure)));
      },
      (profile) {
        log('ProfileBloc: Profile loaded successfully');
        emit(state.copyWith(profileState: DataState.success(profile)));
      },
    );
  }

  Future<void> _onRefreshed(
    ProfileRefreshedEvent event,
    Emitter<ProfileState> emit,
  ) async {
    log('ProfileBloc: Refreshing profile');

    // If we have existing data, use refreshing state to keep showing it
    if (state.profileState is DataStateSuccess<CustomerProfile>) {
      final currentProfile =
          (state.profileState as DataStateSuccess<CustomerProfile>).data;
      emit(
        state.copyWith(
          profileState: DataState.refreshing(currentProfile),
        ),
      );
    } else {
      emit(state.copyWith(profileState: DataState.loading()));
    }

    final result = await _userRepository.getProfile();

    result.fold(
      (failure) {
        log('ProfileBloc: Failed to refresh profile - ${failure.message}');
        emit(state.copyWith(profileState: DataState.failure(failure)));
      },
      (profile) {
        log('ProfileBloc: Profile refreshed successfully');
        emit(state.copyWith(profileState: DataState.success(profile)));
      },
    );
  }

  Future<void> _onProfilePictureUpdated(
    ProfilePictureUpdatedEvent event,
    Emitter<ProfileState> emit,
  ) async {
    log('ProfileBloc: Updating profile picture');
    emit(
      state.copyWith(
        profilePictureUpdateState: DataState.loading(),
      ),
    );

    final result = await _userRepository.updateProfilePicture(event.filePath);

    result.fold(
      (failure) {
        log(
          'ProfileBloc: Failed to update profile picture - ${failure.message}',
        );
        emit(
          state.copyWith(
            profilePictureUpdateState: DataState.failure(failure),
          ),
        );
      },
      (profile) {
        log('ProfileBloc: Profile picture updated successfully');
        // Update both states with new profile data
        emit(
          state.copyWith(
            profileState: DataState.success(profile),
            profilePictureUpdateState: DataState.success(profile),
          ),
        );
      },
    );
  }
}
