import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Chip with 2 states, selected and unselected
class AppFilterChip extends StatelessWidget {
  const AppFilterChip({
    required this.isSelected,
    required this.onSelected,
    this.title,
    this.child,
    super.key,
    this.selectedColor = AppColors.warning,
    this.selectedForegroundColor = AppColors.white,
    this.backgroundColor = AppColors.grey100,
    this.foregroundColor = AppColors.textPrimary,
  });

  final String? title;

  final Widget? child;

  final bool isSelected;

  final void Function(bool value) onSelected;

  /// Selected color
  final Color selectedColor;

  /// Color to use for the text and icon when the filter is selected
  final Color selectedForegroundColor;

  /// Background color used when the filter is not selected
  final Color backgroundColor;

  /// Foreground color used when the filter is not selected
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: child ??
          Text(
            title ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isSelected ? selectedForegroundColor : foregroundColor,
                ),
          ),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: selectedColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? selectedColor : backgroundColor,
        ),
      ),
      // backgroundColor: AppColors.base20,
      checkmarkColor: selectedForegroundColor,
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(16),
      // ),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 8,
      ),
    );
  }
}
