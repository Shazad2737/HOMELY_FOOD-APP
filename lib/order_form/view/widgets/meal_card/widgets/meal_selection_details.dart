import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/order_form/bloc/order_form_bloc.dart';

/// Displays selection details for a selected meal
class MealSelectionDetails extends StatelessWidget {
  /// Constructor
  const MealSelectionDetails({
    required this.selection,
    this.pairedMealSelected = false,
    super.key,
  });

  /// The meal selection
  final OrderItemSelection selection;

  /// Whether the meal this item is delivered with is also selected
  final bool pairedMealSelected;

  @override
  Widget build(BuildContext context) {
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
          '${selection.food.name} (${selection.food.code ?? '-'})',
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
          _AttributeRow(
            icon: Icons.restaurant_menu,
            text: selection.food.description!,
          ),
        if (selection.food.cuisine != null) ...[
          const SizedBox(height: 8),
          _AttributeRow(
            icon: Icons.restaurant,
            text: 'Cuisine: ${selection.food.cuisine}',
          ),
        ],
        if (selection.food.style != null) ...[
          const SizedBox(height: 8),
          _AttributeRow(
            icon: Icons.kitchen,
            text: 'Style: ${selection.food.style}',
          ),
        ],

        const SizedBox(height: 12),

        // Delivery mode and location/time pill
        const SizedBox(height: 6),
        if (selection.food.deliveryMode == DeliveryMode.withOther &&
            selection.food.deliverWith != null)
          (pairedMealSelected
              ? _DeliveryInfoPill(
                  leadingIcon: Icons.schedule,
                  leadingText:
                      'Delivered with ${selection.food.deliverWith!.name}',
                  trailingIcon: Icons.delivery_dining,
                  trailingText: selection.food.deliveryTime != null
                      ? selection.food.deliveryTime!.displayString
                      : 'N/A',
                  color: AppColors.success,
                )
              : _DeliveryInfoPill(
                  leadingIcon: Icons.location_on,
                  leadingText: selection.location.displayName,
                  trailingIcon: Icons.delivery_dining,
                  trailingText: selection.food.deliveryTime != null
                      ? selection.food.deliveryTime!.displayString
                      : 'N/A',
                  color: AppColors.success,
                ))
        else if (selection.food.deliveryMode == DeliveryMode.separate)
          _DeliveryInfoPill(
            leadingIcon: Icons.location_on,
            leadingText: selection.location.displayName,
            trailingIcon: Icons.delivery_dining,
            trailingText: selection.food.deliveryTime != null
                ? selection.food.deliveryTime!.displayString
                : 'N/A',
            color: AppColors.success,
          ),
      ],
    );
  }
}

class _AttributeRow extends StatelessWidget {
  const _AttributeRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
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
}

class _DeliveryInfoPill extends StatelessWidget {
  const _DeliveryInfoPill({
    required this.leadingIcon,
    required this.leadingText,
    required this.trailingIcon,
    required this.trailingText,
    required this.color,
  });

  final IconData leadingIcon;
  final String leadingText;
  final IconData trailingIcon;
  final String trailingText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.16)),
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
          // Vertical divider
          Container(
            width: 1,
            height: 24,
            color: color.withOpacity(0.16),
          ),
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
