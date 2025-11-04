import 'package:equatable/equatable.dart';

/// {@template profile_event}
/// Base class for all profile events
/// {@endtemplate}
sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// {@template profile_loaded_event}
/// Event to load profile data
/// {@endtemplate}
final class ProfileLoadedEvent extends ProfileEvent {
  const ProfileLoadedEvent();
}

/// {@template profile_refreshed_event}
/// Event to refresh profile data
/// {@endtemplate}
final class ProfileRefreshedEvent extends ProfileEvent {
  const ProfileRefreshedEvent();
}

/// {@template profile_picture_updated_event}
/// Event to update profile picture
/// {@endtemplate}
final class ProfilePictureUpdatedEvent extends ProfileEvent {
  const ProfilePictureUpdatedEvent(this.filePath);

  /// Path to the image file
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}
