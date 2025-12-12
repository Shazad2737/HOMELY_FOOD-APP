/// Button widgets
library app_button;

import 'package:flutter/material.dart';

/// {@template app_button_secondary}
/// Primary button with white text and primary background color
/// {@endtemplate}
class PrimaryButton extends StatelessWidget {
  /// Constructs a [PrimaryButton]
  const PrimaryButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.isLoading = false,
    this.foregroundColor,
    this.backgroundColor,
    this.isDisabled = false,
    this.maxSize,
    this.padding,
    this.textStyle,
  })  : assert(
          !(child != null && text != null),
          'Only one of child or text should be provided',
        ),
        assert(
          !(child == null && text == null),
          'Either child or text should be provided',
        );
  final EdgeInsets? padding;
  final Size? maxSize;

  final Color? foregroundColor;
  final Color? backgroundColor;

  /// Text to be displayed on the button
  /// This will be ignored if [child] is provided
  final String? text;

  /// Text style of [text]
  final TextStyle? textStyle;

  /// Callback to be called when the button is pressed
  final VoidCallback? onPressed;

  /// Whether the button is in loading state
  ///
  /// If true, the button will show a [CircularProgressIndicator]
  /// instead of the text
  ///
  /// This will be ignored if [child] is provided
  final bool? isLoading;

  /// Child of the button. If provided, [text] will be ignored
  /// and the child will be displayed instead
  final Widget? child;

  /// Whether the button is disabled. If true, the button will be disabled
  /// and the [onPressed] callback will not be called. Color will be grey
  ///
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resolvedTextStyle = textStyle ?? theme.textTheme.labelLarge;
    final resolvedForeground = foregroundColor ?? theme.colorScheme.onPrimary;

    final content = child ??
        (text != null
            ? _LoadingLabel(
                label: text!,
                style: resolvedTextStyle,
                isLoading: isLoading ?? false,
                textColor: resolvedForeground,
              )
            : const SizedBox.shrink());

    return FilledButton(
      style: ButtonStyle(
        foregroundColor: foregroundColor != null
            ? WidgetStatePropertyAll(resolvedForeground)
            : null,
        backgroundColor: backgroundColor != null
            ? WidgetStatePropertyAll(backgroundColor)
            : null,
        padding: WidgetStatePropertyAll(
          padding ?? const EdgeInsets.all(16),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(20),
          ),
        ),
        maximumSize: maxSize != null ? WidgetStatePropertyAll(maxSize) : null,
      ),
      onPressed: isDisabled || (isLoading ?? false) ? null : onPressed,
      child: content,
    );
  }
}

class _LoadingLabel extends StatelessWidget {
  const _LoadingLabel({
    required this.label,
    required this.style,
    required this.isLoading,
    required this.textColor,
  });

  final String label;
  final TextStyle? style;
  final bool isLoading;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Visibility(
          visible: !isLoading,
          maintainAnimation: true,
          maintainSize: true,
          maintainState: true,
          child: Text(
            label,
            style: (style ?? const TextStyle()).copyWith(color: textColor),
          ),
        ),
        if (isLoading)
          const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
      ],
    );
  }
}
