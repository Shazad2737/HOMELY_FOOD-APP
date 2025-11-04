import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/view/widgets/meal_card.dart';

/// Section showing all meal cards
class MealCardsSection extends StatelessWidget {
  /// Constructor
  const MealCardsSection({
    required this.availableMealTypes,
    super.key,
  });

  /// Available meal types for selected date
  final List<MealType> availableMealTypes;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.restaurant_menu,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Choose Your Meals',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...MealType.values.map((mealType) {
          final isAvailable = availableMealTypes.contains(mealType);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MealCard(
              mealType: mealType,
              isAvailable: isAvailable,
            ),
          );
        }),
      ],
    );
  }
}
