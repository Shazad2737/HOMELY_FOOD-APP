import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/food_selection_bottom_sheet/food_selection_bottom_sheet.dart';
import 'package:instamess_app/order_form/view/widgets/meal_card/widgets/meal_selection_details.dart';
import 'package:instamess_app/order_form/view/helpers/meal_type_helper.dart';

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
    return BlocConsumer<OrderFormBloc, OrderFormState>(
      listenWhen: (previous, current) =>
          // Listen for errors or when this meal's bottom sheet should open
          (current.mealTapError != null &&
              previous.mealTapError != current.mealTapError) ||
          (current.activeBottomSheet == mealType &&
              previous.activeBottomSheet != current.activeBottomSheet),
      listener: (context, state) {
        final bloc = context.read<OrderFormBloc>();

        // Show error if there's one
        if (state.mealTapError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.mealTapError!),
              duration: const Duration(seconds: 2),
            ),
          );
          // Clear error immediately after showing so next tap can trigger
          Future.microtask(
            () => bloc.add(const OrderFormMealTapErrorClearedEvent()),
          );
        }

        // Open bottom sheet if this meal type is active
        if (state.activeBottomSheet == mealType) {
          final foodItems = state.getFoodItemsForMeal(mealType);
          final selectedDay = state.findDayByDate(state.selectedDate);
          if (foodItems.isNotEmpty && selectedDay != null) {
            _showFoodSelectionSheet(context, foodItems, selectedDay);
            // Clear active bottom sheet immediately after opening
            Future.microtask(
              () => bloc.add(const OrderFormBottomSheetClearedEvent()),
            );
          }
        }
      },
      buildWhen: (previous, current) =>
          previous.mealSelections[mealType] != current.mealSelections[mealType],
      builder: (context, state) {
        final selection = state.mealSelections[mealType];
        final isSelected = selection != null;

        return Semantics(
          selected: isSelected,
          enabled: isAvailable,
          label: MealTypeHelper.getMealLabel(mealType),
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
                          context.read<OrderFormBloc>().add(
                            OrderFormMealTappedEvent(mealType),
                          );
                        }
                      : () {
                          // Provide feedback when unavailable meal is tapped
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${MealTypeHelper.getMealLabel(mealType)} is not available for this date',
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
                            ? AppColors.appGreen.withOpacity(0.6)
                            : AppColors.grey200,
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            isSelected ? 0.10 : 0.06,
                          ),
                          blurRadius: isSelected ? 10 : 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MealTypeHelper.getMealIcon(
                                mealType,
                                isSelected: isSelected,
                                isAvailable: isAvailable,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  MealTypeHelper.getMealLabel(mealType),
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
                              // Delete button for selected meals
                              if (isSelected)
                                Material(
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
                                        color: AppColors.error.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
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
                                    child: Builder(
                                      builder: (context) {
                                        // Determine if the paired meal (if any) is also selected
                                        final paired =
                                            selection.food.deliverWith;
                                        final pairedMealSelected =
                                            paired != null &&
                                            state.mealSelections[paired.type] !=
                                                null;

                                        return MealSelectionDetails(
                                          selection: selection,
                                          pairedMealSelected:
                                              pairedMealSelected,
                                        );
                                      },
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
                                                    .withOpacity(0.7),
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
            ],
          ),
        );
      },
    );
  }

  Color _getBackgroundColor(bool isSelected, bool isAvailable) {
    if (!isAvailable) return AppColors.grey50;
    return AppColors.white;
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
}
