import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';
import 'package:instamess_app/order_form/view/widgets/food_selection_bottom_sheet/widgets/food_item_tile.dart';
import 'package:instamess_app/order_form/view/widgets/food_selection_bottom_sheet/widgets/food_selection_header.dart';
import 'package:instamess_app/order_form/view/widgets/location_selection_bottom_sheet/location_selection_bottom_sheet.dart';

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
          FoodSelectionHeader(
            mealType: mealType,
            selectedDay: selectedDay,
          ),
          const SizedBox(height: 8),
          const Divider(),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 8, bottom: 20),
              itemCount: foodItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return FoodItemTile(
                  foodItem: foodItems[index],
                  mealType: mealType,
                  onSelected: (foodItem) {
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
                'Using same location as ${pairedMealType.name}',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      // Paired meal not selected - show location picker
      Navigator.pop(context);
      _showLocationPicker(context, foodItem);
    } else {
      // SEPARATE delivery - always show location picker
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
