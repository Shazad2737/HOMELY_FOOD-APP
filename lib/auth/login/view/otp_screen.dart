import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:instamess_app/router/router.gr.dart';
import 'package:pinput/pinput.dart';

@RoutePage()
class OtpPage extends StatefulWidget {
  const OtpPage({required this.phone, super.key});
  final String phone;

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
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
      textStyle: AppTextStyles.titleMedium,
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Verification',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We have sent a code to your Number',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
              ),
              const SizedBox(height: 8),
              Text(
                widget.phone,
                textAlign: TextAlign.center,
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 24),
              Center(
                child: Pinput(
                  controller: _pinController,
                  focusNode: _focusNode,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedTheme,
                  onCompleted: (_) {},
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Verify',
                  onPressed: () {
                    // On success, redirect to main shell
                    context.router.replaceAll([const MainShellRoute()]);
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the OTP? ",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey600),
                  ),
                  TextButton(
                    onPressed: () {
                      // resend action stub
                    },
                    child: const Text('Resend OTP'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'By Continuing you agree instamess Terms of services and Privacy Policy',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
