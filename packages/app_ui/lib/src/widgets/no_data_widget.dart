import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// {@template no_data_widget}
/// A widget to display when there's no data to show
/// {@endtemplate}
class NoDataWidget extends StatelessWidget {
  /// {@macro no_data_widget}
  const NoDataWidget({
    this.title,
    this.message,
    this.icon,
    super.key,
  });

  /// Title text
  final String? title;

  /// Message text
  final String? message;

  /// Icon to display
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.grey200,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  icon ?? Icons.search_off,
                  size: 48,
                  color: AppColors.grey500,
                ),
              ),
            ),
            if (title != null) ...[
              const SizedBox(height: 24),
              Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
