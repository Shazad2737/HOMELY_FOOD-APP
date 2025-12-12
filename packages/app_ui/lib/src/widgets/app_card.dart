import 'dart:math';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.backgroundColor = AppColors.white,
    this.onTap,
    this.border,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 12,
    ),
    this.boxShadow,
    this.borderRadius = 12,
  });

  final Widget child;

  final Color backgroundColor;

  final VoidCallback? onTap;

  final BoxBorder? border;

  final EdgeInsetsGeometry padding;

  final List<BoxShadow>? boxShadow;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: AppColors.textPrimary.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
        border: border,
        borderRadius: BorderRadius.circular(
          borderRadius +
              (max(border?.bottom.width ?? 0, border?.top.width ?? 0)),
        ),
      ),
      // width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
