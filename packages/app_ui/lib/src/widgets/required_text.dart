import 'package:flutter/material.dart';

/// A widget that displays text with a red asterisk at the end to indicate
/// that it is required.
class RequiredText extends StatelessWidget {
  /// Creates a [RequiredText] widget.
  const RequiredText(
    this.text, {
    super.key,
    this.style,
  });

  /// The text to display.
  final String text;

  /// The style to use for the text. Will use the theme's titleSmall style if not provided.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: text,
        style: style,
        children: [
          TextSpan(
            text: ' *',
            style: (style ?? const TextStyle()).copyWith(
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
