part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthCheckRequestedEvent extends AuthEvent {}

class AuthLogOutRequestedEvent extends AuthEvent {}

// /// Event fired when user is logged in successfully
// ///
// /// When this event happens, Authenticated state will be emitted without
// /// checking local storage .
// class AuthUserLoggedInEvent extends AuthEvent {
//   AuthUserLoggedInEvent(this.user);
//   final User user;
// }

/// Internal event fired when session state changes
/// This is used to react to SessionManager changes
class _AuthSessionChangedEvent extends AuthEvent {
  _AuthSessionChangedEvent(this.sessionOption);
  final Option<SessionData> sessionOption;
}
