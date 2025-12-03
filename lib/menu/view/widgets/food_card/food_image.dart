import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/view/widgets/food_card/delivery_mode_overlay_badge.dart';
import 'package:instamess_app/menu/view/widgets/food_card/veg_badge.dart';

/// Displays the food item image with optional badge overlays.
class FoodImage extends StatelessWidget {
  const FoodImage({
    required this.foodItem,
    this.showDeliveryModeBadge = false,
    super.key,
  });

  final FoodItem foodItem;

  /// Whether to show the delivery mode badge on the image.
  /// Defaults to false for backward compatibility.
  final bool showDeliveryModeBadge;

  @override
  Widget build(BuildContext context) {
    final showDeliveryBadge =
        showDeliveryModeBadge &&
        foodItem.deliveryMode == DeliveryMode.withOther &&
        foodItem.deliverWith != null;

    return AspectRatio(
      aspectRatio: 16 / 7,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Food image
          if (foodItem.imageUrl != null)
            CachedNetworkImage(
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
          else
            _buildPlaceholder(),

          // Badges positioned at top
          if (foodItem.isVegetarian || showDeliveryBadge)
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                children: [
                  if (foodItem.isVegetarian) const VegBadge(),
                  if (foodItem.isVegetarian && showDeliveryBadge)
                    const SizedBox(width: 8),
                  if (showDeliveryBadge)
                    DeliveryModeOverlayBadge(
                      deliverWith: foodItem.deliverWith!,
                    ),
                ],
              ),
            ),
        ],
      ),
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
