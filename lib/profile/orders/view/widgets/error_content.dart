import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template error_content}
/// Widget displayed when there's an error loading orders
/// {@endtemplate}
class ErrorContent extends StatelessWidget {
  /// {@macro error_content}
  const ErrorContent({
    required this.message,
    required this.onRetry,
    super.key,
  });

  /// Error message to display
  final String message;

  /// Callback when retry button is pressed
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: context.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
