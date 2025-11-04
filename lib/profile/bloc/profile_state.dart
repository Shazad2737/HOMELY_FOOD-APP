import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template profile_state}
/// State for profile screen
/// {@endtemplate}
class ProfileState extends Equatable {
  /// {@macro profile_state}
  const ProfileState({
    required this.profileState,
    this.profilePictureUpdateState = const DataStateInitial(),
  });

  /// Factory for initial state
  factory ProfileState.initial() => const ProfileState(
        profileState: DataStateInitial(),
      );

  /// Profile data state
  final DataState<CustomerProfile> profileState;

  /// Profile picture update state
  final DataState<CustomerProfile> profilePictureUpdateState;

  /// Whether profile is loading
  bool get isLoading => profileState.isLoading;

  /// Whether profile picture is uploading
  bool get isUploadingPicture => profilePictureUpdateState.isLoading;

  /// Creates a copy with updated fields
  ProfileState copyWith({
    DataState<CustomerProfile>? profileState,
    DataState<CustomerProfile>? profilePictureUpdateState,
  }) {
    return ProfileState(
      profileState: profileState ?? this.profileState,
      profilePictureUpdateState:
          profilePictureUpdateState ?? this.profilePictureUpdateState,
    );
  }

  @override
  List<Object?> get props => [profileState, profilePictureUpdateState];
}
