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

  /// Gets the displayable profile data
  CustomerProfile? get displayProfile {
    if (profileState is DataStateSuccess<CustomerProfile>) {
      return (profileState as DataStateSuccess<CustomerProfile>).data;
    }
    if (profileState is DataStateRefreshing<CustomerProfile>) {
      return (profileState as DataStateRefreshing<CustomerProfile>).currentData;
    }
    return null;
  }

  /// Gets displayable name - from profile or fallback
  String get displayName => displayProfile?.name ?? 'User';

  /// Gets displayable mobile - from profile or fallback
  String get displayMobile => displayProfile?.mobile ?? 'Not available';

  /// Gets displayable profile URL
  String? get displayProfileUrl => displayProfile?.profileUrl;

  /// Gets displayable email
  String? get displayEmail => displayProfile?.email;

  /// Whether there's an error loading profile data
  bool get hasProfileError => profileState is DataStateFailure;

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
