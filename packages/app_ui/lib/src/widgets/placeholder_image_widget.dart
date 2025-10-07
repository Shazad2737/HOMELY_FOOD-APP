import 'dart:math' as math;

import 'package:app_ui/app_ui.dart';
import 'package:app_ui/src/colors/app_colors.dart' show AppColors;
import 'package:flutter/material.dart';

/// A placeholder image widget that shows a camera icon and a message.
class PlaceholderImageWidget extends StatelessWidget {
  /// Creates a [PlaceholderImageWidget].
  const PlaceholderImageWidget({
    super.key,
    this.backgroundColor,
  });

  /// The background color of the widget.
  ///
  /// If not provided, it defaults to [AppColors.skyBase].
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final errorColor = backgroundColor ?? AppColors.grey300;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Icon(
                  Icons.camera_alt,
                  color: errorColor,
                  size: 80,
                ),
              ),
              // strike through the icon
              Positioned(
                top: 44,
                left: 0,
                right: 0,
                child: Transform.rotate(
                  angle: math.pi / 5,
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: errorColor,
                      border: const Border(
                        top: BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // const Space(),
          Text(
            'No image available',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: errorColor,
                ),
          ),
        ],
      ),
    );
  }
}
