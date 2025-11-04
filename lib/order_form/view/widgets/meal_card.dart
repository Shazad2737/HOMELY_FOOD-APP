import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/food_selection_bottom_sheet.dart';

/// Card for selecting a meal type
class MealCard extends StatelessWidget {
  /// Constructor
  const MealCard({
    required this.mealType,
    required this.isAvailable,
    super.key,
  });

  /// The meal type
  final MealType mealType;

  /// Whether this meal is available for selected date
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      buildWhen: (previous, current) =>
          previous.mealSelections[mealType] != current.mealSelections[mealType],
      builder: (context, state) {
        final selection = state.mealSelections[mealType];
        final isSelected = selection != null;

        return Semantics(
          selected: isSelected,
          enabled: isAvailable,
          label: _getMealLabel(mealType),
          child: Stack(
            children: [
              // Card body with ripple + animated styling
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: isAvailable
                      ? () {
                          HapticFeedback.selectionClick();
                          debugPrint(
                            '🍽️ MealCard tapped: ${_getMealLabel(mealType)}, isAvailable: $isAvailable',
                          );
                          _handleTap(context, state);
                        }
                      : () {
                          // Provide feedback when unavailable meal is tapped
                          debugPrint(
                            '❌ Unavailable meal tapped: ${_getMealLabel(mealType)}',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${_getMealLabel(mealType)} is not available for this date',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(isSelected, isAvailable),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.appGreen.withValues(alpha: 0.6)
                            : AppColors.grey200,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isSelected ? 0.10 : 0.06,
                          ),
                          blurRadius: isSelected ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _getMealIcon(mealType, isSelected, isAvailable),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getMealLabel(mealType),
                                  style: context.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: isAvailable
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (!isAvailable)
                                const Icon(
                                  Icons.block,
                                  color: AppColors.textSecondary,
                                  size: 20,
                                ),
                            ],
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            switchInCurve: Curves.easeOut,
                            switchOutCurve: Curves.easeIn,
                            child: isSelected
                                ? Padding(
                                    key: const ValueKey('selected-details'),
                                    padding: const EdgeInsets.only(top: 12),
                                    child: _buildSelectionDetails(
                                      context,
                                      selection,
                                    ),
                                  )
                                : Padding(
                                    key: const ValueKey('not-selected-info'),
                                    padding: const EdgeInsets.only(top: 12),
                                    child: isAvailable
                                        ? Row(
                                            children: [
                                              Icon(
                                                Icons.add_circle_outline,
                                                size: 16,
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.7),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Tap to select meal',
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              const Icon(
                                                Icons.info_outline,
                                                size: 16,
                                                color: AppColors.textSecondary,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Not available for this date',
                                                style: context
                                                    .textTheme
                                                    .bodySmall
                                                    ?.copyWith(
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Delete button for selected meals
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<OrderFormBloc>().add(
                          OrderFormMealRemovedEvent(mealType),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionDetails(
    BuildContext context,
    OrderItemSelection selection,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Food image - larger, full width
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: selection.food.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: selection.food.imageUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 160,
                    color: AppColors.grey200,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant,
                        color: AppColors.grey400,
                        size: 48,
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 160,
                    color: AppColors.grey200,
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: AppColors.grey400,
                        size: 48,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 160,
                  color: AppColors.grey300,
                  child: const Center(
                    child: Icon(
                      Icons.restaurant,
                      color: AppColors.grey400,
                      size: 48,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 12),

        // Food name with code
        Text(
          selection.food.name,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // Food attributes
        if (selection.food.description != null)
          _buildAttributeRow(
            context,
            icon: Icons.restaurant_menu,
            text: selection.food.description!,
          ),
        if (selection.food.cuisine != null) ...[
          const SizedBox(height: 8),
          _buildAttributeRow(
            context,
            icon: Icons.restaurant,
            text: 'Cuisine: ${selection.food.cuisine!.displayName}',
          ),
        ],
        if (selection.food.style != null) ...[
          const SizedBox(height: 8),
          _buildAttributeRow(
            context,
            icon: Icons.kitchen,
            text: 'Style: ${selection.food.style!.displayName}',
          ),
        ],

        const SizedBox(height: 12),

        // Delivery mode and location/time pill — combine location and timing
        const SizedBox(height: 6),
        if (selection.food.deliveryMode == DeliveryMode.withOther &&
            selection.food.deliverWith != null)
          _buildLocationTimePill(
            context,
            leadingIcon: Icons.schedule,
            leadingText: 'Delivered with ${selection.food.deliverWith!.name}',
            trailingIcon: Icons.delivery_dining,
            trailingText: '5:00 PM - 6:00 PM',
            color: AppColors.success,
          )
        else if (selection.food.deliveryMode == DeliveryMode.separate)
          _buildLocationTimePill(
            context,
            leadingIcon: Icons.location_on,
            leadingText: selection.location.displayName,
            trailingIcon: Icons.delivery_dining,
            trailingText: '5:00 PM - 6:00 PM',
            color: AppColors.success,
          ),
      ],
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isAvailable) {
    // Use opaque backgrounds when a shadow is applied. For selected state
    // we keep the surface white and indicate selection via border + shadow
    if (!isAvailable) return AppColors.grey50;
    return AppColors.white;
  }

  Widget _getMealIcon(MealType type, bool isSelected, bool isAvailable) {
    final color = !isAvailable
        ? AppColors.grey500
        : (isSelected ? AppColors.appGreen : AppColors.appRed);
    IconData iconData;

    switch (type) {
      case MealType.breakfast:
        iconData = Icons.breakfast_dining;
      case MealType.lunch:
        iconData = Icons.lunch_dining;
      case MealType.dinner:
        iconData = Icons.dinner_dining;
    }

    return Icon(iconData, color: color, size: 28);
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

  void _handleTap(BuildContext context, OrderFormState state) {
    debugPrint('🔍 _handleTap called for ${_getMealLabel(mealType)}');

    final selectedDate = state.selectedDate;
    if (selectedDate == null) {
      // Show feedback if somehow tapped without date
      debugPrint('❌ No selected date');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date first')),
      );
      return;
    }

    debugPrint('✅ Selected date: $selectedDate');

    // Find available food items for this meal type
    // Handle both success and refreshing states
    final availableDays = state.availableDaysState;
    debugPrint(
      '📊 AvailableDays state - isSuccess: ${availableDays.isSuccess}, isRefreshing: ${availableDays.isRefreshing}',
    );

    if (!availableDays.isSuccess && !availableDays.isRefreshing) {
      debugPrint(
        '❌ Data not ready - isLoading: ${availableDays.isLoading}, isFailure: ${availableDays.isFailure}',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading available days...')),
      );
      return;
    }

    dynamic selectedDay;
    try {
      selectedDay = availableDays.maybeMap(
        success: (s) => s.data.days.firstWhere(
          (dynamic day) => day.date == selectedDate,
        ),
        refreshing: (r) => r.currentData.days.firstWhere(
          (dynamic day) => day.date == selectedDate,
        ),
        orElse: () => null,
      );
    } catch (e) {
      selectedDay = null;
    }

    if (selectedDay == null) {
      debugPrint('❌ Selected day not found in available days');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected date not found')),
      );
      return;
    }

    debugPrint('✅ Found selected day');

    // Get food items based on meal type
    List<FoodItem> foodItems;
    try {
      foodItems = switch (mealType) {
        MealType.breakfast => selectedDay.foodItems.breakfast as List<FoodItem>,
        MealType.lunch => selectedDay.foodItems.lunch as List<FoodItem>,
        MealType.dinner => selectedDay.foodItems.dinner as List<FoodItem>,
      };
      debugPrint('✅ Food items loaded: ${foodItems.length} items');
    } catch (e) {
      debugPrint('❌ Error loading food items: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading food items')),
      );
      return;
    }

    if (foodItems.isEmpty) {
      debugPrint('⚠️ No food items available for ${_getMealLabel(mealType)}');
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'No ${_getMealLabel(mealType).toLowerCase()} items available',
            ),
          ),
        );
      return;
    }

    debugPrint(
      '🎉 Opening food selection sheet with ${foodItems.length} items',
    );
    // Show food selection bottom sheet
    _showFoodSelectionSheet(context, foodItems, selectedDay);
  }

  void _showFoodSelectionSheet(
    BuildContext context,
    List<FoodItem> foodItems,
    dynamic selectedDay,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<OrderFormBloc>(),
        child: FoodSelectionBottomSheet(
          mealType: mealType,
          foodItems: foodItems,
          selectedDay: selectedDay,
        ),
      ),
    );
  }

  Widget _buildAttributeRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.grey600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.grey700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// Combined pill showing leading (location/paired meal) and trailing (time)
  Widget _buildLocationTimePill(
    BuildContext context, {
    required IconData leadingIcon,
    required String leadingText,
    required IconData trailingIcon,
    required String trailingText,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          // Leading (location or paired meal)
          Icon(leadingIcon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              leadingText,
              style: context.textTheme.bodySmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          // Vertical divider to visually connect time & location but keep them distinct
          Container(width: 1, height: 24, color: color.withValues(alpha: 0.16)),
          const SizedBox(width: 12),
          Icon(trailingIcon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            trailingText,
            style: context.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
