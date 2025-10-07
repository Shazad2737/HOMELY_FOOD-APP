import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_app/auth/login/bloc/login_bloc.dart';

@RoutePage()
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.widthOf(context) > 600;

    return Scaffold(
      body: SafeArea(
        child: isWide ? const _TabWidget() : const _MobileWidget(),
      ),
    );
  }
}

class _MobileWidget extends StatelessWidget {
  const _MobileWidget();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login to continue',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const _LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabWidget extends StatelessWidget {
  const _TabWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 81, 105, 133),
                  Color.fromARGB(255, 22, 165, 213),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.store_mall_directory_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please login to continue',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),

        // DIVIDER
        Container(
          width: 1,
          color: Colors.grey.shade300,
          margin: const EdgeInsets.symmetric(vertical: 40),
        ),

        // RIGHT SIDE - FORM
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      const _LoginForm(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
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
            (l) => AppSnackbar.showErrorSnackbar(context, content: l.message),
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
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
                initialValue: state.username,
                onChanged: (value) => context.read<LoginBloc>().add(
                  LoginUserNameChangedEvent(value),
                ),
              ),
              const Space(2),
              PasswordField(
                controller: passwordController,
                hintText: 'Password',
              ),
              const Space(3),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  onPressed: () {
                    context.read<LoginBloc>().add(LoginSubmittedEvent());
                  },
                  isLoading: state.isSubmitting,
                  text: 'Sign In',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
