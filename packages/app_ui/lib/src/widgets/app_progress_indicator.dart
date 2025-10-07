import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class AppProgressIndicator extends StatelessWidget {
  const AppProgressIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const innerDotLength = 10.0;
    const factor = 2.2;
    const outerDotLength = innerDotLength * factor;

    const strokeWidth = 6.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        // const SizedBox(
        //   height: 38,
        //   width: 38,
        //   child: CircularProgressIndicator(
        //     color: AppColors.primary,
        //     strokeWidth: 6,
        //   ),
        // ),
        const SizedBox(
          height: outerDotLength,
          width: outerDotLength,
          child: CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: strokeWidth,
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
          width: innerDotLength,
          height: innerDotLength,
        ),
      ],
    );
  }
}
