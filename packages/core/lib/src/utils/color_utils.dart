import 'dart:developer';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/widgets.dart';

/// HexColor
class ColorUtils {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional
  /// leading "#".
  static Color? fromHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      return null;
    }
  }
}

extension ColorX on Color {
  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  /// Returns a [Color] to be used on foreground of this color.
  /// If this is darker, returns [AppColors.white] and
  /// [AppColors.base100] otherwise
  Color getForegroundColor() {
    final color = this;

    // Counting the perceptive luminance - human eye favors green color...
    final luminance =
        (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;

    if (luminance > 0.55) {
      return AppColors.black;
    } else {
      return AppColors.white;
    }
  }

  /// Convert the color to a darker color based on the [percent]
  Color darken([int percent = 40]) {
    assert(1 <= percent && percent <= 100, 'Percent must be between 1 and 100');
    final value = 1 - percent / 100;
    return Color.fromARGB(
      alpha,
      (red * value).round(),
      (green * value).round(),
      (blue * value).round(),
    );
  }

  /// Convert the color to a lighter color based on the [percent]
  Color lighten([int percent = 40]) {
    assert(1 <= percent && percent <= 100, 'Percent must be between 1 and 100');
    final value = percent / 100;
    return Color.fromARGB(
      alpha,
      (red + ((255 - red) * value)).round(),
      (green + ((255 - green) * value)).round(),
      (blue + ((255 - blue) * value)).round(),
    );
  }
}
