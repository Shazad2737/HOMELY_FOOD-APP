import 'package:flutter/material.dart';

extension StringX on String {
  /// Converts the first character to uppercase
  String capitalize() {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word in a string
  String toTitleCase() {
    if (isEmpty) return '';
    final result = StringBuffer();
    var capitalizeNext = true;

    final trimmed = trim();

    for (var i = 0; i < trimmed.length; i++) {
      final char = trimmed[i];
      if (RegExp(r'[\s\-]').hasMatch(char)) {
        // If it's a space or hyphen, the next character should be capitalized.
        capitalizeNext = true;
        result.write(char);
      } else if (capitalizeNext) {
        // Capitalize this character.
        result.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        // Just add the character as it is.
        result.write(char.toLowerCase());
      }
    }

    return result.toString();
  }
}

extension StringToWidget on String {
  Widget toWidget({
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    bool? softWrap,
    TextOverflow? overflow,
    int? maxLines,
    StrutStyle? strutStyle,
    TextWidthBasis? textWidthBasis,
    TextHeightBehavior? textHeightBehavior,
    Key? key,
  }) {
    return Text(
      this,
      style: style,
      textAlign: textAlign,
      textDirection: textDirection,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      strutStyle: strutStyle,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      key: key,
    );
  }
}
