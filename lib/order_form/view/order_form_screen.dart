import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class OrderFormScreen extends StatefulWidget {
  const OrderFormScreen({super.key});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  // Selected meal state (breakfast, lunch, dinner)
  int?
  selectedMealIndex; // null means no selection, 0=breakfast, 1=lunch, 2=dinner

  // Selected date state
  int? selectedDateIndex;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Form'),

        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            // Date Selection Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date from below',
                    style: textTheme.bodyLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date chips
                  Row(
                    children: List.generate(7, (index) {
                      final isSelected = selectedDateIndex == index;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedDateIndex = index;
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.appRed
                                  : AppColors.appGreen,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _getDayLabel(index),
                                  style: textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  (20 + index).toString(),
                                  style: textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Meal Selection Cards
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                // Breakfast Card (Masala Dosa)
                _MealCard(
                  title: 'Masala Dosa B050',
                  subtitle: 'Chatny + Sambar + Vada',
                  description: 'Cuisine: Kerala',
                  style: 'Style: South Indian',
                  deliveryTime:
                      'Delivery is scheduled between 5:00 PM and 6:00 PM.',
                  isSelected: selectedMealIndex == 0,
                  onTap: () {
                    setState(() {
                      selectedMealIndex = 0;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Lunch Card
                _MealCard(
                  title: 'Select Lunch',
                  subtitle: '',
                  description: '',
                  style: '',
                  deliveryTime:
                      'Delivery is scheduled between 5:00 PM and 6:00 PM.',
                  isSelected: selectedMealIndex == 1,
                  onTap: () {
                    setState(() {
                      selectedMealIndex = 1;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // Dinner Card
                _MealCard(
                  title: 'Select Dinner',
                  subtitle: '',
                  description: '',
                  style: '',
                  deliveryTime:
                      'Delivery is scheduled between 5:00 PM and 6:00 PM.',
                  isSelected: selectedMealIndex == 2,
                  onTap: () {
                    setState(() {
                      selectedMealIndex = 2;
                    });
                  },
                ),
              ],
            ),

            // Order Button
            Container(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: selectedMealIndex != null ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.appRed,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'ORDER NOW',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayLabel(int index) {
    switch (index) {
      case 0:
        return 'MON';
      case 1:
        return 'TUE';
      case 2:
        return 'WED';
      case 3:
        return 'THU';
      case 4:
        return 'FRI';
      case 5:
        return 'SAT';
      case 6:
        return 'SUN';
      default:
        return '';
    }
  }
}

// Meal selection card widget
class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.style,
    required this.deliveryTime,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String description;
  final String style;
  final String deliveryTime;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: isSelected ? 8 : 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? const BorderSide(color: AppColors.appRed, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food image with favorite button
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Image(
                image: appImages.banner.provider(),
                fit: BoxFit.cover,
              ),
            ),

            // Food details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with favorite icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? AppColors.appRed
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.favorite,
                          color: AppColors.appRed,
                          size: 20,
                        ),
                    ],
                  ),

                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  if (description.isNotEmpty || style.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    if (description.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.restaurant,
                            color: AppColors.appRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              description,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (style.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.set_meal_outlined,
                            color: AppColors.appRed,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              style,
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 16),

                  // Delivery time with icon
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.appGreen.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: AppColors.textSecondary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deliveryTime,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.appGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
