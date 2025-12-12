import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

export 'app_text_styles.dart';

extension TextStyleHelpers on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);

  // colors
  TextStyle get red => copyWith(color: AppColors.appRed);
  TextStyle get orange => copyWith(color: AppColors.appOrange);
  TextStyle get orangeDark => copyWith(color: AppColors.appOrangeDark);
  TextStyle get white => copyWith(color: AppColors.white);
  TextStyle get black => copyWith(color: AppColors.black);
  TextStyle get grey600 => copyWith(color: AppColors.grey600);
}

extension BuildContextTextTheme on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
  // Combined semantic+size getters (use these: ts<Semantic><Size>)
  // Display styles
  TextStyle get tsDisplayLarge48 => textTheme.displayLarge ?? const TextStyle();

  TextStyle get tsDisplayMedium36 =>
      textTheme.displayMedium ?? const TextStyle();

  TextStyle get tsDisplaySmall30 => textTheme.displaySmall ?? const TextStyle();

  // Headline styles
  TextStyle get tsHeadlineLarge28 =>
      textTheme.headlineLarge ?? const TextStyle();

  TextStyle get tsHeadlineMedium24 =>
      textTheme.headlineMedium ?? const TextStyle();

  // Title styles
  TextStyle get tsTitleLarge22 => textTheme.titleLarge ?? const TextStyle();

  TextStyle get tsTitleMedium18 => textTheme.titleMedium ?? const TextStyle();

  TextStyle get tsTitleSmall16 => textTheme.titleSmall ?? const TextStyle();

  // Body styles
  TextStyle get tsBodyLarge16 => textTheme.bodyLarge ?? const TextStyle();

  TextStyle get tsBodyMedium14 => textTheme.bodyMedium ?? const TextStyle();

  TextStyle get tsBodySmall12 => textTheme.bodySmall ?? const TextStyle();

  // Label styles
  TextStyle get tsLabelLarge14 => textTheme.labelLarge ?? const TextStyle();

  TextStyle get tsLabelMedium12 => textTheme.labelMedium ?? const TextStyle();

  TextStyle get tsLabelSmall11 => textTheme.labelSmall ?? const TextStyle();
}
