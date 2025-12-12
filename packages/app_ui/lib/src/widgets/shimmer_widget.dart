import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

export 'package:shimmer/shimmer.dart';

class ShimmerWidget extends StatelessWidget {
  const ShimmerWidget.rectangular({
    required this.width,
    required this.height,
    this.baseColor,
    this.highlightColor,
    this.containerColor,
    this.radius = 2,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  final Color? baseColor;
  final Color? highlightColor;

  final Color? containerColor;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Shimmer.fromColors(
        baseColor: baseColor ?? Colors.grey[300]!,
        highlightColor: highlightColor ?? Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: containerColor ?? AppColors.white,
            borderRadius: BorderRadius.circular(radius),
          ),
          width: width,
          height: height,
        ),
      ),
    );
  }
}
