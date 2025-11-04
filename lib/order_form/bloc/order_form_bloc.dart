import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_api/src/user/models/models.dart' as user_models;

part 'order_form_event.dart';
part 'order_form_state.dart';

/// {@template order_form_bloc}
/// BLoC for managing order form state
///
/// Location Selection Logic:
/// - SEPARATE delivery mode → Always show location picker
/// - WITH_OTHER delivery mode:
///   - If paired meal already selected → Auto-use same location (no picker)
///   - If paired meal NOT selected → Show location picker
/// {@endtemplate}
class OrderFormBloc extends Bloc<OrderFormEvent, OrderFormState> {
  /// {@macro order_form_bloc}
  OrderFormBloc({
    required IUserRepository userRepository,
  }) : _userRepository = userRepository,
       super(OrderFormState.initial()) {
    on<OrderFormLoadedEvent>(_onLoaded);
    on<OrderFormDateSelectedEvent>(_onDateSelected);
    on<OrderFormDateClearRequestedEvent>(_onDateClearRequested);
    on<OrderFormDateClearedEvent>(_onDateCleared);
    on<OrderFormFoodSelectedEvent>(_onFoodSelected);
    on<OrderFormLocationSelectedEvent>(_onLocationSelected);
    on<OrderFormMealRemovedEvent>(_onMealRemoved);
    on<OrderFormNotesChangedEvent>(_onNotesChanged);
    on<OrderFormSubmittedEvent>(_onSubmitted);
  }

  final IUserRepository _userRepository;

  Future<void> _onLoaded(
    OrderFormLoadedEvent event,
    Emitter<OrderFormState> emit,
  ) async {
    // Use refreshing state if we already have data (avoids flickering)
    final hasData = state.availableDaysState.maybeMap(
      success: (_) => true,
      refreshing: (_) => true,
      orElse: () => false,
    );

    if (hasData) {
      final currentData = state.availableDaysState.maybeMap(
        success: (s) => s.data,
        refreshing: (r) => r.currentData,
        orElse: () => null,
      );
      if (currentData != null) {
        emit(
          state.copyWith(
            availableDaysState: DataState.refreshing(currentData),
          ),
        );
      }
    } else {
      emit(state.copyWith(availableDaysState: DataState.loading()));
    }

    final result = await _userRepository.getAvailableOrderDays();

    result.fold(
      (failure) => emit(
        state.copyWith(availableDaysState: DataState.failure(failure)),
      ),
      (data) => emit(
        state.copyWith(availableDaysState: DataState.success(data)),
      ),
    );
  }

  void _onDateSelected(
    OrderFormDateSelectedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    // If keepSelections is true, validate and preserve selections
    if (event.keepSelections && state.selectedMealCount > 0) {
      final validatedSelections = _validateSelectionsForDate(
        event.date,
        state.mealSelections,
      );

      emit(
        state.copyWith(
          selectedDate: event.date,
          mealSelections: validatedSelections,
        ),
      );
      return;
    }

    // If meals already selected and not keeping them, need confirmation
    if (state.selectedMealCount > 0 && !event.keepSelections) {
      // This will be handled in UI with a dialog
      // UI will dispatch OrderFormDateClearedEvent after confirmation
      return;
    }

    // Normal date selection - clear selections
    emit(
      state.copyWith(
        selectedDate: event.date,
        mealSelections: {},
      ),
    );
  }

  /// Validates meal selections for a new date
  /// Removes selections for unavailable meal types
  Map<MealType, OrderItemSelection?> _validateSelectionsForDate(
    String date,
    Map<MealType, OrderItemSelection?> currentSelections,
  ) {
    final validatedSelections = <MealType, OrderItemSelection?>{};

    for (final entry in currentSelections.entries) {
      final mealType = entry.key;
      final selection = entry.value;

      if (selection != null) {
        // Check if this meal type is available on the new date
        final newState = state.copyWith(selectedDate: date);
        if (newState.isMealTypeAvailable(mealType)) {
          validatedSelections[mealType] = selection;
        } else {
          log(
            '⚠️ Meal type $mealType not available on $date, removing selection',
          );
        }
      }
    }

    return validatedSelections;
  }

  void _onDateClearRequested(
    OrderFormDateClearRequestedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    // This event is for UI to know to show confirmation dialog
    // No state change here
  }

  void _onDateCleared(
    OrderFormDateClearedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    emit(
      state.copyWith(
        clearSelectedDate: true,
        mealSelections: {},
      ),
    );
  }

  /// Handles food selection with location already determined
  ///
  /// This event is dispatched after:
  /// - WITH_OTHER mode + paired meal exists → auto-selected location
  /// - WITH_OTHER mode + no paired meal → user picked location
  /// - SEPARATE mode → user picked location
  void _onFoodSelected(
    OrderFormFoodSelectedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    final food = event.food;
    final location = event.location;

    log(
      '📦 Food selected: ${food.name} (${food.deliveryMode}) for ${event.mealType}',
    );
    log('📍 Location: ${location.displayName}');

    // Location is already provided, directly add to selections
    final updatedSelections = Map<MealType, OrderItemSelection?>.from(
      state.mealSelections,
    );
    updatedSelections[event.mealType] = OrderItemSelection(
      food: food,
      location: location,
    );

    log('✅ Added to selections. Total selections: ${updatedSelections.length}');

    emit(
      state.copyWith(
        mealSelections: updatedSelections,
        clearActiveBottomSheet: true,
        clearPendingFood: true,
      ),
    );
  }

  void _onLocationSelected(
    OrderFormLocationSelectedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    final pendingFood = state.pendingFood;
    if (pendingFood == null) {
      log('No pending food when location selected');
      return;
    }

    final updatedSelections = Map<MealType, OrderItemSelection?>.from(
      state.mealSelections,
    );

    updatedSelections[event.mealType] = OrderItemSelection(
      food: pendingFood,
      location: event.location,
    );

    emit(
      state.copyWith(
        mealSelections: updatedSelections,
        clearActiveBottomSheet: true,
        clearPendingFood: true,
      ),
    );
  }

  void _onMealRemoved(
    OrderFormMealRemovedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    final updatedSelections = Map<MealType, OrderItemSelection?>.from(
      state.mealSelections,
    );
    updatedSelections.remove(event.mealType);

    emit(state.copyWith(mealSelections: updatedSelections));
  }

  void _onNotesChanged(
    OrderFormNotesChangedEvent event,
    Emitter<OrderFormState> emit,
  ) {
    emit(state.copyWith(orderNotes: event.notes));
  }

  Future<void> _onSubmitted(
    OrderFormSubmittedEvent event,
    Emitter<OrderFormState> emit,
  ) async {
    if (!state.canSubmit) return;

    // Validate WITH_OTHER constraints
    for (final entry in state.mealSelections.entries) {
      final selection = entry.value;
      if (selection == null) continue;

      if (selection.food.deliveryMode == DeliveryMode.withOther &&
          selection.food.deliverWith != null) {
        final pairedMealType = selection.food.deliverWith!.type;
        final pairedSelection = state.mealSelections[pairedMealType];

        if (pairedSelection != null) {
          if (selection.location.id != pairedSelection.location.id) {
            emit(
              state.copyWith(
                createOrderState: DataState.failure(
                  const UnknownFailure(
                    message: 'Meals delivered together must have same location',
                  ),
                ),
              ),
            );
            return;
          }
        }
      }
    }

    emit(state.copyWith(createOrderState: DataState.loading()));

    final request = user_models.CreateOrderRequest(
      orderDate: state.selectedDate!,
      notes: state.orderNotes,
      orderItems: state.mealSelections.entries
          .where((e) => e.value != null)
          .map(
            (e) => user_models.OrderItemRequest(
              foodItemId: e.value!.food.id,
              mealTypeId: e.value!.food.mealTypeId ?? '',
              deliveryLocationId: e.value!.location.id,
            ),
          )
          .toList(),
    );

    final result = await _userRepository.createOrder(request);

    result.fold(
      (failure) => emit(
        state.copyWith(createOrderState: DataState.failure(failure)),
      ),
      (data) => emit(
        state.copyWith(createOrderState: DataState.success(data)),
      ),
    );
  }
}
