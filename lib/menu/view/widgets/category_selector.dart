import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/home/view/widgets/categories/category_chip.dart';
import 'package:instamess_app/menu/bloc/menu_bloc.dart';

/// Horizontal scrollable category selector for menu screen
class CategorySelector extends StatefulWidget {
  const CategorySelector({
    required this.categories,
    required this.selectedCategory,
    super.key,
  });

  final List<Category> categories;
  final Category? selectedCategory;

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  late final ScrollController _scrollController;
  final Map<String, GlobalKey> _categoryKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _initializeCategoryKeys();

    // Scroll to selected category after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCategory(animate: false);
    });
  }

  @override
  void didUpdateWidget(CategorySelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize keys if categories changed
    if (oldWidget.categories.length != widget.categories.length) {
      _initializeCategoryKeys();
    }

    // Scroll to selected category when selection changes
    if (oldWidget.selectedCategory?.id != widget.selectedCategory?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedCategory(animate: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeCategoryKeys() {
    _categoryKeys.clear();
    for (final category in widget.categories) {
      if (category.id != null) {
        _categoryKeys[category.id!] = GlobalKey();
      }
    }
  }

  void _scrollToSelectedCategory({required bool animate}) {
    final selectedCategory = widget.selectedCategory;
    if (selectedCategory == null || selectedCategory.id == null) return;

    final key = _categoryKeys[selectedCategory.id!];
    if (key == null) return;

    // Wait a bit longer to ensure the widget is fully rendered
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted || !_scrollController.hasClients) return;

      final currentContext = key.currentContext;
      if (currentContext == null) return;

      final renderBox = currentContext.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) return;

      try {
        final position = renderBox.localToGlobal(Offset.zero).dx;
        final viewportWidth = MediaQuery.of(context).size.width;
        final itemWidth = renderBox.size.width;

        // Calculate the current scroll offset
        final currentOffset = _scrollController.offset;

        // Calculate the position of the item relative to the viewport
        final itemPositionInViewport =
            position - 16; // Account for left padding

        // Target: center the selected item
        final targetOffset =
            currentOffset +
            itemPositionInViewport -
            (viewportWidth / 2) +
            (itemWidth / 2);

        // Ensure we don't scroll beyond bounds
        final maxScrollExtent = _scrollController.position.maxScrollExtent;
        final minScrollExtent = _scrollController.position.minScrollExtent;
        final clampedOffset = targetOffset.clamp(
          minScrollExtent,
          maxScrollExtent,
        );

        if (animate) {
          _scrollController.animateTo(
            clampedOffset,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
          );
        } else {
          _scrollController.jumpTo(clampedOffset);
        }
      } catch (e) {
        // Silently handle any errors during scrolling calculation
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = widget.categories[index];
          final isSelected = widget.selectedCategory?.id == category.id;
          final categoryId = category.id;

          return CategoryChip(
            key: categoryId != null ? _categoryKeys[categoryId] : null,
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
