import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:homely_api/homely_api.dart';
import 'package:homely_app/menu/bloc/menu_bloc.dart';
import 'package:homely_app/menu/view/widgets/category_selector.dart';
import 'package:homely_app/menu/view/widgets/empty_state.dart';
import 'package:homely_app/menu/view/widgets/food_card/food_card.dart';
import 'package:homely_app/menu/view/widgets/plan_selector.dart';
import 'package:homely_app/menu/view/widgets/sticky_tab_bar_delegate.dart';

@RoutePage()
class MenuScreen extends StatelessWidget {
  const MenuScreen({
    this.category,
    super.key,
  });

  final Category? category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuBloc(
        menuRepository: context.read<IMenuRepository>(),
        cmsRepository: context.read<ICmsRepository>(),
        initialCategory: category,
      )..add(MenuInitializedEvent()),
      child: const _MenuView(),
    );
  }
}

/// Main view that routes to the appropriate content based on menu state.
class _MenuView extends StatelessWidget {
  const _MenuView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MenuBloc, MenuState>(
        buildWhen: (previous, current) =>
            previous.menuState.runtimeType != current.menuState.runtimeType,
        builder: (context, state) {
          return state.menuState.map(
            initial: (_) => const _MenuInitialContent(),
            loading: (_) => const _MenuLoadingContent(),
            success: (s) => _MenuSuccessContent(menuData: s.data),
            failure: (f) => _MenuFailureContent(failure: f.failure),
            refreshing: (r) => _MenuSuccessContent(
              menuData: r.currentData,
              isRefreshing: true,
            ),
          );
        },
      ),
    );
  }
}

/// AppBar used across all menu states.
class _MenuAppBar extends StatelessWidget {
  const _MenuAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      title: Text(
        'Menu',
        style: context.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      pinned: true,
    );
  }
}

/// Initial state content — prompts user to select a category.
class _MenuInitialContent extends StatelessWidget {
  const _MenuInitialContent();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _MenuAppBar(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: MenuEmptyState(
            message: 'Select a category to view menu',
            icon: Icons.category,
          ),
        ),
      ],
    );
  }
}

/// Loading state content.
class _MenuLoadingContent extends StatelessWidget {
  const _MenuLoadingContent();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        _MenuAppBar(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}

/// Failure state content with retry button.
class _MenuFailureContent extends StatelessWidget {
  const _MenuFailureContent({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const _MenuAppBar(),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    failure.message,
                    style: context.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MenuBloc>().add(MenuRefreshedEvent());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Success state content — shows categories, plans, tabs, search, and food items.
class _MenuSuccessContent extends StatefulWidget {
  const _MenuSuccessContent({
    required this.menuData,
    this.isRefreshing = false,
  });

  final MenuData menuData;
  final bool isRefreshing;

  @override
  State<_MenuSuccessContent> createState() => _MenuSuccessContentState();
}

class _MenuSuccessContentState extends State<_MenuSuccessContent>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _lastCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final mealType = MealType.values[_tabController.index];
    context.read<MenuBloc>().add(MenuMealTypeSelectedEvent(mealType: mealType));
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<MenuBloc>()..add(MenuRefreshedEvent());
    await bloc.stream.firstWhere((s) => !s.isRefreshing && !s.isLoading);
  }

  void _resetScrollOnCategoryChange(String? currentCategoryId) {
    if (_lastCategoryId != null && _lastCategoryId != currentCategoryId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
    }
    _lastCategoryId = currentCategoryId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MenuBloc, MenuState, String?>(
      selector: (state) => state.selectedCategory?.id,
      builder: (context, selectedCategoryId) {
        _resetScrollOnCategoryChange(selectedCategoryId);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const _MenuAppBar(),
              const _CategorySelectorSliver(),
              _PlanSelectorSliver(menuData: widget.menuData),
              _MealTypeTabBar(tabController: _tabController),
              _SearchBarSliver(isRefreshing: widget.isRefreshing),
              _FoodItemsSliver(menuData: widget.menuData),
            ],
          ),
        );
      },
    );
  }
}

/// Category selector wrapped in a sliver.
class _CategorySelectorSliver extends StatelessWidget {
  const _CategorySelectorSliver();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      MenuBloc,
      MenuState,
      ({List<Category> categories, Category? selected})
    >(
      selector: (state) =>
          (categories: state.categories, selected: state.selectedCategory),
      builder: (context, data) {
        if (data.categories.isEmpty) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        return SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CategorySelector(
              categories: data.categories,
              selectedCategory: data.selected,
            ),
          ),
        );
      },
    );
  }
}

/// Plan selector wrapped in a sliver.
class _PlanSelectorSliver extends StatelessWidget {
  const _PlanSelectorSliver({required this.menuData});

  final MenuData menuData;

  @override
  Widget build(BuildContext context) {
    if (menuData.availablePlans.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return BlocSelector<MenuBloc, MenuState, MenuPlan?>(
      selector: (state) => state.selectedPlan,
      builder: (context, selectedPlan) {
        return SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PlanSelector(
                plans: menuData.availablePlans,
                selectedPlan: selectedPlan,
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

/// Meal type tab bar (Breakfast / Lunch / Dinner).
class _MealTypeTabBar extends StatelessWidget {
  const _MealTypeTabBar({required this.tabController});

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        TabBar(
          controller: tabController,
          labelColor: AppColors.appRed,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.appRed,
          labelStyle: context.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: context.textTheme.titleSmall,
          tabs: const [
            Tab(text: 'Breakfast'),
            Tab(text: 'Lunch'),
            Tab(text: 'Dinner'),
          ],
        ),
      ),
    );
  }
}

/// Search bar sliver with optional refreshing indicator.
class _SearchBarSliver extends StatefulWidget {
  const _SearchBarSliver({this.isRefreshing = false});

  final bool isRefreshing;

  @override
  State<_SearchBarSliver> createState() => _SearchBarSliverState();
}

class _SearchBarSliverState extends State<_SearchBarSliver> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<MenuBloc>().add(
      MenuSearchQueryChangedEvent(query: _controller.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppDims.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SearchTextField(controller: _controller),
            if (widget.isRefreshing) ...[
              const SizedBox(height: 8),
              const _RefreshingIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}

/// Search text field widget.
class _SearchTextField extends StatelessWidget {
  const _SearchTextField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey900.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search by name, code or cuisine',
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: AppColors.grey500,
          ),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey500),
          suffixIcon: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              if (controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.clear, color: AppColors.grey500),
                onPressed: controller.clear,
              );
            },
          ),
          filled: true,
          fillColor: AppColors.white,
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(100)),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}

/// Linear progress indicator shown during refresh.
class _RefreshingIndicator extends StatelessWidget {
  const _RefreshingIndicator();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: const LinearProgressIndicator(
        minHeight: 3,
        valueColor: AlwaysStoppedAnimation(AppColors.appRed),
        backgroundColor: AppColors.grey200,
      ),
    );
  }
}

/// Food items list sliver — shows items or empty state.
class _FoodItemsSliver extends StatelessWidget {
  const _FoodItemsSliver({required this.menuData});

  final MenuData menuData;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MenuBloc, MenuState, (MealType, String)>(
      selector: (state) => (state.selectedMealType, state.searchQuery),
      builder: (context, data) {
        final (mealType, searchQuery) = data;
        final items = menuData.getItemsForMealType(mealType);

        if (items.isEmpty) {
          return _EmptyResultsSliver(hasSearchQuery: searchQuery.isNotEmpty);
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDims.screenPadding,
          ),
          sliver: SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return MenuFoodCard(
                key: ValueKey('food_${item.id}'),
                index: index,
                isLast: index == items.length - 1,
                foodItem: item,
              );
            },
          ),
        );
      },
    );
  }
}

/// Empty results sliver.
class _EmptyResultsSliver extends StatelessWidget {
  const _EmptyResultsSliver({required this.hasSearchQuery});

  final bool hasSearchQuery;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: MenuEmptyState(
        message: hasSearchQuery ? 'No items found' : 'No items available',
        icon: hasSearchQuery
            ? Icons.search_off
            : Icons.restaurant_menu_outlined,
        // Note: clearing search would require access to the controller;
        // consider lifting state or using a callback if needed.
      ),
    );
  }
}
