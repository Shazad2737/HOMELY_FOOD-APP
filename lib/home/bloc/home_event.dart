part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

/// Event to load home page data
class HomeLoadedEvent extends HomeEvent {}

/// Event to refresh home page data
class HomeRefreshedEvent extends HomeEvent {}
