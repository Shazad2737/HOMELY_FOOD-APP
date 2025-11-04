import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/location_selection_bottom_sheet.dart';

/// Bottom sheet for selecting a food item
class FoodSelectionBottomSheet extends StatelessWidget {
  /// Constructor
  const FoodSelectionBottomSheet({
    required this.mealType,
    required this.foodItems,
    required this.selectedDay,
    super.key,
  });

  /// The meal type being selected
  final MealType mealType;

  /// Available food items for this meal
  final List<FoodItem> foodItems;

  /// The selected day data
  final dynamic selectedDay;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Select ${_getMealLabel(mealType)}',
                        style: context.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildDateContextChip(context),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: foodItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _FoodItemTile(
                  foodItem: foodItems[index],
                  mealType: mealType,
                  onSelected: (foodItem) {
                    // Don't pop here - let _handleFoodSelected handle it
                    _handleFoodSelected(context, foodItem);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateContextChip(BuildContext context) {
    if (selectedDay == null || selectedDay.date == null) {
      return const SizedBox.shrink();
    }

    final date = DateTime.parse(selectedDay.date as String);
    final dayName = _getDayName(date.weekday);
    final formattedDate = '${_getMonthName(date.month)} ${date.day}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            '$dayName, $formattedDate',
            style: context.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getMealLabel(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }

  void _handleFoodSelected(BuildContext context, FoodItem foodItem) {
    final bloc = context.read<OrderFormBloc>();

    // Check delivery mode
    if (foodItem.deliveryMode == DeliveryMode.withOther) {
      // WITH_OTHER delivery - check if paired meal is already selected
      final pairedMealType = foodItem.deliverWith?.type;

      if (pairedMealType != null) {
        final pairedSelection = bloc.state.mealSelections[pairedMealType];

        if (pairedSelection != null) {
          // Paired meal exists - auto-use its location
          // ignore: avoid_print
          print('🟢 WITH_OTHER mode - paired meal found, auto-using location');
          Navigator.pop(context);

          bloc.add(
            OrderFormFoodSelectedEvent(
              mealType: mealType,
              food: foodItem,
              location: pairedSelection.location,
            ),
          );

          // Show snackbar to inform user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Using same location as ${_getMealLabel(pairedMealType)}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      // Paired meal not selected - show location picker
      // ignore: avoid_print
      print('� WITH_OTHER mode - no paired meal, showing location picker');
      Navigator.pop(context);
      _showLocationPicker(context, foodItem);
    } else {
      // SEPARATE delivery - always show location picker
      // ignore: avoid_print
      print('� SEPARATE mode - showing location picker');
      Navigator.pop(context);
      _showLocationPicker(context, foodItem);
    }
  }

  void _showLocationPicker(BuildContext context, FoodItem foodItem) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<OrderFormBloc>(),
        child: LocationSelectionBottomSheet(
          mealType: mealType,
          foodItem: foodItem,
        ),
      ),
    );
  }
}

class _FoodItemTile extends StatelessWidget {
  const _FoodItemTile({
    required this.foodItem,
    required this.mealType,
    required this.onSelected,
  });

  final FoodItem foodItem;
  final MealType mealType;
  final void Function(FoodItem) onSelected;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        final selection = state.mealSelections[mealType];
        final isSelected = selection?.food.id == foodItem.id;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 4,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isSelected
                  ? const BorderSide(color: AppColors.appGreen, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              onTap: () => onSelected(foodItem),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food image
                  _buildImage(context),

                  // Food details
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title, code, and selection indicator
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${foodItem.name} (${foodItem.code})',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.appGreen,
                                size: 24,
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Description
                        if (foodItem.description != null) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.restaurant,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  foodItem.description!,
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],

                        // Cuisine
                        if (foodItem.cuisine != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Cuisine: ${foodItem.cuisine!.displayName}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        // Style
                        if (foodItem.style != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.set_meal_outlined,
                                size: 18,
                                color: AppColors.appRed,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Style: ${foodItem.style!.displayName}',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.grey700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // Dietary badges and price
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (foodItem.isVegetarian)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.eco,
                                      size: 14,
                                      color: AppColors.appGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Veg',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            if (foodItem.isVegetarian && foodItem.isVegan)
                              const SizedBox(width: 8),
                            if (foodItem.isVegan)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.appGreen.withValues(
                                    alpha: 0.2,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.park,
                                      size: 14,
                                      color: AppColors.appGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Vegan',
                                      style: context.textTheme.labelSmall
                                          ?.copyWith(
                                            color: AppColors.appGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),

                        // Delivery mode info
                        if (foodItem.deliveryMode == DeliveryMode.withOther &&
                            foodItem.deliverWith != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.info.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppColors.info.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Delivered with ${foodItem.deliverWith!.name}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 7,
      child: (foodItem.imageUrl != null)
          ? CachedNetworkImage(
              imageUrl: foodItem.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(
                color: AppColors.grey200,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return const ColoredBox(
      color: AppColors.grey200,
      child: Icon(
        Icons.restaurant_menu,
        size: 64,
        color: AppColors.grey500,
      ),
    );
  }
}
