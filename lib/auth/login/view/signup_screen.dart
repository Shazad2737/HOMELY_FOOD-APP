import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:instamess_app/router/router.gr.dart';

@RoutePage()
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

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
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Name'),
          ),
          TextFormField(
            decoration: const InputDecoration(
              hintText: 'Enter Name',
            ),
          ),
          const Space(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Mobile Number'),
          ),
          TextField(
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            decoration: const InputDecoration(
              hintText: 'Enter Mobile Number',
            ),
          ),
          const Space(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Password'),
          ),
          const PasswordField(
            hintText: 'Enter password',
          ),
          const Space(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Confirm Password'),
          ),
          const PasswordField(
            hintText: 'Enter Confirm password',
          ),
          const Space(3),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              onPressed: () {
                final phone = _phoneController.text.trim();
                if (phone.isEmpty) return;
                context.router.push(
                  OtpRoute(phone: phone),
                );
              },
              text: 'Sign Up',
            ),
          ),
        ],
      ),
    );
  }
}
