import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:homely_app/order_form/view/widgets/calendar_section/widgets/date_chip.dart';
import 'package:homely_api/src/user/models/models.dart' as user_models;

/// Calendar section with date chips
class CalendarSection extends StatelessWidget {
  /// Constructor
  const CalendarSection({
    required this.days,
    super.key,
  });

  /// List of available days
  final List<user_models.OrderDay> days;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Select Date',
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 88,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              physics: const BouncingScrollPhysics(),
              cacheExtent: 500, // Cache 500 pixels ahead for smooth scrolling
              itemBuilder: (context, index) {
                return DateChip(
                  day: days[index],
                  key: ValueKey(days[index].date),
                );
              },
            ),
          ),
          // if (days.length > 10)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 8),
          //     child: Row(
          //       children: [
          //         const Icon(
          //           Icons.swipe,
          //           size: 14,
          //           color: AppColors.textSecondary,
          //         ),
          //         const SizedBox(width: 4),
          //         Text(
          //           'Swipe to see more dates',
          //           style: context.textTheme.labelSmall?.copyWith(
          //             color: AppColors.textSecondary,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
