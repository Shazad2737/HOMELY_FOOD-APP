import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/view/widgets/categories/category_chip.dart';
import 'package:instamess_app/router/router.gr.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        const _TitleRow(),
        const SizedBox(height: 12),
        _CategorySelector(categories: categories),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    const width = 115.0;
    return SizedBox(
      height: width,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final category = categories[index];
          return CategoryChip(
            width: width,
            label: category.name ?? 'Category',
            image: category.imageUrl != null
                ? NetworkImage(category.imageUrl!)
                : appImages.foodRoundSmall1.provider(),
            onTap: () {
              context.router.push(MenuRoute(category: category));
            },
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: categories.length,
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  const _TitleRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Food Categories',
          style: context.textTheme.titleMedium,
        ),
        // const Spacer(),
        // ElevatedButton(
        //   onPressed: () {},

        //   style: ElevatedButton.styleFrom(
        //     visualDensity: const VisualDensity(
        //       horizontal: -4,
        //       vertical: -4,
        //     ),
        //     foregroundColor: AppColors.appOrangeDark,
        //     backgroundColor: AppColors.appOrangeDark.withValues(
        //       alpha: 0.3,
        //     ),
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadiusGeometry.circular(30),
        //     ),
        //     padding: const EdgeInsets.symmetric(
        //       horizontal: 12,
        //       vertical: 6,
        //     ),
        //   ),
        //   child: Text(
        //     'See All',
        //     style: context.textTheme.bodySmall?.semiBold.orange.copyWith(
        //       height: 1,
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
