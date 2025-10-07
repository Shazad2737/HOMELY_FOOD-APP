/// Button widgets
library app_button;

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/typography/app_text_styles.dart';
import 'package:core/core.dart';
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
    this.foregroundColor = AppColors.white,
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
    final textStyle = this.textStyle ??
        AppTextStyles.titleMedium.copyWith(height: 1, color: foregroundColor);
    return IgnorePointer(
      ignoring: isLoading ?? false || isDisabled,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: foregroundColor,
          maximumSize: maxSize,
          backgroundColor: backgroundColor ?? AppColors.primary,
          padding: padding ?? const EdgeInsets.all(16),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: child ??
            () {
              if (text == null) {
                return const SizedBox();
              }
              final ts = textStyle;
              final textSize = TextUtils.getTextSize(
                text ?? '',
                ts,
              );

              return SizedBox(
                width: textSize.width + 16,
                child: Center(
                  child: Builder(
                    builder: (context) {
                      if (isLoading ?? false) {
                        print('is loading');
                        return SizedBox(
                          width: textSize.height,
                          height: textSize.height,
                          child: CircularProgressIndicator(
                            color: foregroundColor,
                          ),
                        );
                      }
                      return Text(
                        text!,
                        style: ts,
                      );
                    },
                  ),
                ),
              );
            }(),
      ),
    );
  }
}
