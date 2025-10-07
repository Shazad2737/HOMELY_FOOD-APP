import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showMaterialModalBottomSheet<T>(
      context: context,
      builder: builder,
      backgroundColor: AppColors.white,
      animationCurve: Curves.easeInOut,
      duration: const Duration(milliseconds: 500),
    );
  }
}
