import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/auth/forgot_password/bloc/forgot_password_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordBloc(
        context.read<IAuthFacade>(),
      ),
      child: const ForgotPasswordScreen(),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: BlocConsumer<ForgotPasswordBloc, ForgotPasswordStateFull>(
        listener: (context, state) {
          state.submissionResult.fold(
            () {},
            (either) => either.fold(
              (failure) => AppSnackbar.showErrorSnackbar(
                context,
                content: failure.message,
              ),
              (message) {
                AppSnackbar.showSuccessSnackbar(
                  context,
                  content: message,
                );
                // Navigate to login after successful password reset
                if (state.step == ForgotPasswordStep.newPasswordInput) {
                  context.router.replaceAll([const LoginRoute()]);
                }
              },
            ),
          );
        },
        builder: (context, state) {
          // We can use a PageView or IndexedStack, or just conditional return.
          // Conditional return is easiest for now.
          switch (state.step) {
            case ForgotPasswordStep.mobileInput:
              return const _MobileInputView();
            case ForgotPasswordStep.otpInput:
              return const _OtpInputView();
            case ForgotPasswordStep.newPasswordInput:
              return const _NewPasswordInputView();
          }
        },
      ),
    );
  }
}

class _MobileInputView extends StatelessWidget {
  const _MobileInputView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ForgotPasswordBloc>().state;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter your mobile number to receive an OTP.',
            ),
            const SizedBox(height: 24),
            InternationalPhoneInput(
              onChanged: (value) => context.read<ForgotPasswordBloc>().add(
                ForgotPasswordMobileChanged(value),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Send OTP',
              isLoading: state.isLoading,
              onPressed: () {
                context.read<ForgotPasswordBloc>().add(
                  ForgotPasswordRequestOtpSubmitted(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpInputView extends StatefulWidget {
  const _OtpInputView();

  @override
  State<_OtpInputView> createState() => _OtpInputViewState();
}

class _OtpInputViewState extends State<_OtpInputView> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ForgotPasswordBloc>().state;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: context.textTheme.titleMedium,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border),
      ),
    );

    final focusedTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColors.accent, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 12,
          offset: Offset(0, 6),
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Verification',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter OTP sent to',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            state.mobile,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          Center(
            child: Pinput(
              controller: _pinController,
              focusNode: _focusNode,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedTheme,
              onChanged: (value) {
                context.read<ForgotPasswordBloc>().add(
                  ForgotPasswordOtpChanged(value),
                );
              },
              onCompleted: (String _) {
                context.read<ForgotPasswordBloc>().add(
                  ForgotPasswordVerifyOtpSubmitted(),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Verify',
            isLoading: state.isLoading,
            onPressed: () {
              context.read<ForgotPasswordBloc>().add(
                ForgotPasswordVerifyOtpSubmitted(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NewPasswordInputView extends StatefulWidget {
  const _NewPasswordInputView();

  @override
  State<_NewPasswordInputView> createState() => _NewPasswordInputViewState();
}

class _NewPasswordInputViewState extends State<_NewPasswordInputView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      context.read<ForgotPasswordBloc>().add(
        ForgotPasswordNewPasswordChanged(_controller.text),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ForgotPasswordBloc>().state;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Enter your new password'),
          const SizedBox(height: 24),
          PasswordField(
            controller: _controller,
            hintText: 'New Password',
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Reset Password',
            isLoading: state.isLoading,
            onPressed: () {
              context.read<ForgotPasswordBloc>().add(
                ForgotPasswordResetSubmitted(),
              );
            },
          ),
        ],
      ),
    );
  }
}
