import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/view/widgets/day_chip.dart';
import 'package:instamess_app/menu/view/widgets/food_card/delivery_info_badge.dart';
import 'package:instamess_app/menu/view/widgets/food_card/dietary_badges.dart';
import 'package:instamess_app/menu/view/widgets/food_card/food_image.dart';
import 'package:instamess_app/menu/view/widgets/info_row.dart';

/// Food item card showing dish details with optional staggered animation
class MenuFoodCard extends StatefulWidget {
  const MenuFoodCard({
    required this.foodItem,
    this.index,
    this.isLast,
    super.key,
  });

  final FoodItem foodItem;
  final int? index;
  final bool? isLast;

  @override
  State<MenuFoodCard> createState() => _MenuFoodCardState();
}

class _MenuFoodCardState extends State<MenuFoodCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Only animate if index is provided
    if (widget.index != null) {
      // Stagger the animation based on index (max 50ms delay per item)
      final delay = (widget.index! * 50).clamp(0, 300);

      _fadeAnimation =
          Tween<double>(
            begin: 0,
            end: 1,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                delay / 700, // Convert delay to fraction of total animation
                1,
                curve: Curves.easeOut,
              ),
            ),
          );

      _slideAnimation =
          Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: _controller,
              curve: Interval(
                delay / 700,
                1,
                curve: Curves.easeOutCubic,
              ),
            ),
          );

      // Start animation after a frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image with veg badge
          FoodImage(foodItem: widget.foodItem),

          // Food details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and code
                Text(
                  '${widget.foodItem.name} (${widget.foodItem.code})',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Description
                if (widget.foodItem.description != null &&
                    widget.foodItem.description!.isNotEmpty) ...[
                  InfoRow(
                    icon: Icons.restaurant,
                    text: widget.foodItem.description!,
                    iconColor: AppColors.appRed,
                  ),
                ],

                // Cuisine
                if (widget.foodItem.cuisine != null)
                  InfoRow(
                    icon: Icons.location_on_outlined,
                    text: 'Cuisine: ${widget.foodItem.cuisine!.displayName}',
                    iconColor: AppColors.appRed,
                  ),

                // Style
                if (widget.foodItem.style != null)
                  InfoRow(
                    icon: Icons.set_meal_outlined,
                    text: 'Style: ${widget.foodItem.style!.displayName}',
                    iconColor: AppColors.appRed,
                  ),

                // Delivery mode info
                if (widget.foodItem.deliveryMode == DeliveryMode.withOther &&
                    widget.foodItem.deliverWith != null) ...[
                  const SizedBox(height: 12),
                  DeliveryInfoBadge(foodItem: widget.foodItem),
                ],

                const SizedBox(height: 12),

                // Days availability
                Row(
                  spacing: 8,
                  children: DayOfWeek.values.map((day) {
                    final isAvailable = widget.foodItem.isAvailableOn(day);
                    return DayChip(
                      label: day.shortName,
                      isAvailable: isAvailable,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Apply animation if index is provided
    if (widget.index != null) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: widget.isLast ?? false ? 8 : 16,
            ),
            child: card,
          ),
        ),
      );
    }

    // Return card without animation
    return card;
  }
}
