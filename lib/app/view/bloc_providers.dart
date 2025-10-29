import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/auth/bloc/auth_bloc.dart';
import 'package:instamess_app/auth/login/bloc/login_bloc.dart';
import 'package:instamess_app/auth/signup/bloc/signup_bloc.dart';

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
  ];
}
