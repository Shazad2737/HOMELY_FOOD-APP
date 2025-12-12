# Menu Feature - Backend Integration Implementation Plan

**Created**: October 27, 2025  
**Feature**: Dynamic Menu Screen with Category, Plan, and Meal Type Filtering  
**Status**: Ready for Implementation

---

## 1. Overview

This document outlines the complete implementation plan for integrating the Menu backend API with the Flutter frontend. The implementation follows BLoC architecture, functional error handling with fpdart, and adheres to the project's established patterns.

### Key Requirements
- Dynamic category-based menu with navigation from Home screen
- Plan-based filtering (Basic, Premium, Ultimate)
- Meal type organization (Breakfast, Lunch, Dinner)
- Real-time debounced search
- Dietary indicators and delivery mode information
- Production-ready architecture with proper state management

---

## 2. Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                        Home Screen                           │
│  (Categories Section - Click Category → Navigate to Menu)   │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                       Menu Screen                            │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MenuBloc (screen-scoped)                            │   │
│  │  - State: selectedCategory, selectedPlan, mealType   │   │
│  │  - Events: CategorySelected, PlanSelected, etc.      │   │
│  └─────────────────────────────────────────────────────┘   │
│                         │                                    │
│                         ▼                                    │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  MenuRepository (homely_api package)              │   │
│  │  - getMenu(categoryId, planId?, search?)            │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Data Models

### 3.1 New Models to Create

All models will be created in: `packages/homely_api/lib/src/menu/models/`

#### 3.1.1 Plan Type Enum
**File**: `plan_type.dart`
```dart
enum PlanType {
  basic,
  premium,
  ultimate;
  
  static PlanType? fromString(String? value) { ... }
  String toApiString() { ... }
}
```

#### 3.1.2 Menu Plan Model
**File**: `menu_plan.dart`
```dart
class MenuPlan extends Equatable {
  final String id;
  final String name;
  final PlanType type;
  final String? imageUrl;
  
  // fromJson, toJson, props
}
```

#### 3.1.3 Meal Type Enum
**File**: `meal_type.dart`
```dart
enum MealType {
  breakfast,
  lunch,
  dinner;
  
  static MealType? fromString(String? value) { ... }
  String toApiString() { ... }
}
```

#### 3.1.4 Meal Type Info Model
**File**: `meal_type_info.dart`
```dart
class MealTypeInfo extends Equatable {
  final String id;
  final MealType type;
  final String name;
  final String? description;
  final String? startTime;  // e.g., "07:00 AM"
  final String? endTime;    // e.g., "09:00 AM"
  final int sortOrder;
  
  // fromJson, toJson, props
}
```

#### 3.1.5 Cuisine Enum
**File**: `cuisine.dart`
```dart
enum Cuisine {
  southIndian,
  northIndian,
  kerala,
  chinese,
  continental,
  italian,
  mexican,
  other;
  
  static Cuisine? fromString(String? value) { ... }
  String get displayName { ... }
}
```

#### 3.1.6 Food Style Enum
**File**: `food_style.dart`
```dart
enum FoodStyle {
  southIndian,
  northIndian,
  kerala,
  punjabi,
  bengali,
  gujarati,
  rajasthani,
  fusion,
  other;
  
  static FoodStyle? fromString(String? value) { ... }
  String get displayName { ... }
}
```

#### 3.1.7 Delivery Mode Enum
**File**: `delivery_mode.dart`
```dart
enum DeliveryMode {
  separate,
  withOther;
  
  static DeliveryMode? fromString(String? value) { ... }
}
```

#### 3.1.8 Day of Week Enum
**File**: `day_of_week.dart`
```dart
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday;
  
  static DayOfWeek? fromString(String? value) { ... }
  String get shortName { ... } // MON, TUE, etc.
}
```

#### 3.1.9 Deliver With Model
**File**: `deliver_with.dart`
```dart
class DeliverWith extends Equatable {
  final String id;
  final String name;
  final MealType type;
  
  // fromJson, toJson, props
}
```

#### 3.1.10 Available Day Model
**File**: `available_day.dart`
```dart
class AvailableDay extends Equatable {
  final DayOfWeek dayOfWeek;
  
  // fromJson, toJson, props
}
```

#### 3.1.11 Food Item Model
**File**: `food_item.dart`
```dart
class FoodItem extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? imageUrl;
  final Cuisine? cuisine;
  final FoodStyle? style;
  final double? price;
  final bool isVegetarian;
  final bool isVegan;
  final DeliveryMode deliveryMode;
  final DeliverWith? deliverWith;
  final List<AvailableDay> availableDays;
  
  // Helper: Get list of DayOfWeek from availableDays
  List<DayOfWeek> get availableDaysOfWeek { ... }
  
  // Helper: Check if available on specific day
  bool isAvailableOn(DayOfWeek day) { ... }
  
  // fromJson, toJson, props
}
```

#### 3.1.12 Menu Data Model
**File**: `menu_data.dart`
```dart
class MenuData extends Equatable {
  final List<MenuPlan> availablePlans;
  final List<MealTypeInfo> mealTypes;
  final Map<MealType, List<FoodItem>> menu;
  
  // Helper methods
  List<FoodItem> getItemsForMealType(MealType type) { ... }
  bool hasMealType(MealType type) { ... }
  
  // fromJson with special handling for menu map
  factory MenuData.fromJson(Map<String, dynamic> json) {
    // Parse menu: { "breakfast": [...], "lunch": [...], "dinner": [...] }
    final menuMap = <MealType, List<FoodItem>>{};
    final menuJson = json['menu'] as Map<String, dynamic>?;
    
    if (menuJson != null) {
      if (menuJson.containsKey('breakfast')) {
        menuMap[MealType.breakfast] = (menuJson['breakfast'] as List)
          .map((e) => FoodItem.fromJson(e))
          .toList();
      }
      if (menuJson.containsKey('lunch')) {
        menuMap[MealType.lunch] = (menuJson['lunch'] as List)
          .map((e) => FoodItem.fromJson(e))
          .toList();
      }
      if (menuJson.containsKey('dinner')) {
        menuMap[MealType.dinner] = (menuJson['dinner'] as List)
          .map((e) => FoodItem.fromJson(e))
          .toList();
      }
    }
    
    return MenuData(...);
  }
  
  // toJson, props
}
```

#### 3.1.13 Models Export File
**File**: `packages/homely_api/lib/src/menu/models/models.dart`
```dart
export 'available_day.dart';
export 'cuisine.dart';
export 'day_of_week.dart';
export 'deliver_with.dart';
export 'delivery_mode.dart';
export 'food_item.dart';
export 'food_style.dart';
export 'meal_type.dart';
export 'meal_type_info.dart';
export 'menu_data.dart';
export 'menu_plan.dart';
export 'plan_type.dart';
```

### 3.2 Refactor Existing Plan Model

**Current**: `packages/homely_api/lib/src/cms/models/category.dart` contains `Plan` class

**Action**: Extract `Plan` to separate file

**New Structure**:
```
packages/homely_api/lib/src/cms/models/
  ├── area.dart
  ├── banner.dart
  ├── category.dart  (imports Plan from plan.dart)
  ├── home_page_data.dart
  ├── location.dart
  ├── plan.dart  (NEW - existing Plan model moved here)
  └── models.dart  (updated to export plan.dart)
```

**Future Consideration**: If `Plan` and `MenuPlan` need to be unified, create:
```
packages/homely_api/lib/src/common/models/
  └── plan.dart  (unified model)
```

---

## 4. Repository Layer

### 4.1 Menu Repository Interface

**File**: `packages/homely_api/lib/src/menu/menu_repository_interface.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/menu/models/models.dart';

/// {@template menu_repository_interface}
/// Interface for Menu operations
/// {@endtemplate}
abstract class IMenuRepository {
  /// Get menu for a specific category
  /// 
  /// [categoryId] - Required category ID
  /// [planId] - Optional plan ID to filter menu items
  /// [search] - Optional search query for item names, descriptions, or codes
  Future<Either<Failure, MenuData>> getMenu({
    required String categoryId,
    String? planId,
    String? search,
  });
}
```

### 4.2 Menu Repository Implementation

**File**: `packages/homely_api/lib/src/menu/menu_repository.dart`

```dart
import 'dart:developer';
import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homely_api/src/menu/menu_repository_interface.dart';
import 'package:homely_api/src/menu/models/models.dart';

/// {@template menu_repository}
/// Repository for menu-related operations
/// {@endtemplate}
class MenuRepository implements IMenuRepository {
  /// {@macro menu_repository}
  const MenuRepository({
    required this.apiClient,
  });

  /// Api client
  final ApiClient apiClient;

  @override
  Future<Either<Failure, MenuData>> getMenu({
    required String categoryId,
    String? planId,
    String? search,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, dynamic>{};
      if (planId != null && planId.isNotEmpty) {
        queryParams['planId'] = planId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await apiClient.get<Map<String, dynamic>>(
        'menu/$categoryId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.fold(
        (apiFailure) {
          log('Error fetching menu: $apiFailure');
          return left(apiFailure);
        },
        (response) {
          final body = response.data;
          if (body == null) {
            return left(
              const UnknownApiFailure(
                0,
                'No menu data received',
              ),
            );
          }

          try {
            final success = body['success'] as bool? ?? false;
            if (!success) {
              final message = body['message'] as String? ?? 'Failed to fetch menu';
              return left(UnknownApiFailure(response.statusCode ?? 0, message));
            }

            final data = body['data'] as Map<String, dynamic>?;
            if (data == null) {
              return left(
                const UnknownApiFailure(0, 'No menu data in response'),
              );
            }

            final menuData = MenuData.fromJson(data);
            return right(menuData);
          } catch (e, s) {
            log('Error parsing menu response: $e', stackTrace: s);
            return left(
              const UnknownApiFailure(
                0,
                'Failed to parse menu data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log('Unexpected error in getMenu: $e', stackTrace: s);
      return left(
        UnknownFailure(
          message: 'An unexpected error occurred',
          error: e,
          stackTrace: s,
        ),
      );
    }
  }
}
```

### 4.3 Update HomelyApi

**File**: `packages/homely_api/lib/src/homely_api.dart`

Add menu repository:

```dart
// Add import
import 'package:homely_api/src/menu/menu.dart';

// In IHomelyApi interface, add:
abstract class IHomelyApi {
  // ... existing methods
  IMenuRepository get menuFacade;
}

// In HomelyApi implementation:
class HomelyApi implements IHomelyApi {
  // ... existing code
  late final IMenuRepository _menuFacade;
  
  HomelyApi({...}) {
    // ... existing initialization
    
    // Create Menu facade
    _menuFacade = MenuRepository(
      apiClient: _apiClient,
    );
  }
  
  @override
  IMenuRepository get menuFacade => _menuFacade;
}
```

### 4.4 Menu Package Exports

**File**: `packages/homely_api/lib/src/menu/menu.dart`

```dart
export 'menu_repository.dart';
export 'menu_repository_interface.dart';
export 'models/models.dart';
```

**Update**: `packages/homely_api/lib/homely_api.dart`

```dart
// Add export
export 'src/menu/menu.dart';
```

---

## 5. BLoC Layer

### 5.1 Menu State

**File**: `lib/menu/bloc/menu_state.dart`

```dart
part of 'menu_bloc.dart';

@immutable
class MenuState {
  const MenuState({
    required this.menuState,
    this.selectedCategory,
    this.selectedPlan,
    this.selectedMealType = MealType.breakfast,
    this.searchQuery = '',
    this.debouncedSearchQuery = '',
  });

  factory MenuState.initial() {
    return MenuState(
      menuState: DataState.initial(),
      selectedMealType: MealType.breakfast,
    );
  }

  final DataState<MenuData> menuState;
  final Category? selectedCategory;
  final MenuPlan? selectedPlan;
  final MealType selectedMealType;
  final String searchQuery;  // User typing
  final String debouncedSearchQuery;  // Actually used for API call

  // Convenience getters
  bool get isLoading => menuState.isLoading;
  bool get isRefreshing => menuState.isRefreshing;
  bool get isSuccess => menuState.isSuccess;
  bool get isFailure => menuState.isFailure;

  MenuData? get menuData {
    return menuState.maybeMap(
      success: (state) => state.data,
      refreshing: (state) => state.currentData,
      orElse: () => null,
    );
  }

  Failure? get failure {
    return menuState.maybeMap(
      failure: (state) => state.failure,
      orElse: () => null,
    );
  }

  // Get current meal items
  List<FoodItem> get currentMealItems {
    final data = menuData;
    if (data == null) return [];
    return data.getItemsForMealType(selectedMealType);
  }

  // Get filtered items (by search)
  List<FoodItem> get filteredItems {
    final items = currentMealItems;
    if (debouncedSearchQuery.isEmpty) return items;

    final query = debouncedSearchQuery.toLowerCase();
    return items.where((item) {
      return item.name.toLowerCase().contains(query) ||
          (item.description?.toLowerCase().contains(query) ?? false) ||
          item.code.toLowerCase().contains(query);
    }).toList();
  }

  MenuState copyWith({
    DataState<MenuData>? menuState,
    Category? selectedCategory,
    MenuPlan? selectedPlan,
    MealType? selectedMealType,
    String? searchQuery,
    String? debouncedSearchQuery,
  }) {
    return MenuState(
      menuState: menuState ?? this.menuState,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      searchQuery: searchQuery ?? this.searchQuery,
      debouncedSearchQuery: debouncedSearchQuery ?? this.debouncedSearchQuery,
    );
  }
}
```

### 5.2 Menu Events

**File**: `lib/menu/bloc/menu_event.dart`

```dart
part of 'menu_bloc.dart';

@immutable
sealed class MenuEvent {}

/// Initialize menu with a category
class MenuInitializedEvent extends MenuEvent {
  MenuInitializedEvent({required this.category});
  
  final Category category;
}

/// Category selection changed
class MenuCategorySelectedEvent extends MenuEvent {
  MenuCategorySelectedEvent({required this.category});
  
  final Category category;
}

/// Plan selection changed
class MenuPlanSelectedEvent extends MenuEvent {
  MenuPlanSelectedEvent({this.plan});
  
  final MenuPlan? plan;  // null = clear filter
}

/// Meal type tab changed
class MenuMealTypeSelectedEvent extends MenuEvent {
  MenuMealTypeSelectedEvent({required this.mealType});
  
  final MealType mealType;
}

/// Search query changed (will be debounced)
class MenuSearchQueryChangedEvent extends MenuEvent {
  MenuSearchQueryChangedEvent({required this.query});
  
  final String query;
}

/// Refresh current menu
class MenuRefreshedEvent extends MenuEvent {}
```

### 5.3 Menu BLoC

**File**: `lib/menu/bloc/menu_bloc.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:homely_api/homely_api.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc({
    required this.menuRepository,
  }) : super(MenuState.initial()) {
    on<MenuInitializedEvent>(_onInitialized);
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

  Future<void> _onInitialized(
    MenuInitializedEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCategory: event.category,
        menuState: DataState.loading(),
      ),
    );

    await _fetchMenu(emit);
  }

  Future<void> _onCategorySelected(
    MenuCategorySelectedEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state.selectedCategory?.id == event.category.id) {
      return; // Same category, no-op
    }

    emit(
      state.copyWith(
        selectedCategory: event.category,
        selectedPlan: null, // Reset plan when category changes
        menuState: DataState.loading(),
      ),
    );

    await _fetchMenu(emit);
  }

  Future<void> _onPlanSelected(
    MenuPlanSelectedEvent event,
    Emitter<MenuState> emit,
  ) async {
    if (state.selectedPlan?.id == event.plan?.id) {
      return; // Same plan, no-op
    }

    // Use refreshing state if we have existing data
    final currentState = state.menuState;
    if (currentState is DataStateSuccess<MenuData>) {
      emit(
        state.copyWith(
          selectedPlan: event.plan,
          menuState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(
        state.copyWith(
          selectedPlan: event.plan,
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
    final categoryId = state.selectedCategory?.id;
    if (categoryId == null) {
      emit(
        state.copyWith(
          menuState: DataState.failure(
            const UnknownFailure(message: 'No category selected'),
          ),
        ),
      );
      return;
    }

    final result = await menuRepository.getMenu(
      categoryId: categoryId,
      planId: state.selectedPlan?.id,
      search: state.debouncedSearchQuery.isNotEmpty 
          ? state.debouncedSearchQuery 
          : null,
    );

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            menuState: DataState.failure(failure),
          ),
        );
      },
      (menuData) {
        emit(
          state.copyWith(
            menuState: DataState.success(menuData),
          ),
        );
      },
    );
  }
}
```

---

## 6. UI Layer

### 6.1 Update Home Screen - Category Navigation

**File**: `lib/home/view/widgets/categories/categories_section.dart`

**Changes**:
```dart
// In CategoryChip onTap callback:
onTap: () {
  context.router.push(MenuRoute(category: category));
},
```

### 6.2 Update Router - Pass Category Parameter

**File**: `lib/router/router.dart`

**Update MenuRoute**:
```dart
AutoRoute(page: MenuRoute.page),
```

**File**: `lib/menu/view/menu_screen.dart`

**Update MenuScreen to accept category parameter**:
```dart
@RoutePage()
class MenuScreen extends StatelessWidget {
  const MenuScreen({
    this.category,  // Optional - can be null if navigated directly
    super.key,
  });

  final Category? category;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = MenuBloc(
          menuRepository: context.read<IMenuRepository>(),
        );
        
        // Initialize with passed category or first from home data
        final categoryToUse = category ?? _getFirstCategory(context);
        if (categoryToUse != null) {
          bloc.add(MenuInitializedEvent(category: categoryToUse));
        }
        
        return bloc;
      },
      child: const MenuView(),
    );
  }

  Category? _getFirstCategory(BuildContext context) {
    // Get first category from HomeBloc if available
    final homeBloc = context.read<HomeBloc>();
    final categories = homeBloc.state.homePageData?.categories ?? [];
    return categories.isNotEmpty ? categories.first : null;
  }
}
```

**Note**: Need to run `flutter pub run build_runner build --delete-conflicting-outputs` after this change.

### 6.3 Menu View Structure

**File**: `lib/menu/view/menu_screen.dart`

Complete restructure to:

```dart
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
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  MealType _getMealTypeFromIndex(int index) {
    switch (index) {
      case 0: return MealType.breakfast;
      case 1: return MealType.lunch;
      case 2: return MealType.dinner;
      default: return MealType.breakfast;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MenuBloc, MenuState>(
        builder: (context, state) {
          return state.menuState.map(
            initial: (_) => _buildInitialState(),
            loading: (_) => _buildLoadingState(),
            success: (s) => _buildSuccessState(s.data),
            failure: (f) => _buildFailureState(f.failure),
            refreshing: (r) => _buildSuccessState(r.currentData, isRefreshing: true),
          );
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return _buildEmptyState(
      message: 'Select a category to view menu',
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(MenuData menuData, {bool isRefreshing = false}) {
    final bloc = context.read<MenuBloc>();
    final state = bloc.state;
    final items = state.filteredItems;

    return RefreshIndicator(
      onRefresh: () async {
        bloc.add(MenuRefreshedEvent());
        await bloc.stream.firstWhere((s) => !s.isRefreshing && !s.isLoading);
      },
      child: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildCategorySelector(menuData),
          _buildPlanSelector(menuData),
          _buildTabBar(menuData),
          _buildSearchBar(),
          
          if (items.isEmpty)
            _buildEmptyResultsSliver()
          else
            _buildFoodItemsList(items),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureState(Failure failure) {
    return CustomScrollView(
      slivers: [
        _buildHeader(),
        SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
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
      ],
    );
  }

  // ... Other build methods
}
```

### 6.4 New Widgets to Create

#### 6.4.1 Category Selector (Horizontal Scroll)
**File**: `lib/menu/view/widgets/category_selector.dart`

- Reuse `CategoryChip` from home screen
- Horizontal scrollable list
- Show selected state
- Handle selection with `MenuCategorySelectedEvent`

#### 6.4.2 Plan Selector
**File**: `lib/menu/view/widgets/plan_selector.dart`

- Horizontal scrollable cards (reuse/update existing `MenuCategoryCard`)
- Show plan image, name, type
- Selected state with border highlight
- "All Plans" option (null plan) to clear filter
- Handle selection with `MenuPlanSelectedEvent`

#### 6.4.3 Updated Food Card
**File**: `lib/menu/view/widgets/food_card.dart`

Update to use `FoodItem` model:

```dart
class MenuFoodCard extends StatelessWidget {
  const MenuFoodCard({
    required this.foodItem,
    super.key,
  });

  final FoodItem foodItem;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image with CachedNetworkImage
          _buildImage(),
          
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Code
                Text('${foodItem.name} ${foodItem.code}'),
                
                // Description
                if (foodItem.description != null) ...[
                  const SizedBox(height: 4),
                  Text(foodItem.description!),
                ],
                
                const SizedBox(height: 8),
                
                // Cuisine + Style
                _buildInfoRow(),
                
                // Dietary badges
                const SizedBox(height: 8),
                _buildDietaryBadges(),
                
                // Delivery mode info
                if (foodItem.deliveryMode == DeliveryMode.withOther &&
                    foodItem.deliverWith != null) ...[
                  const SizedBox(height: 8),
                  _buildDeliveryInfo(),
                ],
                
                // Available days
                const SizedBox(height: 12),
                _buildAvailableDays(),
                
                // Price (if available)
                if (foodItem.price != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    '₹${foodItem.price!.toStringAsFixed(2)}',
                    style: context.textTheme.titleMedium?.copyWith(
                      color: AppColors.appOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (foodItem.imageUrl != null)
            CachedNetworkImage(
              imageUrl: foodItem.imageUrl!,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: AppColors.grey200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (_, __, ___) => _buildPlaceholder(),
            )
          else
            _buildPlaceholder(),
          
          // Favorite button
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              backgroundColor: AppColors.white,
              child: IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implement favorite functionality
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.grey200,
      child: const Icon(
        Icons.restaurant_menu,
        size: 64,
        color: AppColors.grey500,
      ),
    );
  }

  Widget _buildInfoRow() {
    return Row(
      children: [
        if (foodItem.cuisine != null) ...[
          Icon(Icons.restaurant, size: 16, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(
            foodItem.cuisine!.displayName,
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
        if (foodItem.cuisine != null && foodItem.style != null)
          const SizedBox(width: 12),
        if (foodItem.style != null) ...[
          Icon(Icons.local_dining, size: 16, color: AppColors.grey600),
          const SizedBox(width: 4),
          Text(
            foodItem.style!.displayName,
            style: TextStyle(fontSize: 12, color: AppColors.grey600),
          ),
        ],
      ],
    );
  }

  Widget _buildDietaryBadges() {
    return Row(
      children: [
        if (foodItem.isVegetarian)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'Veg',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (foodItem.isVegetarian && foodItem.isVegan)
          const SizedBox(width: 8),
        if (foodItem.isVegan)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade700.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.park, size: 14, color: Colors.green.shade700),
                const SizedBox(width: 4),
                Text(
                  'Vegan',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: AppColors.info),
          const SizedBox(width: 6),
          Text(
            'Delivered with ${foodItem.deliverWith!.name}',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.info,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableDays() {
    return Row(
      children: DayOfWeek.values.map((day) {
        final isAvailable = foodItem.isAvailableOn(day);
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: DayChip(
            day: day.shortName,
            isAvailable: isAvailable,
          ),
        );
      }).toList(),
    );
  }
}
```

#### 6.4.4 Update Day Chip
**File**: `lib/menu/view/widgets/day_chip.dart`

Update to accept `String` day and `bool` isAvailable:

```dart
class DayChip extends StatelessWidget {
  const DayChip({
    required this.day,
    required this.isAvailable,
    super.key,
  });

  final String day;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isAvailable ? AppColors.appOrange : AppColors.grey200,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(
        day,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAvailable ? AppColors.white : AppColors.grey500,
        ),
      ),
    );
  }
}
```

#### 6.4.5 Empty States
**File**: `lib/menu/view/widgets/empty_state.dart`

```dart
class MenuEmptyState extends StatelessWidget {
  const MenuEmptyState({
    required this.message,
    this.icon = Icons.restaurant_menu,
    this.action,
    this.actionLabel,
    super.key,
  });

  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: action,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Integration Checklist

### 7.1 Package Layer (`packages/homely_api`)

- [ ] Create `lib/src/menu/models/` directory
- [ ] Create all enum files (plan_type, meal_type, cuisine, food_style, delivery_mode, day_of_week)
- [ ] Create model files (menu_plan, meal_type_info, deliver_with, available_day, food_item, menu_data)
- [ ] Create `models.dart` export file
- [ ] Extract `Plan` from `category.dart` to `plan.dart`
- [ ] Update `cms/models/models.dart` to export `plan.dart`
- [ ] Create `menu_repository_interface.dart`
- [ ] Create `menu_repository.dart`
- [ ] Create `menu.dart` export file
- [ ] Update `homely_api.dart` to add `IMenuRepository` getter
- [ ] Update `homely_api.dart` to initialize `MenuRepository`
- [ ] Update main export `homely_api.dart` to export menu module

### 7.2 App Layer (`lib/`)

- [ ] Create `lib/menu/bloc/` directory
- [ ] Create `menu_event.dart`
- [ ] Create `menu_state.dart`
- [ ] Create `menu_bloc.dart`
- [ ] Update `lib/app/view/bloc_providers.dart` to provide `IMenuRepository`
- [ ] Update `lib/home/view/widgets/categories/categories_section.dart` for navigation
- [ ] Update `lib/router/router.dart` to accept category parameter in MenuRoute
- [ ] Run build_runner to generate routes
- [ ] Update `lib/menu/view/menu_screen.dart` completely
- [ ] Create `lib/menu/view/widgets/category_selector.dart`
- [ ] Create `lib/menu/view/widgets/plan_selector.dart`
- [ ] Update `lib/menu/view/widgets/food_card.dart`
- [ ] Update `lib/menu/view/widgets/day_chip.dart`
- [ ] Create `lib/menu/view/widgets/empty_state.dart`


---

## 8. Implementation Order

### Phase 1: Models & Repository (Backend Integration)
1. Create all enum files
2. Create model files with proper fromJson/toJson
3. Extract and refactor Plan model
4. Create menu repository interface and implementation
5. Update HomelyApi to expose menu repository

### Phase 2: BLoC Layer (State Management)
1. Create menu events
2. Create menu state with DataState wrapper
3. Implement MenuBloc with all event handlers

### Phase 3: UI Components (View Layer)
1. Create/update individual widgets (day chip, empty state, etc.)
2. Create category selector widget
3. Create plan selector widget
4. Update food card with all new features. keep current design mostly same

### Phase 4: Screen Integration
1. Update MenuScreen to use BLoC
2. Implement all UI states (loading, success, failure, empty)
3. Add RefreshIndicator
4. Implement search bar with debounce
5. Add tab controller for meal types

### Phase 5: Navigation & Final Integration
1. Update home screen category navigation
2. Update router configuration
3. Provide MenuRepository in app
4. Run build_runner
5. Test complete flow end-to-end

### Phase 6: Polish 
1. Add error handling and edge cases
2. Optimize performance (const constructors, build optimizations)
3. Add loading states and shimmer effects
5. Code review and refactoring

---

## 9. Code Quality Standards

### Adherence to Project Patterns

✅ **Must Follow**:
- Use `DataState<T>` for all async operations
- Use `Either<Failure, T>` in repositories
- Always use `.fold()` for Either handling
- Sealed classes for events and states
- Exhaustive switch statements in BLoC
- Constructor dependency injection
- Immutable state with copyWith
- Use `context.read<T>()` for repository access
- Add `@RoutePage()` annotation to screens
- Use `context.textTheme` instead of `AppTextStyles`
- Prefer `BlocBuilder` with `buildWhen` for targeted rebuilds
- Use const constructors where possible

❌ **Must Avoid**:
- Global singletons
- Direct ApiClient usage in BLoC
- Hardcoded values (all from API)
- Functions for widgets (use widget classes)
- Provider.of without listen: false
- Ignoring null safety
- Creating files without proper exports

### Documentation
- Document all public code with `///`
- Use `{@template}` and `{@macro}` for class documentation
- Add inline comments for complex logic
- Keep comments concise and meaningful

---

## 10. Edge Cases & Error Handling

### Scenarios to Handle

1. **No categories available**
   - Show empty state with message
   - Disable menu screen or show placeholder

2. **Category has no menu items**
   - Show attractive empty state
   - Message: "No items available in this category"

3. **Search returns no results**
   - Show "No results found" state
   - Show clear search button
   - Message: "Try different keywords"

4. **Network failure**
   - Show error with retry button
   - Preserve last successful state if refreshing

5. **Invalid category ID**
   - Handle 404 from backend
   - Show error message
   - Allow navigation back

6. **Plan filter returns empty**
   - Show message: "No items available for this plan"
   - Allow clearing filter

7. **Meal type has no items**
   - Show empty state for that tab
   - Don't disable tab (backend controls availability)

8. **Debounce edge cases**
   - Transformer handles debouncing automatically
   - Handle rapid typing/clearing
   - Clear search should reset immediately

9. **Image loading failures**
   - Show placeholder icon
   - Graceful fallback

10. **Missing optional fields**
    - Defensive null checks
    - Hide UI elements if data missing

---

## 11. Performance Considerations

### Optimization Strategies

1. **Const Constructors**
   - Use const for all static widgets
   - Reduces rebuild overhead

2. **BlocBuilder buildWhen**
   - Only rebuild when relevant state changes
   - Example: Don't rebuild food list when search query changes (only when debouncedSearchQuery changes)

3. **ListView.builder**
   - Use builder pattern for food items list
   - Only build visible items

4. **Image Caching**
   - CachedNetworkImage automatically caches
   - Set reasonable cache duration

5. **Debounce Search**
   - 500ms delay prevents excessive API calls
   - Uses `debounce` transformer from `core/utils/bloc_utils.dart`

6. **State Preservation**
   - Use `refreshing` state to keep showing data during background updates
   - Prevents jarring loading states

7. **Lazy Loading**
   - Consider pagination if menu items exceed 50+ per meal type
   - Infinite scroll pattern

8. **Memory Management**
   - Dispose controllers (TabController, TextEditingController)
   - Debounce transformer handles event cancellation automatically

---


---

## 14. Documentation Updates

After implementation, update:
1. **Code Comments**
   - Inline documentation
   - Complex logic explanations
  

dont create any summary or implementation something md files

---

## 15. Success Criteria

The implementation is complete when:

- [ ] All menu data comes from API (no hardcoded values)
- [ ] Category navigation from Home works seamlessly
- [ ] Plan filtering updates menu in real-time
- [ ] Search is debounced and works across all fields
- [ ] Meal type tabs switch correctly
- [ ] Empty states are attractive and informative
- [ ] Error states show retry option
- [ ] Pull-to-refresh works
- [ ] Images load with proper placeholders
- [ ] Delivery mode info displays correctly
- [ ] Code follows project conventions
- [ ] No linting errors
- [ ] Documentation is complete
- [ ] Performance is smooth (60fps)

---

## 16. Developer Notes

### Key Decisions

1. **Screen-scoped BLoC**: MenuBloc is created per screen instance, not globally, because each menu session is independent.

2. **Category Parameter**: MenuRoute accepts optional Category to support both direct navigation and deep linking.

3. **Debounced Search**: Uses `debounce` transformer from `core/utils/bloc_utils.dart` with 500ms delay for optimal responsiveness and API call reduction.

4. **Refreshing State**: Using `DataState.refreshing()` provides better UX by keeping content visible during background updates.

5. **Separate Models**: Created `MenuPlan` separate from CMS `Plan` to allow future divergence without breaking existing code.

6. **Meal Type Tabs**: Hardcoded 3 tabs (breakfast, lunch, dinner) matching backend response keys, but can be disabled based on `mealTypes` array.

### Common Pitfalls to Avoid

1. Don't forget to dispose controllers (TabController, TextEditingController)
2. Don't use Provider.of in event handlers (use context.read)
3. Don't forget to run build_runner after route changes
4. Don't mix loading and refreshing states incorrectly
5. Don't forget null checks for optional API fields
6. Don't create summary files unless requested
7. Don't use functions for widgets (use widget classes)


---

## 18. Dependencies

### New Dependencies Required

None - All required packages already in project:
- ✅ fpdart
- ✅ bloc/flutter_bloc
- ✅ auto_route
- ✅ cached_network_image
- ✅ equatable
- ✅ deep_pick

---

## 19. Final Checklist Before Submission

- [ ] All code formatted (`dart format .`)
- [ ] All tests passing (`very_good test --coverage`)
- [ ] No analysis errors (`dart analyze`)
- [ ] Build runner executed successfully
- [ ] Manual testing on device/simulator
- [ ] Screenshots/video of working feature
- [ ] Code reviewed for best practices
- [ ] Documentation updated
- [ ] Git commits are clean and descriptive
- [ ] No debug prints or commented code
- [ ] All TODO comments addressed

---

**End of Implementation Plan**

This plan provides a complete, production-ready roadmap for implementing the Menu feature. Follow the phases sequentially, test continuously, and adhere to the project's architectural patterns for a successful implementation.
