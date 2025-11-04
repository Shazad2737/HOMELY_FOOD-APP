import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';

import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/auth/login/bloc/login_bloc.dart';
import 'package:instamess_app/auth/signup/bloc/signup_bloc.dart';
import 'package:instamess_app/profile/addresses/bloc/addresses_bloc.dart';
import 'package:instamess_app/profile/bloc/profile_bloc.dart';
import 'package:instamess_app/profile/bloc/profile_event.dart';

List<BlocProvider> getBlocProviders(
  IInstaMessApi apiClient,
  AuthBloc authBloc,
) {
  return [
    BlocProvider<AuthBloc>(
      create: (context) => authBloc..add(AuthCheckRequestedEvent()),
    ),
    BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(apiClient.authFacade),
    ),
    BlocProvider<SignupBloc>(
      create: (context) => SignupBloc(),
    ),
    // Provide a long-lived ProfileBloc at the app level so screens and
    // detail routes can access the same instance. This prevents Provider
    // lookup errors when navigating to sibling routes (e.g. ProfileDetailRoute)
    BlocProvider<ProfileBloc>(
      create: (context) => ProfileBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(const ProfileLoadedEvent()),
    ),
    // Provide AddressesBloc at the app level for address-related screens
    // and forms that need to access the same instance
    BlocProvider<AddressesBloc>(
      create: (context) => AddressesBloc(
        userRepository: context.read<IUserRepository>(),
      ),
    ),
  ];
}
