import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/menu/bloc/menu_bloc.dart';
import 'package:instamess_app/menu/view/widgets/category_selector.dart';
import 'package:instamess_app/menu/view/widgets/empty_state.dart';
import 'package:instamess_app/menu/view/widgets/food_card.dart';
import 'package:instamess_app/menu/view/widgets/plan_selector.dart';
import 'package:instamess_app/menu/view/widgets/sticky_tab_bar_delegate.dart';

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
      child: const MenuView(),
    );
  }
}

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final mealType = _getMealTypeFromIndex(_tabController.index);
        context.read<MenuBloc>().add(
          MenuMealTypeSelectedEvent(mealType: mealType),
        );
      }
    });

    _searchController.addListener(() {
      context.read<MenuBloc>().add(
        MenuSearchQueryChangedEvent(query: _searchController.text),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  MealType _getMealTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return MealType.breakfast;
      case 1:
        return MealType.lunch;
      case 2:
        return MealType.dinner;
      default:
        return MealType.breakfast;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          return state.menuState.map(
            initial: (_) => _buildInitialState(context),
            loading: (_) => _buildLoadingState(context),
            success: (s) => _buildSuccessState(context, s.data),
            failure: (f) => _buildFailureState(context, f.failure),
            refreshing: (r) => _buildSuccessState(
              context,
              r.currentData,
              isRefreshing: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          _buildHeader(context),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: MenuEmptyState(
              message: 'Select a category to view menu',
              icon: Icons.category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          _buildHeader(context),
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    MenuData menuData, {
    bool isRefreshing = false,
  }) {
    final bloc = context.read<MenuBloc>();
    final state = bloc.state;
    final items = state.filteredItems;

    return SafeArea(
      top: false,
      child: RefreshIndicator(
        onRefresh: () async {
          bloc.add(MenuRefreshedEvent());
          await bloc.stream.firstWhere((s) => !s.isRefreshing && !s.isLoading);
        },
        child: CustomScrollView(
          slivers: [
            _buildHeader(context),
            _buildCategorySelector(context),
            _buildPlanSelector(context, menuData),
            _buildTabBar(context, menuData),
            _buildSearchBar(context),

            if (items.isEmpty)
              _buildEmptyResultsSliver(context)
            else
              _buildFoodItemsList(context, items),
          ],
        ),
      ),
    );
  }

  Widget _buildFailureState(BuildContext context, Failure failure) {
    return SafeArea(
      top: false,
      child: CustomScrollView(
        slivers: [
          _buildHeader(context),
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
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenWidth = MediaQuery.of(context).size.width;
    // Calculate height based on aspect ratio
    final aspectRatioHeight = screenWidth / (16 / 4);
    // Ensure minimum height to clear notch with some visible content
    final baseHeight = aspectRatioHeight > topPadding + 40
        ? aspectRatioHeight
        : topPadding + 60;

    return SliverToBoxAdapter(
      child: SizedBox(
        height: baseHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Banner image - extends above to fill behind the notch
            Positioned(
              top: -topPadding, // Extend image upward behind notch
              left: 0,
              right: 0,
              bottom: 0,
              child: Image(
                image: appImages.menuHeader.provider(),
                fit: BoxFit.cover,
              ),
            ),
            // menu text - positioned at bottom of visible area
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Text(
                'Menu',
                textAlign: TextAlign.center,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: AppColors.black.withValues(alpha: 0.6),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final menuBloc = context.read<MenuBloc>();
    final categories = menuBloc.state.categories;
    final selectedCategory = menuBloc.state.selectedCategory;

    if (categories.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CategorySelector(
          categories: categories,
          selectedCategory: selectedCategory,
        ),
      ),
    );
  }

  Widget _buildPlanSelector(BuildContext context, MenuData menuData) {
    final selectedPlan = context.read<MenuBloc>().state.selectedPlan;

    if (menuData.availablePlans.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          //   child: Text(
          //     'Plans',
          //     style: context.textTheme.titleMedium?.copyWith(
          //       fontWeight: FontWeight.w600,
          //       color: AppColors.grey700,
          //     ),
          //   ),
          // ),
          PlanSelector(
            plans: menuData.availablePlans,
            selectedPlan: selectedPlan,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, MenuData menuData) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyTabBarDelegate(
        TabBar(
          controller: _tabController,
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

  Widget _buildSearchBar(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppDims.screenPadding),
        child: Container(
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
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'What do you want to eat?',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: AppColors.grey500,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.grey500,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: AppColors.grey500,
                      ),
                      onPressed: _searchController.clear,
                    )
                  : null,
              filled: true,
              fillColor: AppColors.white,
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(style: BorderStyle.none),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(style: BorderStyle.none),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(100)),
                borderSide: BorderSide(style: BorderStyle.none),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResultsSliver(BuildContext context) {
    final hasSearchQuery = _searchController.text.isNotEmpty;

    return SliverFillRemaining(
      hasScrollBody: false,
      child: MenuEmptyState(
        message: hasSearchQuery ? 'No items found' : 'No items available',
        icon: hasSearchQuery
            ? Icons.search_off
            : Icons.restaurant_menu_outlined,
        action: hasSearchQuery ? _searchController.clear : null,
        actionLabel: hasSearchQuery ? 'Clear Search' : null,
      ),
    );
  }

  Widget _buildFoodItemsList(BuildContext context, List<FoodItem> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDims.screenPadding,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final isLast = index == items.length - 1;
            return Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 8 : 16,
              ),
              child: MenuFoodCard(
                foodItem: items[index],
              ),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}
