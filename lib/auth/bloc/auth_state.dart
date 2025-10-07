part of 'auth_bloc.dart';

// @immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

/// State when user is authenticated successfully
/// This means the auth flow is completed when user selects a role
final class Authenticated extends AuthState {
  Authenticated({
    required this.user,
  });
  final User user;
}

class Unauthenticated extends AuthState {
  Unauthenticated({this.message});
  final String? message;
}
