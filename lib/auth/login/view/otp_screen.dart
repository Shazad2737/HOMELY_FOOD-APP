import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/auth/login/bloc/otp_bloc.dart';
import 'package:instamess_app/router/router.gr.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class OtpPage extends StatelessWidget {
  const OtpPage({required this.phone, super.key});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OtpBloc(
        authFacade: context.read<IAuthFacade>(),
        mobile: phone,
      ),
      child: _OtpScreen(phone: phone),
    );
  }
}

class _OtpScreen extends StatefulWidget {
  const _OtpScreen({required this.phone});
  final String phone;

  @override
  State<_OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<_OtpScreen> {
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

    return BlocListener<OtpBloc, OtpState>(
      listenWhen: (previous, current) =>
          previous.verifyOtpOption != current.verifyOtpOption ||
          previous.resendOtpMessage != current.resendOtpMessage,
      listener: (context, state) {
        // Handle OTP verification result
        state.verifyOtpOption.fold(
          () => null,
          (either) => either.fold(
            (failure) {
              AppSnackbar.showErrorSnackbar(
                context,
                content: failure.message,
              );
            },
            (user) {
              // Successfully verified OTP, navigate to main app
              context.router.replaceAll([const MainShellRoute()]);
            },
          ),
        );

        // Handle resend OTP message
        state.resendOtpMessage.fold(
          () => null,
          (message) {
            AppSnackbar.showSuccessSnackbar(
              context,
              content: message,
            );
          },
        );
      },
      child: Scaffold(
        appBar: AppBar(),
        body: SafeArea(
          child: Padding(
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
                            'Verification',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'We have sent a code to your Number',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.85),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.phone,
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
                                context.read<OtpBloc>().add(
                                  OtpChangedEvent(value),
                                );
                              },
                              onCompleted: (_) {
                                // Auto-submit when all 6 digits are entered
                                context.read<OtpBloc>().add(
                                  const OtpSubmittedEvent(),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          BlocBuilder<OtpBloc, OtpState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: PrimaryButton(
                                  text: state.isSubmitting
                                      ? 'Verifying...'
                                      : 'Verify',
                                  onPressed: state.isSubmitting
                                      ? null
                                      : () {
                                          context.read<OtpBloc>().add(
                                            const OtpSubmittedEvent(),
                                          );
                                        },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                          BlocBuilder<OtpBloc, OtpState>(
                            builder: (context, state) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Didn't receive the OTP? ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: state.canResend
                                        ? () {
                                            context.read<OtpBloc>().add(
                                              const ResendOtpEvent(),
                                            );
                                          }
                                        : null,
                                    child: Text(
                                      state.resendCountdown > 0
                                          ? 'RESEND OTP (${state.resendCountdown}s)'
                                          : 'RESEND OTP',
                                    ),
                                  ),
                                ],
                              );
                            },
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
