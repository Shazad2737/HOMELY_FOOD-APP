import 'package:flutter/widgets.dart';

/// Utility functions for working with [Text]
abstract class TextUtils {
  /// Returns the size of a [Text] widget with the given [text] and [style]
  static Size getTextSize(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}
