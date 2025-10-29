import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/view/widgets/categories/category_chip.dart';
import 'package:instamess_app/menu/bloc/menu_bloc.dart';

/// Horizontal scrollable category selector for menu screen
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.categories,
    required this.selectedCategory,
    super.key,
  });

  final List<Category> categories;
  final Category? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory?.id == category.id;

          return CategoryChip(
            label: category.name ?? '',
            width: 110,
            isSelected: isSelected,
            image: category.imageUrl != null
                ? CachedNetworkImageProvider(category.imageUrl!)
                : appImages.banner.provider(),
            onTap: () {
              context.read<MenuBloc>().add(
                MenuCategorySelectedEvent(category: category),
              );
            },
          );
        },
      ),
    );
  }
}
