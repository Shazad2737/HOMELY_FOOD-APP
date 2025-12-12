import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/menu/bloc/menu_bloc.dart';

/// Compact horizontal chip-style plan selector for menu screen
class PlanSelector extends StatelessWidget {
  const PlanSelector({
    required this.plans,
    required this.selectedPlan,
    super.key,
  });

  final List<MenuPlan> plans;
  final MenuPlan? selectedPlan;

  @override
  Widget build(BuildContext context) {
    // NOTE: The "All Plans" toggle has been removed/disabled for now.
    // If needed in future, re-enable by adding an initial "All Plans" item.
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final plan = plans[index];
          final isSelected = selectedPlan?.id == plan.id;

          return _PlanChip(
            name: plan.name,
            isSelected: isSelected,
            onTap: () {
              context.read<MenuBloc>().add(
                MenuPlanSelectedEvent(plan: plan),
              );
            },
          );
        },
      ),
    );
  }
}

/// Compact plan chip widget
class _PlanChip extends StatelessWidget {
  const _PlanChip({
    required this.name,
    required this.isSelected,
    this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appOrange : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.appOrange : AppColors.grey300,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 16,
                  color: AppColors.white,
                ),
              ),
            Text(
              name,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.white : AppColors.grey700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
