import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/order_form/bloc/order_form_bloc.dart';
import 'package:homely_app/order_form/view/widgets/food_selection_bottom_sheet/food_selection_cubit.dart';
import 'package:homely_app/order_form/view/widgets/food_selection_bottom_sheet/widgets/food_item_tile.dart';
import 'package:homely_app/order_form/view/widgets/food_selection_bottom_sheet/widgets/food_selection_header.dart';
import 'package:homely_app/order_form/view/widgets/location_selection_bottom_sheet/location_selection_bottom_sheet.dart';

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
    return BlocProvider(
      create: (_) => FoodSelectionCubit(foodItems: foodItems),
      child: _FoodSelectionBottomSheetContent(
        mealType: mealType,
        selectedDay: selectedDay,
      ),
    );
  }
}

class _FoodSelectionBottomSheetContent extends StatefulWidget {
  const _FoodSelectionBottomSheetContent({
    required this.mealType,
    required this.selectedDay,
  });

  final MealType mealType;
  final dynamic selectedDay;

  @override
  State<_FoodSelectionBottomSheetContent> createState() =>
      _FoodSelectionBottomSheetContentState();
}

class _FoodSelectionBottomSheetContentState
    extends State<_FoodSelectionBottomSheetContent> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<FoodSelectionCubit>().updateSearchQuery(
      _searchController.text,
    );
  }

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
      child: BlocBuilder<FoodSelectionCubit, FoodSelectionState>(
        builder: (context, state) {
          return Column(
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
                mealType: widget.mealType,
                selectedDay: widget.selectedDay,
              ),
              const SizedBox(height: 8),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: _buildSearchBar(),
              ),
              Flexible(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8, bottom: 20),
                  itemCount: state.filteredFoodItems.isEmpty
                      ? 1
                      : state.filteredFoodItems.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    if (state.filteredFoodItems.isEmpty) {
                      return _buildEmptyState(state.searchQuery);
                    }
                    return FoodItemTile(
                      foodItem: state.filteredFoodItems[index],
                      mealType: widget.mealType,
                      onSelected: (foodItem) {
                        _handleFoodSelected(context, foodItem);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, code or cuisine',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.grey500,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.grey500,
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: AppColors.grey500,
                    size: 20,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    context.read<FoodSelectionCubit>().clearSearch();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String searchQuery) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 24), // Account for ListView top padding
        Icon(
          searchQuery.isNotEmpty ? Icons.search_off : Icons.restaurant,
          size: 48,
          color: AppColors.grey400,
        ),
        const SizedBox(height: 16),
        Text(
          searchQuery.isNotEmpty
              ? 'No food items found for "$searchQuery"'
              : 'No food items available',
          style: context.textTheme.bodyLarge?.copyWith(
            color: AppColors.grey600,
          ),
          textAlign: TextAlign.center,
        ),
        if (searchQuery.isNotEmpty) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              _searchController.clear();
              context.read<FoodSelectionCubit>().clearSearch();
            },
            child: Text(
              'Clear search',
              style: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.appGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24), // Account for ListView bottom padding
      ],
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
              mealType: widget.mealType,
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
          mealType: widget.mealType,
          foodItem: foodItem,
        ),
      ),
    );
  }
}
