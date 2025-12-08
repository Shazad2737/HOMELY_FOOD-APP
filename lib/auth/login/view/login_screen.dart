// +971 58 889 5187
// password

import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/auth/login/bloc/login_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: _MobileWidget(),
      ),
    );
  }
}

class _MobileWidget extends StatelessWidget {
  const _MobileWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Log In',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign in to your existing account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _LoginForm(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.router.push(const SignupRoute());
                          },
                          child: const Text('SIGN UP'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'By Continuing you agree instamess ',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    context.router.push(TermsAndConditionsRoute());
                  },
                  child: Text(
                    'Terms${kNonBreakingSpace}of${kNonBreakingSpace}services',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.black,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
                Text(
                  ' and ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w400,
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {
                    context.router.push(
                      TermsAndConditionsRoute(isPrivacyPolicy: true),
                    );
                  },
                  child: Text(
                    'Privacy${kNonBreakingSpace}Policy',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.black,
                      fontSize: 10,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      context.read<LoginBloc>().add(
        LoginPasswordChangedEvent(passwordController.text),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(
      listenWhen: (previous, current) =>
          previous.loginFailureOrSuccessOption !=
          current.loginFailureOrSuccessOption,
      listener: (context, state) {
        state.loginFailureOrSuccessOption.fold(() => null, (t) {
          t.fold(
            (failure) {
              // Handle account not verified - redirect to OTP
              if (failure is AccountNotVerifiedFailure) {
                context.router.push(
                  OtpRoute(phone: state.mobile),
                );
                return;
              }

              // Show generic error for other failures
              AppSnackbar.showErrorSnackbar(context, content: failure.message);
            },
            (user) {
              // Success handled elsewhere
            },
          );
        });
      },
      builder: (context, state) {
        return Form(
          autovalidateMode: state.showErrorMessages
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Mobile Number'),
              ),
              // Option 1: UAE-only phone input (simple, locked to UAE)
              // UaePhoneInput(
              //   onChanged: (value) => context.read<LoginBloc>().add(
              //     LoginMobileChangedEvent(value),
              //   ),
              // ),

              // Option 2: International phone input (supports multiple countries)
              InternationalPhoneInput(
                onChanged: (value) => context.read<LoginBloc>().add(
                  LoginMobileChangedEvent(value),
                ),
              ),
              const Space(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Password'),
              ),
              PasswordField(
                controller: passwordController,
                hintText: 'Enter password',
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text('Forgot Password'),
                ),
              ),
              const Space(3),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  // backgroundColor: AppColors.accent,
                  onPressed: () {
                    context.read<LoginBloc>().add(LoginSubmittedEvent());
                  },
                  isLoading: state.isSubmitting,
                  text: 'Login',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
