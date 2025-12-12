# Order Flow Implementation Guide

## Backend API Summary

### Endpoints
```
GET  /api/orders/available  → Get available order days
POST /api/orders/create     → Create order
GET  /api/orders            → View orders (already implemented ✅)
```

### Key Backend Rules
- **One order per day** - Single Order entity per date with multiple orderItems[]
- **Multiple meal types allowed** - Can order breakfast + lunch + dinner same day
- **One meal type per item** - Can't order 2 breakfasts on same day
- **Delivery modes**: `SEPARATE` (own time) or `WITH_OTHER` (delivered with another meal)
- **Advance ordering** - Must order X days ahead before cutoff hour
- **Subscription bound** - Orders only within subscription dates
- **Holidays** - No orders allowed on holidays
- **Already ordered** - Can't reorder same date

---

## UI Design: Progressive Disclosure Hybrid

### Screen Structure
Single screen with smart state transitions:
1. **Calendar at top** - Always visible
2. **Meal cards below** - Only appear after date selection
3. **Bottom sheets** - Food selection → Location selection (chained)

### Visual States

#### State 1: No Date Selected
```
┌─────────────────────────────────────┐
│ [MON] [TUE] [WED] [THU] [FRI] ...   │ ← Scrollable calendar
│  3✓   4🎉   5    6    7             │
│                                     │
│    ↓ Select a date above ↓          │
└─────────────────────────────────────┘
```

#### State 2: Date Selected
```
┌─────────────────────────────────────┐
│ [MON] [TUE] [WED] [THU] [FRI] ...   │
│  3✓   4🎉   5★   6    7             │ ← 5 selected
├─────────────────────────────────────┤
│ 📅 Ordering for Nov 5, 2025         │
│ [Change Date]         ⓘ Order by 3PM│
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🍳 Breakfast                    │ │ Empty
│ │ Tap to select           →       │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🍽️ Lunch                   [✓] │ │ Selected
│ │ Chicken Biryani                 │ │
│ │ 📍 Home - Apt 502      [Edit]   │ │
│ │ 📦 With Breakfast • 6:00-10:30  │ │ ← WITH_OTHER indicator
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ 🌙 Dinner                  [🚫] │ │ Disabled
│ │ Not available for this day      │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ 📝 Order Notes (optional)           │
│ [text field]                        │
├─────────────────────────────────────┤
│       [Order Now (1 meal)]          │
└─────────────────────────────────────┘
```

### Calendar Chip States
- **Available**: Default style, tappable
- **Selected**: Highlighted (star icon ★)
- **Ordered**: Badge with checkmark (✓), shows banner if tapped
- **Holiday**: Badge with emoji (🎉), shows banner if tapped
- **Out of subscription**: Grayed out, disabled

### Meal Card States
- **Empty**: "Tap to select" with arrow icon
- **Selected**: Shows food name, location, edit button, delivery info if WITH_OTHER
- **Disabled**: Grayed out, "Not available for this day"

---

## Implementation Plan

### Phase 1: API Models & Repository

#### New Models (packages/instamess_api/lib/src/user/models/)

**1. available_order_days.dart**
```dart
class AvailableOrderDays {
  final Customer customer;
  final Subscription subscription;
  final OrderingRules orderingRules;
  final List<AvailableDay> days;
}
```

**2. available_day.dart**
```dart
class AvailableDay {
  final String date;              // "2025-11-05"
  final String dayOfWeek;         // "MONDAY"
  final bool isAvailable;
  final String? holidayName;
  final bool alreadyOrdered;      // ✓ NEW
  final String? existingOrderNumber;  // ✓ NEW (e.g., "ORD251105-0001")
  final String? existingOrderStatus;  // ✓ NEW (e.g., "CONFIRMED")
  final AvailableMealTypes availableMealTypes;
  final FoodItemsByMeal foodItems;
}

class AvailableMealTypes {
  final bool breakfast;
  final bool lunch;
  final bool dinner;
}

class FoodItemsByMeal {
  final List<FoodItem> breakfast;
  final List<FoodItem> lunch;
  final List<FoodItem> dinner;
}
```

**3. food_item.dart** (extend existing)
```dart
class FoodItem {
  // ... existing fields (id, name, description, imageUrl, cuisine, style, isVegetarian, isVegan, mealTypeId)
  final String code;                   // ✓ NEW (e.g., "DS0323")
  final String deliveryMode;           // "SEPARATE" | "WITH_OTHER"
  final String? deliverWith;           // "BREAKFAST" | "LUNCH" | "DINNER"
  final DeliveryTime deliveryTime;
  final List<DayOfWeek> availableDays; // ✓ NEW (optional, for validation)
  final List<Location> availableLocations;
  
  bool get isSeparateDelivery => deliveryMode == 'SEPARATE';
  bool get isGroupedDelivery => deliveryMode == 'WITH_OTHER';
}

class DayOfWeek {
  final String dayOfWeek;  // "MONDAY", "TUESDAY", etc.
}

class DeliveryTime {
  final String start;  // "06:00"
  final String end;    // "10:30"
}
```

**4. location.dart** (extend existing DeliveryLocation)
```dart
class Location {
  final String id;
  final String name;
  final String? buildingName;  // ✓ NEW (optional)
  final String areaId;
  final String locationId;
  final String type;      // "HOME" | "OFFICE" | "OTHER"
  final bool isDefault;
  
  // Display name for UI
  String get displayName => buildingName != null 
      ? '$name - $buildingName' 
      : name;
}
```

**5. customer.dart**
```dart
class Customer {
  final String id;
  final String name;
  final String mobile;
  final String customerCode;
  final List<Location> locations;
}
```

**6. subscription.dart** (reuse existing or create new)
```dart
class Subscription {
  final String id;
  final Category? category;    // ✓ NEW (nullable)
  final Plan? plan;            // ✓ NEW (nullable)
  final String startDate;
  final String endDate;
  final List<String> subscribedMealTypes;  // ["BREAKFAST", "LUNCH"]
}

// Note: Category and Plan models may already exist in subscription package
// Reuse if available, otherwise create minimal versions
```

**7. ordering_rules.dart**
```dart
class OrderingRules {
  final int minAdvanceOrderDays;
  final int maxAdvanceOrderDays;
  final int advanceOrderCutoffHour;
  final int currentHour;
  final bool canOrderToday;
}
```

**8. create_order_request.dart**
```dart
class CreateOrderRequest {
  final String orderDate;              // "2025-11-05"
  final String? notes;
  final List<OrderItemRequest> orderItems;
  
  Map<String, dynamic> toJson();
}

class OrderItemRequest {
  final String foodItemId;
  final String mealTypeId;
  final String deliveryLocationId;
  final String? notes;
}
```

**9. create_order_response.dart**
```dart
class CreateOrderResponse {
  final String id;
  final String orderNumber;
  final String orderDate;
  final String status;
  final String? notes;
  final List<OrderItem> orderItems;  // Reuse existing OrderItem model
}
```

#### Repository Methods (packages/instamess_api/lib/src/user/)

**user_repository_interface.dart**
```dart
abstract class IUserRepository {
  // Existing
  Future<Either<Failure, OrdersResponse>> getOrders({...});
  Future<Either<Failure, SubscriptionData>> getSubscription();
  
  // New
  Future<Either<Failure, AvailableOrderDays>> getAvailableOrderDays();
  Future<Either<Failure, CreateOrderResponse>> createOrder(CreateOrderRequest request);
}
```

**user_repository.dart**
```dart
@override
Future<Either<Failure, AvailableOrderDays>> getAvailableOrderDays() async {
  try {
    final response = await _apiClient.get<Map<String, dynamic>>('/orders/available');
    return response.fold(
      left,
      (r) {
        // Parse response, handle success/failure
        final data = AvailableOrderDays.fromJson(r.data['data']);
        return right(data);
      },
    );
  } catch (e) {
    return left(UnknownFailure(message: e.toString()));
  }
}

@override
Future<Either<Failure, CreateOrderResponse>> createOrder(CreateOrderRequest request) async {
  try {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '/orders/create',
      data: request.toJson(),
    );
    return response.fold(
      left,
      (r) {
        final data = CreateOrderResponse.fromJson(r.data['data']);
        return right(data);
      },
    );
  } catch (e) {
    return left(UnknownFailure(message: e.toString()));
  }
}
```

---

### Phase 2: BLoC Layer

#### lib/order_form/bloc/

**order_form_event.dart**
```dart
sealed class OrderFormEvent extends Equatable {
  const OrderFormEvent();
}

class OrderFormLoadedEvent extends OrderFormEvent {}
class OrderFormDateSelectedEvent extends OrderFormEvent {
  final String date;
}
class OrderFormDateClearRequestedEvent extends OrderFormEvent {}
class OrderFormDateClearedEvent extends OrderFormEvent {}
class OrderFormMealTappedEvent extends OrderFormEvent {
  final MealTypeEnum mealType;
}
class OrderFormFoodSelectedEvent extends OrderFormEvent {
  final MealTypeEnum mealType;
  final FoodItem food;
}
class OrderFormLocationSelectedEvent extends OrderFormEvent {
  final MealTypeEnum mealType;
  final Location location;
}
class OrderFormMealEditedEvent extends OrderFormEvent {
  final MealTypeEnum mealType;
}
class OrderFormMealRemovedEvent extends OrderFormEvent {
  final MealTypeEnum mealType;
}
class OrderFormNotesChangedEvent extends OrderFormEvent {
  final String notes;
}
class OrderFormSubmittedEvent extends OrderFormEvent {}
```

**order_form_state.dart**
```dart
enum MealTypeEnum { breakfast, lunch, dinner }

class OrderItemSelection extends Equatable {
  final FoodItem food;
  final Location location;
  final String? notes;
}

class PendingFoodSelection extends Equatable {
  final MealTypeEnum mealType;
  final FoodItem food;
  
  const PendingFoodSelection({
    required this.mealType,
    required this.food,
  });
  
  @override
  List<Object?> get props => [mealType, food];
}

class OrderFormState extends Equatable {
  final DataState<AvailableOrderDays> availableDaysState;
  final String? selectedDate;
  final Map<MealTypeEnum, OrderItemSelection?> mealSelections;
  final String? orderNotes;
  final DataState<CreateOrderResponse> createOrderState;
  final PendingFoodSelection? pendingFoodSelection;  // Stores food until location is selected
  
  // Computed getters
  bool get hasSelectedDate => selectedDate != null;
  
  bool get canShowMealCards {
    if (!hasSelectedDate) return false;
    final selectedDay = _findDayByDate(selectedDate);
    return selectedDay?.isAvailable ?? false;
  }
  
  bool get isSelectedDateHoliday {
    final selectedDay = _findDayByDate(selectedDate);
    return selectedDay?.holidayName != null;
  }
  
  bool get isSelectedDateAlreadyOrdered {
    final selectedDay = _findDayByDate(selectedDate);
    return selectedDay?.alreadyOrdered ?? false;
  }
  
  String? get existingOrderNumber {
    final selectedDay = _findDayByDate(selectedDate);
    return selectedDay?.existingOrderNumber;
  }
  
  String? get existingOrderStatus {
    final selectedDay = _findDayByDate(selectedDate);
    return selectedDay?.existingOrderStatus;
  }
  
  int get selectedMealCount {
    return mealSelections.values.where((s) => s != null).length;
  }
  
  bool get canSubmit {
    return hasSelectedDate && 
           selectedMealCount > 0 && 
           !isSelectedDateHoliday &&
           !isSelectedDateAlreadyOrdered;
  }
  
  List<FoodItem> getFoodItemsForMeal(MealTypeEnum mealType) {
    final selectedDay = _findDayByDate(selectedDate);
    if (selectedDay == null) return [];
    
    switch (mealType) {
      case MealTypeEnum.breakfast:
        return selectedDay.foodItems.breakfast;
      case MealTypeEnum.lunch:
        return selectedDay.foodItems.lunch;
      case MealTypeEnum.dinner:
        return selectedDay.foodItems.dinner;
    }
  }
  
  bool isMealTypeAvailable(MealTypeEnum mealType) {
    final selectedDay = _findDayByDate(selectedDate);
    if (selectedDay == null) return false;
    
    switch (mealType) {
      case MealTypeEnum.breakfast:
        return selectedDay.availableMealTypes.breakfast;
      case MealTypeEnum.lunch:
        return selectedDay.availableMealTypes.lunch;
      case MealTypeEnum.dinner:
        return selectedDay.availableMealTypes.dinner;
    }
  }
}
```

**order_form_bloc.dart**
```dart
/// Order Form BLoC
/// 
/// Location Selection Logic:
/// - SEPARATE delivery mode → Always show location picker
/// - WITH_OTHER delivery mode:
///   - If paired meal already selected → Auto-use same location (no picker)
///   - If paired meal NOT selected → Show location picker, location will be reused for paired meal
class OrderFormBloc extends Bloc<OrderFormEvent, OrderFormState> {
  final IUserRepository _userRepository;
  
  OrderFormBloc({required IUserRepository userRepository})
      : _userRepository = userRepository,
        super(OrderFormState.initial()) {
    on<OrderFormLoadedEvent>(_onLoaded);
    on<OrderFormDateSelectedEvent>(_onDateSelected);
    on<OrderFormDateClearRequestedEvent>(_onDateClearRequested);
    on<OrderFormFoodSelectedEvent>(_onFoodSelected);
    on<OrderFormLocationSelectedEvent>(_onLocationSelected);
    on<OrderFormMealRemovedEvent>(_onMealRemoved);
    on<OrderFormNotesChangedEvent>(_onNotesChanged);
    on<OrderFormSubmittedEvent>(_onSubmitted);
  }
  
  Future<void> _onLoaded(OrderFormLoadedEvent event, Emitter<OrderFormState> emit) async {
    emit(state.copyWith(availableDaysState: DataState.loading()));
    
    final result = await _userRepository.getAvailableOrderDays();
    
    result.fold(
      (failure) => emit(state.copyWith(availableDaysState: DataState.failure(failure))),
      (data) => emit(state.copyWith(availableDaysState: DataState.success(data))),
    );
  }
  
  void _onDateSelected(OrderFormDateSelectedEvent event, Emitter<OrderFormState> emit) {
    // If meals already selected, need to clear them
    if (state.selectedMealCount > 0) {
      // Emit confirmation needed state
      // UI will show dialog, then dispatch OrderFormDateClearedEvent if confirmed
      return;
    }
    
    emit(state.copyWith(
      selectedDate: event.date,
      mealSelections: {}, // Clear selections
    ));
  }
  
  void _onFoodSelected(OrderFormFoodSelectedEvent event, Emitter<OrderFormState> emit) {
    final food = event.food;
    
    // Handle WITH_OTHER delivery mode with paired meal already selected
    if (food.deliveryMode == 'WITH_OTHER') {
      final pairedMealType = _getMealTypeFromString(food.deliverWith);
      final pairedSelection = state.mealSelections[pairedMealType];
      
      if (pairedSelection != null) {
        // Paired meal exists: Auto-use paired meal's location
        final updatedSelections = Map<MealTypeEnum, OrderItemSelection?>.from(state.mealSelections);
        updatedSelections[event.mealType] = OrderItemSelection(
          food: food,
          location: pairedSelection.location,
        );
        
        emit(state.copyWith(
          mealSelections: updatedSelections,
          activeBottomSheet: null,
        ));
        return;
      }
      // Paired meal not selected: fall through to store food and wait for location picker
    }
    
    // For SEPARATE delivery OR WITH_OTHER without paired meal:
    // Store selected food temporarily, will be confirmed after location selection
    emit(state.copyWith(
      pendingFoodSelection: PendingFoodSelection(
        mealType: event.mealType,
        food: food,
      ),
    ));
  }
  
  void _onLocationSelected(OrderFormLocationSelectedEvent event, Emitter<OrderFormState> emit) {
    // Get the pending food selection
    final pending = state.pendingFoodSelection;
    if (pending == null || pending.mealType != event.mealType) {
      // No pending selection or mismatch, ignore
      return;
    }
    
    final updatedSelections = Map<MealTypeEnum, OrderItemSelection?>.from(state.mealSelections);
    
    updatedSelections[event.mealType] = OrderItemSelection(
      food: pending.food,
      location: event.location,
    );
    
    emit(state.copyWith(
      mealSelections: updatedSelections,
      pendingFoodSelection: null, // Clear pending selection
    ));
  }
  
  Future<void> _onSubmitted(OrderFormSubmittedEvent event, Emitter<OrderFormState> emit) async {
    if (!state.canSubmit) return;
    
    // Validate WITH_OTHER constraints
    for (final entry in state.mealSelections.entries) {
      final selection = entry.value;
      if (selection == null) continue;
      
      if (selection.food.deliveryMode == 'WITH_OTHER') {
        final pairedMealType = _getMealTypeFromString(selection.food.deliverWith);
        final pairedSelection = state.mealSelections[pairedMealType];
        
        if (pairedSelection != null) {
          if (selection.location.id != pairedSelection.location.id) {
            emit(state.copyWith(
              createOrderState: DataState.failure(
                UnknownFailure(message: 'Meals delivered together must have same location'),
              ),
            ));
            return;
          }
        }
      }
    }
    
    emit(state.copyWith(createOrderState: DataState.loading()));
    
    final request = CreateOrderRequest(
      orderDate: state.selectedDate!,
      notes: state.orderNotes,
      orderItems: state.mealSelections.entries
          .where((e) => e.value != null)
          .map((e) => OrderItemRequest(
                foodItemId: e.value!.food.id,
                mealTypeId: e.value!.food.mealTypeId,
                deliveryLocationId: e.value!.location.id,
              ))
          .toList(),
    );
    
    final result = await _userRepository.createOrder(request);
    
    result.fold(
      (failure) => emit(state.copyWith(createOrderState: DataState.failure(failure))),
      (data) => emit(state.copyWith(createOrderState: DataState.success(data))),
    );
  }
  
  // Helper to map backend strings to enum
  MealTypeEnum _getMealTypeFromString(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST':
        return MealTypeEnum.breakfast;
      case 'LUNCH':
        return MealTypeEnum.lunch;
      case 'DINNER':
        return MealTypeEnum.dinner;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
  }
}
```

---

### Phase 3: UI Implementation

#### lib/order_form/view/order_form_screen.dart

**Main Screen Structure**
```dart
@RoutePage()
class OrderFormScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrderFormBloc(
        userRepository: context.read<IUserRepository>(),
      )..add(OrderFormLoadedEvent()),
      child: const _OrderFormContent(),
    );
  }
}

class _OrderFormContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Your Meals')),
      body: BlocConsumer<OrderFormBloc, OrderFormState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          return state.availableDaysState.map(
            initial: (_) => const LoadingIndicator(),
            loading: (_) => const LoadingIndicator(),
            success: (data) => _OrderFormBody(data: data.data),
            failure: (f) => ErrorContent(failure: f.failure),
            refreshing: (r) => _OrderFormBody(data: r.currentData),
          );
        },
      ),
    );
  }
  
  void _handleStateChanges(BuildContext context, OrderFormState state) {
    // Handle date change confirmation
    // Handle order submission success/failure
    // Show snackbars for WITH_OTHER auto-location selection
  }
}

class _OrderFormBody extends StatelessWidget {
  final AvailableOrderDays data;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _CalendarSection(days: data.days),
                BlocBuilder<OrderFormBloc, OrderFormState>(
                  builder: (context, state) {
                    if (!state.hasSelectedDate) {
                      return _EmptyDatePrompt();
                    }
                    
                    if (state.isSelectedDateHoliday) {
                      return _HolidayBanner(holidayName: '...');
                    }
                    
                    if (state.isSelectedDateAlreadyOrdered) {
                      return _AlreadyOrderedBanner(orderNumber: '...');
                    }
                    
                    return _MealCardsSection();
                  },
                ),
              ],
            ),
          ),
        ),
        _BottomSubmitSection(),
      ],
    );
  }
}
```

**Calendar Section**
```dart
class _CalendarSection extends StatelessWidget {
  final List<AvailableDay> days;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          return _DateChip(day: days[index]);
        },
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final AvailableDay day;
  
  @override
  Widget build(BuildContext context) {
    final isSelected = /* check if this date is selected */;
    final isHoliday = day.holidayName != null;
    final isOrdered = /* check backend data */;
    
    return GestureDetector(
      onTap: () {
        if (isHoliday || isOrdered) {
          // Show banner
          return;
        }
        context.read<OrderFormBloc>().add(OrderFormDateSelectedEvent(day.date));
      },
      child: Container(
        // Style based on state
        child: Column(
          children: [
            Text(/* day of week */),
            Text(/* date number */),
            if (isOrdered) Icon(Icons.check),
            if (isHoliday) Text('🎉'),
          ],
        ),
      ),
    );
  }
}
```

**Meal Cards Section**
```dart
class _MealCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        return Column(
          children: [
            _SelectedDateHeader(date: state.selectedDate!),
            _MealCard(mealType: MealTypeEnum.breakfast),
            _MealCard(mealType: MealTypeEnum.lunch),
            _MealCard(mealType: MealTypeEnum.dinner),
            _NotesField(),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealTypeEnum mealType;
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        final isAvailable = state.isMealTypeAvailable(mealType);
        final selection = state.mealSelections[mealType];
        
        if (!isAvailable) {
          return _DisabledMealCard(mealType: mealType);
        }
        
        if (selection == null) {
          return _EmptyMealCard(
            mealType: mealType,
            onTap: () => _showFoodBottomSheet(context, mealType),
          );
        }
        
        return _SelectedMealCard(
          mealType: mealType,
          selection: selection,
          onEdit: () => _showFoodBottomSheet(context, mealType),
          onRemove: () => context.read<OrderFormBloc>().add(
            OrderFormMealRemovedEvent(mealType),
          ),
        );
      },
    );
  }
}

class _SelectedMealCard extends StatelessWidget {
  final OrderItemSelection selection;
  
  @override
  Widget build(BuildContext context) {
    final food = selection.food;
    
    return Card(
      child: Padding(
        child: Column(
          children: [
            Row(
              children: [
                _MealIcon(mealType: mealType),
                Text(food.name),
                if (food.isGroupedDelivery) _GroupedDeliveryBadge(food: food),
                Spacer(),
                IconButton(icon: Icons.edit, onPressed: onEdit),
              ],
            ),
            Row(
              children: [
                Icon(Icons.location_on),
                Text(selection.location.name),
              ],
            ),
            if (food.isGroupedDelivery)
              _DeliveryInfoRow(
                text: 'Delivered with ${food.deliverWith} • ${food.deliveryTime.start}-${food.deliveryTime.end}',
              ),
          ],
        ),
      ),
    );
  }
}
```

**Bottom Sheets**
```dart
void _showFoodBottomSheet(BuildContext context, MealTypeEnum mealType) {
  final bloc = context.read<OrderFormBloc>();
  final foodItems = bloc.state.getFoodItemsForMeal(mealType);
  
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => BlocProvider.value(
      value: bloc,
      child: _FoodSelectionBottomSheet(
        mealType: mealType,
        foodItems: foodItems,
      ),
    ),
  );
}

class _FoodSelectionBottomSheet extends StatelessWidget {
  final MealTypeEnum mealType;
  final List<FoodItem> foodItems;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BottomSheetHeader(title: 'Select ${mealType.name}'),
        Expanded(
          child: ListView.builder(
            itemCount: foodItems.length,
            itemBuilder: (context, index) {
              return _FoodItemTile(
                food: foodItems[index],
                onTap: () {
                  final food = foodItems[index];
                  final bloc = context.read<OrderFormBloc>();
                  
                  // Dispatch food selection event
                  bloc.add(
                    OrderFormFoodSelectedEvent(
                      mealType: mealType,
                      food: food,
                    ),
                  );
                  
                  // Determine if we need to show location picker
                  bool needsLocationPicker = false;
                  
                  if (food.isSeparateDelivery) {
                    // SEPARATE delivery always needs location picker
                    needsLocationPicker = true;
                  } else if (food.isGroupedDelivery) {
                    // WITH_OTHER: check if paired meal is already selected
                    final pairedMealType = _getMealTypeFromString(food.deliverWith);
                    final pairedSelection = bloc.state.mealSelections[pairedMealType];
                    
                    if (pairedSelection == null) {
                      // Paired meal not selected yet, need location picker
                      needsLocationPicker = true;
                    } else {
                      // Paired meal exists, auto-use its location (handled in BLoC)
                      needsLocationPicker = false;
                    }
                  }
                  
                  Navigator.pop(context); // Close food selection sheet
                  
                  if (needsLocationPicker) {
                    _showLocationBottomSheet(context, mealType, food);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
  
  // Helper to map backend strings to enum
  MealTypeEnum _getMealTypeFromString(String? mealType) {
    switch (mealType?.toUpperCase()) {
      case 'BREAKFAST':
        return MealTypeEnum.breakfast;
      case 'LUNCH':
        return MealTypeEnum.lunch;
      case 'DINNER':
        return MealTypeEnum.dinner;
      default:
        throw ArgumentError('Invalid meal type: $mealType');
    }
  }
}

class _FoodItemTile extends StatelessWidget {
  final FoodItem food;
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: food.imageUrl != null 
          ? Image.network(food.imageUrl!) 
          : Icon(Icons.restaurant),
      title: Text(food.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (food.description != null) Text(food.description!),
          Row(
            children: [
              Text('${food.cuisine} • ${food.style}'),
              if (food.isVegetarian) Icon(Icons.eco, size: 16),
            ],
          ),
          if (food.isGroupedDelivery)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '📦 Delivered with ${food.deliverWith} • ${food.deliveryTime.start}-${food.deliveryTime.end}',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}

void _showLocationBottomSheet(BuildContext context, MealTypeEnum mealType, FoodItem food) {
  showModalBottomSheet(
    context: context,
    builder: (sheetContext) => _LocationSelectionBottomSheet(
      mealType: mealType,
      locations: food.availableLocations,
    ),
  );
}

class _LocationSelectionBottomSheet extends StatelessWidget {
  final MealTypeEnum mealType;
  final List<Location> locations;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BottomSheetHeader(title: 'Select Delivery Location'),
        ListView.builder(
          shrinkWrap: true,
          itemCount: locations.length,
          itemBuilder: (context, index) {
            final location = locations[index];
            return RadioListTile<String>(
              value: location.id,
              groupValue: null, // Track selected
              title: Text(location.name),
              subtitle: location.isDefault ? Text('★ Default') : null,
              onChanged: (_) {
                context.read<OrderFormBloc>().add(
                  OrderFormLocationSelectedEvent(
                    mealType: mealType,
                    location: location,
                  ),
                );
                Navigator.pop(context);
              },
            );
          },
        ),
      ],
    );
  }
}
```

**Submit Section**
```dart
class _BottomSubmitSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderFormBloc, OrderFormState>(
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: state.canSubmit 
                ? () => context.read<OrderFormBloc>().add(OrderFormSubmittedEvent())
                : null,
            child: Text('Order Now (${state.selectedMealCount} meals)'),
          ),
        );
      },
    );
  }
}
```

---

## Edge Cases & Handling

### 1. Date Change with Existing Selections
**Scenario**: User selects meals, then clicks "Change Date"  
**Solution**: Show confirmation dialog
```dart
void _onDateClearRequested() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Change Date?'),
      content: Text('This will clear your meal selections. Continue?'),
      actions: [
        TextButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context)),
        TextButton(
          child: Text('Change Date'),
          onPressed: () {
            Navigator.pop(context);
            bloc.add(OrderFormDateClearedEvent());
          },
        ),
      ],
    ),
  );
}
```

### 2. WITH_OTHER Delivery Mode
**Scenario**: Lunch delivered with Breakfast  
**Solution**: 
- Show badge in food list: "📦 Delivered with Breakfast"
- If breakfast already selected → auto-use same location, show snackbar
- If breakfast not selected → allow selection, validate on submit

### 3. Already Ordered Date
**Scenario**: User taps date with existing order  
**Solution**: Show banner with order number, status, and "View Order" button
```dart
if (state.isSelectedDateAlreadyOrdered) {
  return Container(
    padding: EdgeInsets.all(16),
    color: AppColors.warning.withOpacity(0.1),
    child: Column(
      children: [
        Icon(Icons.info_outline, color: AppColors.warning, size: 48),
        SizedBox(height: 8),
        Text('⚠️ You already have an order for ${state.selectedDate}'),
        Text('Order #${state.existingOrderNumber}'),
        Text('Status: ${state.existingOrderStatus}'),
        SizedBox(height: 16),
        ElevatedButton(
          child: Text('View Order Details'),
          onPressed: () => context.router.push(
            OrdersRoute(), // Navigate to orders tab, it will show this order
          ),
        ),
        TextButton(
          child: Text('Select Different Date'),
          onPressed: () {
            // Clear date selection
            context.read<OrderFormBloc>().add(OrderFormDateClearedEvent());
          },
        ),
      ],
    ),
  );
}
```

### 4. Holiday Date
**Scenario**: User taps holiday date  
**Solution**: Show banner, disable all meal cards
```dart
if (state.isSelectedDateHoliday) {
  return Container(
    child: Text('🎉 No deliveries on ${holidayName}'),
  );
}
```

### 5. No Locations Available
**Scenario**: User has no saved locations  
**Solution**: Show dialog to add location first
```dart
if (customer.locations.isEmpty) {
  showDialog(
    content: Text('Please add a delivery location first'),
    actions: [
      ElevatedButton(
        child: Text('Add Location'),
        onPressed: () => context.router.push(AddLocationRoute()),
      ),
    ],
  );
}
```

### 6. Subscription Expired
**Scenario**: User's subscription ended  
**Solution**: Show banner, disable all dates outside subscription period

### 7. Network Errors
**Scenario**: API call fails  
**Solution**: Show error with retry button
```dart
failure: (f) => ErrorContent(
  message: f.failure.message,
  onRetry: () => bloc.add(OrderFormLoadedEvent()),
),
```

### 8. Validation Errors (422)
**Scenario**: Backend returns validation errors  
**Solution**: Parse ApiValidationFailure and show field-specific errors

### 9. Location Mismatch for WITH_OTHER
**Scenario**: Breakfast at Home, Lunch at Office (both WITH_OTHER)  
**Solution**: Validate before submit, show error
```dart
if (lunch.deliverWith == 'BREAKFAST' && lunch.location != breakfast.location) {
  return 'Lunch must be delivered to same location as Breakfast';
}
```

### 10. Order Success
**Scenario**: Order created successfully  
**Solution**: Navigate to success screen or My Orders
```dart
listener: (context, state) {
  state.createOrderState.maybeMap(
    success: (data) {
      context.router.push(OrderSuccessRoute(order: data.data));
      // OR
      context.router.push(OrdersRoute());
    },
    orElse: () {},
  );
}
```

---

---

## Additional Improvements

### 1. Cutoff Hour Indicator
Show banner if ordering window is closing soon:
```dart
if (orderingRules.currentHour >= orderingRules.advanceOrderCutoffHour - 2) {
  Container(
    padding: EdgeInsets.all(12),
    color: AppColors.warning.withOpacity(0.1),
    child: Text('⏰ Order before ${orderingRules.advanceOrderCutoffHour}:00 today'),
  );
}
```

### 2. Calendar Auto-Scroll
Scroll to first available date on load:
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _scrollToFirstAvailableDate();
  });
}
```

### 3. Pull-to-Refresh
Add refresh functionality:
```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<OrderFormBloc>().add(OrderFormLoadedEvent());
    await Future.delayed(Duration(seconds: 1));
  },
  child: _CalendarSection(),
);
```

### 4. Empty Meal Type State
Show message when no food items available:
```dart
if (foodItems.isEmpty) {
  return Container(
    padding: EdgeInsets.all(16),
    child: Text('No ${mealType.name} items available for this day'),
  );
}
```

### 5. Food Code Display
Show food code in UI for support:
```dart
Text(
  '${food.name} (${food.code})',
  style: context.textTheme.titleMedium,
);
```

---

## Success Criteria

1. ✅ User can select date and see available meals
2. ✅ User can select multiple meals for same date
3. ✅ User can see delivery mode (separate vs grouped)
4. ✅ Grouped meals auto-select same location
5. ✅ Date change clears selections with confirmation
6. ✅ Holidays and ordered dates are disabled
7. ✅ Validation prevents invalid orders
8. ✅ Success navigation to order details/history
9. ✅ Error handling with retry options
10. ✅ All edge cases handled gracefully
