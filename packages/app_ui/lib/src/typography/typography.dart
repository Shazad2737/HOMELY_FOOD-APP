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
}
