import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:core/form_inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/auth/signup/bloc/signup_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';
import 'package:instamess_app/auth/delivery_address/bloc/delivery_address_bloc.dart';
import 'package:instamess_api/instamess_api.dart';

@RoutePage()
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  DeliveryAddressBloc? _deliveryBloc;
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      // Create the DeliveryAddressBloc once and keep it alive while the signup flow is active
      _deliveryBloc = DeliveryAddressBloc(
        cmsRepository: context.read<ICmsRepository>(),
        authFacade: context.read<IAuthFacade>(),
      )..add(DeliveryAddressLoadedEvent());
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _deliveryBloc?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provide the delivery bloc to the signup subtree so the same instance is reused
    return BlocProvider.value(
      value: _deliveryBloc!,
      child: const Scaffold(
        body: SafeArea(
          child: _MobileWidget(),
        ),
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
                      'Sign Up',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please sign up to get started',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _SignupForm(),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.8),
                              ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.router.replace(const LoginRoute());
                          },
                          child: const Text('LOGIN'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'By Continuing you agree instamess ',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w400,
                fontSize: 10,
                height: 1.5,
              ),

              children: [
                TextSpan(
                  text:
                      'Terms${kNonBreakingSpace}of${kNonBreakingSpace}services',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.black,
                  ),
                ),
                TextSpan(
                  text: ' and ',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
                TextSpan(
                  text: 'Privacy${kNonBreakingSpace}Policy',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.black,
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

class _SignupForm extends StatefulWidget {
  const _SignupForm();

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignupBloc, SignupState>(
      listenWhen: (previous, current) =>
          previous.signupState != current.signupState,
      listener: (context, state) {
        state.signupState.maybeMap(
          orElse: () => null,
          failure: (failure) {
            AppSnackbar.showErrorSnackbar(
              context,
              content: failure.failure.message,
            );
          },
          success: (_) {
            context.router.push(
              const DeliveryAddressRoute(),
            );
          },
        );
      },
      builder: (context, state) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: RequiredText(
                  'Name',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter Name',
                  errorText:
                      state.showErrorMessages && state.name.displayError != null
                      ? state.name.displayError!.message
                      : null,
                ),
                initialValue: state.name.value,
                onChanged: (value) => context.read<SignupBloc>().add(
                  SignupNameChangedEvent(value),
                ),
              ),
              const Space(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: RequiredText(
                  'Mobile Number',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              TextField(
                keyboardType: TextInputType.phone,
                onChanged: (value) => context.read<SignupBloc>().add(
                  SignupPhoneChangedEvent(value),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter Mobile Number',
                  errorText:
                      state.showErrorMessages &&
                          state.phone.displayError != null
                      ? state.phone.displayError!.message
                      : null,
                ),
              ),
              const Space(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: RequiredText(
                  'Password',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              PasswordField(
                onChanged: (value) {
                  context.read<SignupBloc>().add(
                    SignupPasswordChangedEvent(value),
                  );
                },
                hintText: 'Enter password',
                errorText:
                    state.showErrorMessages &&
                        state.password.displayError != null
                    ? state.password.displayError!.message
                    : null,
              ),
              const Space(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: RequiredText(
                  'Confirm Password',
                  style: context.textTheme.bodyMedium,
                ),
              ),
              PasswordField(
                onChanged: (value) {
                  context.read<SignupBloc>().add(
                    SignupConfirmPasswordChangedEvent(value),
                  );
                },
                hintText: 'Enter Confirm password',
                errorText:
                    state.showErrorMessages &&
                        state.confirmPassword.displayError != null
                    ? state.confirmPassword.displayError!.message
                    : null,
              ),
              const Space(3),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: state.isSubmitting
                      ? null
                      : () {
                          context.read<SignupBloc>().add(
                            SignupSubmittedEvent(),
                          );
                        },
                  text: state.isSubmitting ? 'Signing Up...' : 'Sign Up',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
