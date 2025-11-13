import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/view/widgets/food_card/veg_badge.dart';

/// Displays the food item image with an optional vegetarian badge overlay.
class FoodImage extends StatelessWidget {
  const FoodImage({
    required this.foodItem,
    super.key,
  });

  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
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

          // Veg badge positioned at top left
          if (foodItem.isVegetarian) const VegBadge(),
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
