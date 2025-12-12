import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:instamess_api/instamess_api.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({
    required this.menuRepository,
    required this.cmsRepository,
    this.initialCategory,
  }) : super(MenuState.initial()) {
    on<MenuInitializedEvent>(_onInitialized);
    on<MenuCategoriesLoadedEvent>(_onCategoriesLoaded);
    on<MenuCategorySelectedEvent>(_onCategorySelected);
    on<MenuPlanSelectedEvent>(_onPlanSelected);
    on<MenuMealTypeSelectedEvent>(_onMealTypeSelected);
    on<MenuSearchQueryChangedEvent>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<MenuRefreshedEvent>(_onRefreshed);
  }

  final IMenuRepository menuRepository;
  final ICmsRepository cmsRepository;
  final Category? initialCategory;

  Future<void> _onInitialized(
    MenuInitializedEvent event,
    Emitter<MenuState> emit,
  ) async {
    // Show loading state
    emit(state.copyWith(menuState: DataState.loading()));

    // Fetch categories from repository (will use cache if available)
    final categoriesResult = await cmsRepository.getCategories();

    categoriesResult.fold(
      (failure) {
        // Failed to fetch categories
        emit(
          state.copyWith(
            menuState: DataState.failure(failure),
          ),
        );
      },
      (categories) {
        // Categories loaded
        if (categories.isEmpty) {
          // No categories available -> surface a user-friendly error and stop loading
          emit(
            state.copyWith(
              categories: const [],
              menuState: DataState.failure(
                const UnknownFailure(message: 'No categories available'),
              ),
            ),
          );
          return;
        }

        // Store categories in state
        emit(state.copyWith(categories: categories));

        // Determine which category to use and dispatch event to load it
        final categoryToUse = initialCategory ?? categories.first;

        // Dispatch event to load the category's menu
        // This will set selectedCategory and fetch menu data
        add(MenuCategorySelectedEvent(category: categoryToUse));
      },
    );
  }

  Future<void> _onCategoriesLoaded(
    MenuCategoriesLoadedEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(categories: event.categories));
  }

  Future<void> _onCategorySelected(
    MenuCategorySelectedEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state.selectedCategory?.id == event.category.id) {
      return; // Same category, no-op
    }

    // Use refreshing state if we have existing data to avoid jarring UI jumps
    final currentState = state.menuState;
    if (currentState is DataStateSuccess<MenuData>) {
      emit(
        state.copyWith(
          selectedCategory: event.category,
          menuState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedCategory: event.category,
          menuState: DataState.loading(),
        ),
      );
    }

    await _fetchMenu(emit);
  }

  Future<void> _onPlanSelected(
    MenuPlanSelectedEvent event,
    Emitter<MenuState> emit,
  ) async {
    // Check if it's the same selection (both null or same ID)
    final isSameSelection =
        (state.selectedPlan == null && event.plan == null) ||
        (state.selectedPlan?.id == event.plan?.id && event.plan != null);

    if (isSameSelection) {
      return; // Same plan, no-op
    }

    // Use refreshing state if we have existing data
    final currentState = state.menuState;
    if (currentState is DataStateSuccess<MenuData>) {
      emit(
        state.copyWith(
          selectedPlan: event.plan,
          overrideSelectedPlan: true,
          menuState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedPlan: event.plan,
          overrideSelectedPlan: true,
          menuState: DataState.loading(),
        ),
      );
    }

    await _fetchMenu(emit);
  }

  void _onMealTypeSelected(
    MenuMealTypeSelectedEvent event,
    Emitter<MenuState> emit,
  ) {
    emit(state.copyWith(selectedMealType: event.mealType));
  }

  Future<void> _onSearchQueryChanged(
    MenuSearchQueryChangedEvent event,
    Emitter<MenuState> emit,
  ) async {
    // Update search query immediately for UI feedback
    emit(state.copyWith(searchQuery: event.query));

    // Update debounced query (this handler is already debounced by transformer)
    emit(state.copyWith(debouncedSearchQuery: event.query));

    // Fetch menu with search query
    final currentState = state.menuState;
    if (currentState is DataStateSuccess<MenuData>) {
      emit(
        state.copyWith(
          menuState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(menuState: DataState.loading()));
    }

    await _fetchMenu(emit);
  }

  Future<void> _onRefreshed(
    MenuRefreshedEvent event,
    Emitter<MenuState> emit,
  ) async {
    final currentState = state.menuState;
    if (currentState is DataStateSuccess<MenuData>) {
      emit(
        state.copyWith(
          menuState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(menuState: DataState.loading()));
    }

    await _fetchMenu(emit);
  }

  Future<void> _fetchMenu(Emitter<MenuState> emit) async {
    final categoryId =
        state.selectedCategory?.id ?? state.categories.firstOrNull?.id;
    if (categoryId == null) {
      log('MenuBloc: Cannot fetch menu - no category selected');
      emit(
        state.copyWith(
          menuState: DataState.failure(
            const UnknownFailure(message: 'No category selected'),
          ),
        ),
      );
      return;
    }

    log(
      'MenuBloc: Fetching menu for category: $categoryId, plan: ${state.selectedPlan?.id}',
    );

    try {
      final result = await menuRepository.getMenu(
        categoryId: categoryId,
        planId: state.selectedPlan?.id,
        search: state.debouncedSearchQuery.isNotEmpty
            ? state.debouncedSearchQuery
            : null,
      );

      log('MenuBloc: Got menu result, folding...');

      result.fold(
        (failure) {
          log('MenuBloc: Menu fetch failed - ${failure.message}');
          emit(
            state.copyWith(
              menuState: DataState.failure(failure),
            ),
          );
        },
        (menuData) {
          log(
            'MenuBloc: Menu fetch succeeded - ${menuData.menu.values.expand((items) => items).length} items',
          );
          emit(
            state.copyWith(
              menuState: DataState.success(menuData),
            ),
          );
          // If no plan is currently selected but the backend returned available
          // plans, default to the first plan and trigger a selection event so
          // the menu is re-fetched for that plan. This avoids showing "all"
          // mixed-plan results and makes the UI default to a concrete plan.
          if (state.selectedPlan == null && menuData.availablePlans.isNotEmpty) {
            log('MenuBloc: No selected plan - defaulting to first available plan');
            // Dispatch plan selection to reuse existing selection/fetch logic.
            add(MenuPlanSelectedEvent(plan: menuData.availablePlans.first));
          }
        },
      );
    } catch (e, s) {
      log('MenuBloc: Unexpected error in _fetchMenu: $e', stackTrace: s);
      emit(
        state.copyWith(
          menuState: DataState.failure(
            UnknownFailure(message: 'Unexpected error: $e'),
          ),
        ),
      );
    }
  }
}
