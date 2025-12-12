import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

abstract class AppSnackbar {
  static void showSuccessSnackbar(
    BuildContext context, {
    required String content,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      _snackBar(
        content: content,
        action: action,
        backgroundColor: AppColors.success,
      ),
    );
  }

  static void showErrorSnackbar(
    BuildContext context, {
    required String content,
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        _snackBar(
          content: content,
          action: action,
          backgroundColor: AppColors.error,
        ),
      );
  }

  static SnackBar _snackBar({
    required String content,
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    return SnackBar(
      backgroundColor: backgroundColor,
      action: action,
      content: Text(content),
    );
  }
}
