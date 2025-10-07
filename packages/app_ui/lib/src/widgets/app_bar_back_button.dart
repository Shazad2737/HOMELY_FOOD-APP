import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppBarBackButton extends StatelessWidget {
  const AppBarBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: IconButton(
        icon: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          // padding: const EdgeInsets.all(13),
          child: const Center(
            child: Icon(
              Icons.chevron_left,
              color: AppColors.primary,
              size: 30,
            ),
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
