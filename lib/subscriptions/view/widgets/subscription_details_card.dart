import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';

/// {@template subscription_details_card}
/// A card widget that displays detailed subscription information
/// {@endtemplate}
class SubscriptionDetailsCard extends StatelessWidget {
  /// {@macro subscription_details_card}
  const SubscriptionDetailsCard({
    required this.subscription,
    super.key,
  });

  /// The subscription information to display
  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusHeader(subscription: subscription),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PlanAndCategorySection(subscription: subscription),
                const SizedBox(height: 12),
                _DateSection(subscription: subscription),
                const SizedBox(height: 12),
                _MealTypesSection(subscription: subscription),
                if (subscription.notes != null &&
                    subscription.notes!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _NotesSection(notes: subscription.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.subscription});

  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    final isActive = subscription.isActive;
    final statusColor = isActive ? AppColors.success : AppColors.appRed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.info_outline,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                subscription.effectiveStatusDisplayName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (isActive &&
              subscription.remainingDays != null &&
              subscription.remainingDays! > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${subscription.remainingDays} days left',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PlanAndCategorySection extends StatelessWidget {
  const _PlanAndCategorySection({required this.subscription});

  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoItem(
            icon: Icons.workspace_premium_outlined,
            label: 'Plan',
            value: subscription.plan.name,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoItem(
            icon: Icons.restaurant_menu_outlined,
            label: 'Category',
            value: subscription.category.name,
          ),
        ),
      ],
    );
  }
}

class _DateSection extends StatelessWidget {
  const _DateSection({required this.subscription});

  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InfoItem(
            icon: Icons.event_outlined,
            label: 'Start Date',
            value: subscription.formattedStartDate,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoItem(
            icon: Icons.event_available_outlined,
            label: 'End Date',
            value: subscription.formattedEndDate,
          ),
        ),
      ],
    );
  }
}

class _MealTypesSection extends StatelessWidget {
  const _MealTypesSection({required this.subscription});

  final SubscriptionInfo subscription;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lunch_dining_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Subscribed Meals',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subscription.mealTypes.map((mealType) {
            return _MealTypeChip(mealType: mealType);
          }).toList(),
        ),
      ],
    );
  }
}

class _MealTypeChip extends StatelessWidget {
  const _MealTypeChip({required this.mealType});

  final SubscriptionMealType mealType;

  @override
  Widget build(BuildContext context) {
    final icon = _getMealIcon(mealType.type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            mealType.name,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String type) {
    switch (type.toUpperCase()) {
      case 'BREAKFAST':
        return Icons.free_breakfast_outlined;
      case 'LUNCH':
        return Icons.lunch_dining_outlined;
      case 'DINNER':
        return Icons.dinner_dining_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }
}

class _NotesSection extends StatelessWidget {
  const _NotesSection({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_outlined,
                size: 18,
                color: AppColors.warning,
              ),
              const SizedBox(width: 8),
              Text(
                'Notes',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(),
      // decoration: BoxDecoration(
      //   color: AppColors.grey100,
      //   borderRadius: BorderRadius.circular(12),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
