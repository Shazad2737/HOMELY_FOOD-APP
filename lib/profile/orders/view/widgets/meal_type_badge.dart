import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_api/src/user/models/meal_type.dart';

/// {@template meal_type_badge}
/// A badge widget displaying the meal type with an icon and color coding
/// {@endtemplate}
class MealTypeBadge extends StatelessWidget {
  /// {@macro meal_type_badge}
  const MealTypeBadge({
    required this.mealType,
    this.showTimeRange = true,
    this.isCompact = false,
    super.key,
  });

  /// The meal type to display
  final MealType mealType;

  /// Whether to show the time range
  final bool showTimeRange;

  /// Whether to use compact layout
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final config = _getMealConfig(mealType.type);

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: config.backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(config.icon, size: 14, color: config.iconColor),
            const SizedBox(width: 4),
            Text(
              mealType.name,
              style: context.textTheme.labelSmall?.copyWith(
                color: config.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: config.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: config.iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(config.icon, size: 16, color: config.iconColor),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mealType.name,
                style: context.textTheme.titleSmall?.copyWith(
                  color: config.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showTimeRange &&
                  mealType.startTime != null &&
                  mealType.endTime != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${mealType.startTime} - ${mealType.endTime}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: config.subtextColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  _MealTypeConfig _getMealConfig(MealTypeEnum type) {
    switch (type) {
      case MealTypeEnum.breakfast:
        return const _MealTypeConfig(
          icon: Icons.wb_sunny_outlined,
          backgroundColor: Color(0xFFFFF3E0), // Orange 50
          iconBackgroundColor: Color(0xFFFFE0B2), // Orange 100
          iconColor: Color(0xFFE65100), // Orange 900
          textColor: Color(0xFFE65100),
          subtextColor: Color(0xFFEF6C00),
          borderColor: Color(0xFFFFCC80), // Orange 200
        );
      case MealTypeEnum.lunch:
        return const _MealTypeConfig(
          icon: Icons.light_mode_outlined,
          backgroundColor: Color(0xFFE3F2FD), // Blue 50
          iconBackgroundColor: Color(0xFFBBDEFB), // Blue 100
          iconColor: Color(0xFF1565C0), // Blue 800
          textColor: Color(0xFF1565C0),
          subtextColor: Color(0xFF1976D2),
          borderColor: Color(0xFF90CAF9), // Blue 200
        );
      case MealTypeEnum.dinner:
        return const _MealTypeConfig(
          icon: Icons.nightlight_round_outlined,
          backgroundColor: Color(0xFFF3E5F5), // Purple 50
          iconBackgroundColor: Color(0xFFE1BEE7), // Purple 100
          iconColor: Color(0xFF6A1B9A), // Purple 800
          textColor: Color(0xFF6A1B9A),
          subtextColor: Color(0xFF7B1FA2),
          borderColor: Color(0xFFCE93D8), // Purple 200
        );
    }
  }
}

class _MealTypeConfig {
  const _MealTypeConfig({
    required this.icon,
    required this.backgroundColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.textColor,
    required this.subtextColor,
    required this.borderColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color textColor;
  final Color subtextColor;
  final Color borderColor;
}
