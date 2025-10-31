# Subscription API Integration Plan

## Overview
This document outlines the complete implementation plan to connect the existing subscription UI to the backend API. The UI is already designed and functional with mock data; we need to integrate it with the real API endpoint.

---

## 1. API Layer Implementation

### 1.1 Create Subscription Models

#### **Directory Structure**
```
packages/instamess_api/lib/src/subscription/
  ├── models/
  │   ├── meal_subscription.dart
  │   ├── subscription_contact.dart
  │   ├── subscription_data.dart
  │   └── models.dart (barrel file)
  ├── subscription_facade_interface.dart
  ├── subscription_repository.dart
  └── subscription.dart (barrel file)
```

> **Note**: We use `MealSubscription` instead of `MealType` to avoid naming conflict with the existing `MealType` enum in `packages/instamess_api/lib/src/menu/models/meal_type.dart`.

#### **1.1.1 Meal Subscription Model**
**File**: `packages/instamess_api/lib/src/subscription/models/meal_subscription.dart`

```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template meal_subscription}
/// Represents a meal type subscription status
/// {@endtemplate}
class MealSubscription extends Equatable {
  /// {@macro meal_subscription}
  const MealSubscription({
    required this.id,
    required this.name,
    required this.systemActive,
    required this.customerActive,
    this.startDate,
    this.endDate,
  });

  /// Creates MealSubscription from JSON
  factory MealSubscription.fromJson(Map<String, dynamic> json) {
    return MealSubscription(
      id: pick(json, 'id').asStringOrThrow(),
      name: pick(json, 'name').asStringOrThrow(),
      systemActive: pick(json, 'systemActive').asBoolOrThrow(),
      customerActive: pick(json, 'customerActive').asBoolOrThrow(),
      startDate: pick(json, 'startDate').asStringOrNull(),
      endDate: pick(json, 'endDate').asStringOrNull(),
    );
  }

  /// Meal type unique ID
  final String id;

  /// Meal type name (e.g., "Breakfast", "Lunch", "Dinner")
  final String name;

  /// Whether this meal type is available in the system
  final bool systemActive;

  /// Whether customer is subscribed to this meal type
  final bool customerActive;

  /// Subscription start date (YYYY-MM-DD format)
  final String? startDate;

  /// Subscription end date (YYYY-MM-DD format)
  final String? endDate;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemActive': systemActive,
      'customerActive': customerActive,
      'startDate': startDate,
      'endDate': endDate,
    };
  }

  /// Returns true if customer has an active subscription
  bool get isSubscribed => customerActive && startDate != null && endDate != null;

  /// Returns true if available for subscription
  bool get isAvailable => systemActive && !customerActive;

  /// Formats date range for display (e.g., "02-December-2025 - 01-January-2026")
  String? get formattedDateRange {
    if (startDate == null || endDate == null) return null;
    
    try {
      final start = DateTime.parse(startDate!);
      final end = DateTime.parse(endDate!);
      
      final startFormatted = '${start.day.toString().padLeft(2, '0')}-${_monthName(start.month)}-${start.year}';
      final endFormatted = '${end.day.toString().padLeft(2, '0')}-${_monthName(end.month)}-${end.year}';
      
      return '$startFormatted - $endFormatted';
    } catch (_) {
      return null;
    }
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  List<Object?> get props => [id, name, systemActive, customerActive, startDate, endDate];
}
```

#### **1.1.2 Subscription Contact Model**
**File**: `packages/instamess_api/lib/src/subscription/models/subscription_contact.dart`

```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';

/// {@template subscription_contact}
/// Contact information for subscription support
/// {@endtemplate}
class SubscriptionContact extends Equatable {
  /// {@macro subscription_contact}
  const SubscriptionContact({
    required this.whatsapp,
    required this.phone,
  });

  /// Creates SubscriptionContact from JSON
  factory SubscriptionContact.fromJson(Map<String, dynamic> json) {
    return SubscriptionContact(
      whatsapp: pick(json, 'whatsapp').asStringOrThrow(),
      phone: pick(json, 'phone').asStringOrThrow(),
    );
  }

  /// WhatsApp number with country code (e.g., "+971501234567")
  final String whatsapp;

  /// Phone number with country code (e.g., "+971501234567")
  final String phone;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'whatsapp': whatsapp,
      'phone': phone,
    };
  }

  @override
  List<Object?> get props => [whatsapp, phone];
}
```

#### **1.1.3 Subscription Data Model**
**File**: `packages/instamess_api/lib/src/subscription/models/subscription_data.dart`

```dart
import 'package:deep_pick/deep_pick.dart';
import 'package:equatable/equatable.dart';
import 'package:instamess_api/src/cms/models/banner.dart';
import 'package:instamess_api/src/subscription/models/meal_subscription.dart';
import 'package:instamess_api/src/subscription/models/subscription_contact.dart';

/// {@template subscription_data}
/// Complete subscription page data
/// {@endtemplate}
class SubscriptionData extends Equatable {
  /// {@macro subscription_data}
  const SubscriptionData({
    required this.mealSubscriptions,
    required this.contact,
    this.banner,
  });

  /// Creates SubscriptionData from JSON
  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      mealSubscriptions: pick(json, 'mealTypes').asListOrEmpty((pick) {
        return MealSubscription.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      banner: pick(json, 'banner').letOrNull((pick) {
        return Banner.fromJson(pick.asMapOrThrow<String, dynamic>());
      }),
      contact: SubscriptionContact.fromJson(
        pick(json, 'contact').asMapOrThrow<String, dynamic>(),
      ),
    );
  }

  /// List of meal subscriptions with status
  final List<MealSubscription> mealSubscriptions;

  /// Promotional banner for subscription page (nullable)
  final Banner? banner;

  /// Contact information for support
  final SubscriptionContact contact;

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'mealTypes': mealSubscriptions.map((e) => e.toJson()).toList(),
      'banner': banner?.toJson(),
      'contact': contact.toJson(),
    };
  }

  /// Returns only subscribed meals
  List<MealSubscription> get subscribedMeals {
    return mealSubscriptions.where((meal) => meal.isSubscribed).toList();
  }

  /// Returns available meals for subscription
  List<MealSubscription> get availableMeals {
    return mealSubscriptions.where((meal) => meal.isAvailable).toList();
  }

  @override
  List<Object?> get props => [mealSubscriptions, banner, contact];
}
```

#### **1.1.4 Models Barrel File**
**File**: `packages/instamess_api/lib/src/subscription/models/models.dart`

```dart
export 'meal_subscription.dart';
export 'subscription_contact.dart';
export 'subscription_data.dart';
```

---

### 1.2 Create Repository Interface and Implementation

#### **1.2.1 Repository Interface**
**File**: `packages/instamess_api/lib/src/subscription/subscription_facade_interface.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart';

/// {@template subscription_facade_interface}
/// Interface for subscription operations
/// {@endtemplate}
abstract class ISubscriptionRepository {
  /// Get subscription data including meal types, banner, and contact info
  Future<Either<Failure, SubscriptionData>> getSubscription();
}
```

#### **1.2.2 Repository Implementation**
**File**: `packages/instamess_api/lib/src/subscription/subscription_repository.dart`

```dart
import 'dart:developer';

import 'package:api_client/api_client.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/src/subscription/models/models.dart';
import 'package:instamess_api/src/subscription/subscription_facade_interface.dart';

/// {@template subscription_repository}
/// Repository which manages subscription related requests.
/// {@endtemplate}
class SubscriptionRepository implements ISubscriptionRepository {
  /// {@macro subscription_repository}
  SubscriptionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Either<Failure, SubscriptionData>> getSubscription() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        'subscription',
      );

      return response.fold(
        left,
        (r) {
          // Check for null response body
          if (r.data == null) {
            log('No response body in SubscriptionRepository.getSubscription');
            return left(
              const UnknownApiFailure(
                500,
                'No response data received',
              ),
            );
          }

          final body = r.data!;
          final success = body['success'] as bool? ?? false;

          // Check success flag
          if (!success) {
            final message = body['message'] as String? ?? 'Failed to fetch subscription';
            log('API returned success: false - $message');
            return left(
              UnknownApiFailure(
                r.statusCode ?? 500,
                message,
              ),
            );
          }

          // Parse data field
          final data = body['data'];
          if (data == null) {
            log('No data field in response');
            return left(
              const UnknownApiFailure(
                500,
                'No subscription data in response',
              ),
            );
          }

          // Parse and return subscription data
          try {
            return Right(
              SubscriptionData.fromJson(data as Map<String, dynamic>),
            );
          } catch (e, s) {
            log(
              'Failed to parse subscription data: $e',
              error: e,
              stackTrace: s,
            );
            return left(
              UnknownApiFailure(
                r.statusCode ?? 500,
                'Failed to parse subscription data',
              ),
            );
          }
        },
      );
    } catch (e, s) {
      log(
        'Unknown error in SubscriptionRepository.getSubscription: $e',
        error: e,
        stackTrace: s,
      );
      return left(const UnknownFailure());
    }
  }
}
```

#### **1.2.3 Subscription Barrel File**
**File**: `packages/instamess_api/lib/src/subscription/subscription.dart`

```dart
export 'models/models.dart';
export 'subscription_facade_interface.dart';
export 'subscription_repository.dart';
```

---

### 1.3 Update Main API File

**File**: `packages/instamess_api/lib/instamess_api.dart`

Add export:
```dart
export 'src/subscription/subscription.dart';
```

---

### 1.4 Expose Subscription Facade in InstaMessApi

**File**: `packages/instamess_api/lib/src/instamess_api.dart`

Add the following:

1. **Import** at the top:
```dart
import 'package:instamess_api/src/subscription/subscription.dart';
```

2. **Add lazy getter** for subscription facade:
```dart
/// Subscription repository
late final ISubscriptionRepository subscriptionFacade = SubscriptionRepository(_apiClient);
```

---

## 2. Feature Layer Implementation (BLoC)

### 2.1 Create BLoC Files

#### **Directory Structure**
```
lib/subscriptions/
  ├── bloc/
  │   ├── subscriptions_bloc.dart
  │   ├── subscriptions_event.dart
  │   └── subscriptions_state.dart
  └── view/
      ├── subscriptions_screen.dart (refactor existing)
      └── widgets/
          ├── subscription_card.dart (update)
          ├── promotional_banner.dart (update)
          └── contact_button.dart (update to add onTap)
```

#### **2.1.1 Events**
**File**: `lib/subscriptions/bloc/subscriptions_event.dart`

```dart
part of 'subscriptions_bloc.dart';

@immutable
sealed class SubscriptionsEvent {}

/// Event to load subscription data
class SubscriptionsLoadedEvent extends SubscriptionsEvent {}

/// Event to refresh subscription data
class SubscriptionsRefreshedEvent extends SubscriptionsEvent {}
```

#### **2.1.2 State**
**File**: `lib/subscriptions/bloc/subscriptions_state.dart`

```dart
part of 'subscriptions_bloc.dart';

@immutable
class SubscriptionsState {
  const SubscriptionsState({
    required this.subscriptionState,
  });

  factory SubscriptionsState.initial() {
    return SubscriptionsState(
      subscriptionState: DataState.initial(),
    );
  }

  final DataState<SubscriptionData> subscriptionState;

  bool get isLoading => subscriptionState.isLoading;
  bool get isRefreshing => subscriptionState.isRefreshing;
  bool get isSuccess => subscriptionState.isSuccess;
  bool get isFailure => subscriptionState.isFailure;

  SubscriptionData? get subscriptionData {
    return subscriptionState.maybeMap(
      success: (state) => state.data,
      refreshing: (state) => state.currentData,
      orElse: () => null,
    );
  }

  Failure? get failure {
    return subscriptionState.maybeMap(
      failure: (state) => state.failure,
      orElse: () => null,
    );
  }

  SubscriptionsState copyWith({
    DataState<SubscriptionData>? subscriptionState,
  }) {
    return SubscriptionsState(
      subscriptionState: subscriptionState ?? this.subscriptionState,
    );
  }

  @override
  String toString() => '''
SubscriptionsState {
  subscriptionState: $subscriptionState
}''';
}
```

#### **2.1.3 BLoC**
**File**: `lib/subscriptions/bloc/subscriptions_bloc.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:bloc/bloc.dart';
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
import 'package:instamess_api/instamess_api.dart';

part 'subscriptions_event.dart';
part 'subscriptions_state.dart';

class SubscriptionsBloc extends Bloc<SubscriptionsEvent, SubscriptionsState> {
  SubscriptionsBloc({
    required this.subscriptionFacade,
  }) : super(SubscriptionsState.initial()) {
    on<SubscriptionsEvent>((event, emit) async {
      switch (event) {
        case SubscriptionsLoadedEvent():
          await _onLoadedEvent(event, emit);
        case SubscriptionsRefreshedEvent():
          await _onRefreshedEvent(event, emit);
      }
    });
  }

  final ISubscriptionRepository subscriptionFacade;

  Future<void> _onLoadedEvent(
    SubscriptionsLoadedEvent event,
    Emitter<SubscriptionsState> emit,
  ) async {
    emit(state.copyWith(subscriptionState: DataState.loading()));

    final result = await subscriptionFacade.getSubscription();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            subscriptionState: DataState.failure(failure),
          ),
        );
      },
      (subscriptionData) {
        emit(
          state.copyWith(
            subscriptionState: DataState.success(subscriptionData),
          ),
        );
      },
    );
  }

  Future<void> _onRefreshedEvent(
    SubscriptionsRefreshedEvent event,
    Emitter<SubscriptionsState> emit,
  ) async {
    // Use refreshing state if we already have data
    final currentState = state.subscriptionState;
    if (currentState is DataStateSuccess<SubscriptionData>) {
      emit(
        state.copyWith(
          subscriptionState: DataState.refreshing(currentState.data),
        ),
      );
    } else {
      emit(state.copyWith(subscriptionState: DataState.loading()));
    }

    final result = await subscriptionFacade.getSubscription();

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            subscriptionState: DataState.failure(failure),
          ),
        );
      },
      (subscriptionData) {
        emit(
          state.copyWith(
            subscriptionState: DataState.success(subscriptionData),
          ),
        );
      },
    );
  }
}
```

---

## 3. UI Layer Updates

### 3.1 Update SubscriptionsScreen

**File**: `lib/subscriptions/view/subscriptions_screen.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:app_ui/app_ui.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/subscriptions/bloc/subscriptions_bloc.dart';
import 'package:instamess_app/subscriptions/view/widgets/contact_button.dart';
import 'package:instamess_app/subscriptions/view/widgets/promotional_banner.dart';
import 'package:instamess_app/subscriptions/view/widgets/subscription_card.dart';
import 'package:url_launcher/url_launcher.dart';

@RoutePage()
class SubscriptionsScreen extends StatelessWidget {
  const SubscriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionsBloc(
        subscriptionFacade: context.read<ISubscriptionRepository>(),
      )..add(SubscriptionsLoadedEvent()),
      child: const _SubscriptionsScreenContent(),
    );
  }
}

class _SubscriptionsScreenContent extends StatelessWidget {
  const _SubscriptionsScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<SubscriptionsBloc, SubscriptionsState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<SubscriptionsBloc>().add(SubscriptionsRefreshedEvent());
              await context.read<SubscriptionsBloc>().stream.firstWhere(
                (state) => !state.isRefreshing,
              );
            },
            child: CustomScrollView(
              slivers: [
                _HeaderSection(),
                _ContentSection(state: state),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text(
                'Subscription',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your Current Subscription is listed below',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.state});

  final SubscriptionsState state;

  @override
  Widget build(BuildContext context) {
    return state.subscriptionState.map(
      initial: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      loading: (_) => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
      success: (successState) => _SuccessContent(data: successState.data),
      failure: (failureState) => _ErrorContent(failure: failureState.failure),
      refreshing: (refreshingState) =>
          _SuccessContent(data: refreshingState.currentData),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                failure.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<SubscriptionsBloc>().add(SubscriptionsLoadedEvent());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.data});

  final SubscriptionData data;

  @override
  Widget build(BuildContext context) {
    final subscribedMeals = data.subscribedMeals;
    final availableMeals = data.availableMeals;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subscribed Meal Types
            if (subscribedMeals.isNotEmpty) ...[
              ...subscribedMeals.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SubscriptionCard(
                    title: meal.name,
                    dateRange: meal.formattedDateRange ?? 'No date range',
                    isSubscribed: true,
                  ),
                ),
              ),
            ],

            // Available Meal Types (not subscribed but available)
            if (availableMeals.isNotEmpty) ...[
              if (subscribedMeals.isNotEmpty) const SizedBox(height: 8),
              ...availableMeals.map(
                (meal) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: SubscriptionCard(
                    title: meal.name,
                    dateRange: 'Available for subscription',
                    isSubscribed: false,
                  ),
                ),
              ),
            ],

            // Empty state if no meals at all
            if (subscribedMeals.isEmpty && availableMeals.isEmpty) ...[
              const SizedBox(height: 48),
              Center(
                child: Text(
                  'No subscriptions available',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 48),
            ],

            const SizedBox(height: 16),

            // Promotional Banner
            if (data.banner != null) ...[
              PromotionalBanner(banner: data.banner!),
              const SizedBox(height: 32),
            ],

            // Contact Buttons
            ContactButton(
              icon: Brand(Brands.whatsapp),
              text: 'Contact Via WhatsApp',
              color: const Color(0xff25D366),
              onTap: () => _launchWhatsApp(context, data.contact.whatsapp),
            ),
            const SizedBox(height: 16),
            ContactButton(
              icon: const Icon(Icons.phone, color: AppColors.white),
              text: 'Contact Via Phone',
              color: AppColors.appRed,
              onTap: () => _launchPhone(context, data.contact.phone),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Future<void> _launchWhatsApp(BuildContext context, String phone) async {
    // Remove + and format for WhatsApp
    final formattedPhone = phone.replaceAll('+', '').replaceAll(' ', '');
    final uri = Uri.parse('https://wa.me/$formattedPhone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }
}
```

---

### 3.2 Update SubscriptionCard Widget

**File**: `lib/subscriptions/view/widgets/subscription_card.dart`

```dart
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({
    required this.title,
    required this.dateRange,
    this.isSubscribed = true,
    super.key,
  });

  final String title;
  final String dateRange;
  final bool isSubscribed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isSubscribed
            ? AppColors.appOrange.withValues(alpha: 0.1)
            : AppColors.textSecondary.withValues(alpha: 0.05),
        border: Border.all(
          color: isSubscribed ? AppColors.appRed : AppColors.textSecondary,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateRange,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isSubscribed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.appRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

### 3.3 Update PromotionalBanner Widget

**File**: `lib/subscriptions/view/widgets/promotional_banner.dart`

```dart
import 'package:app_ui/app_ui.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/router/utils/banner_navigation_handler.dart';

class PromotionalBanner extends StatelessWidget {
  const PromotionalBanner({
    required this.banner,
    super.key,
  });

  final Banner banner;

  @override
  Widget build(BuildContext context) {
    final image = banner.images.isNotEmpty ? banner.images.first : null;

    return GestureDetector(
      onTap: image?.redirectUrl != null
          ? () => BannerNavigationHandler.handleBannerTap(
                context,
                image!.redirectUrl!,
              )
          : null,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.appOrange, AppColors.appRed],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Background image
            if (image?.imageUrl != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(image!.imageUrl),
                      fit: BoxFit.cover,
                      opacity: 0.3,
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  if (banner.description != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      banner.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 3.4 Update ContactButton Widget

**File**: `lib/subscriptions/view/widgets/contact_button.dart`

```dart
import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
    super.key,
  });

  final Widget icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 4. Dependency Injection Setup

### 4.1 Register Subscription Repository

**File**: `lib/app/view/app.dart`

In the `MultiRepositoryProvider`, add:

```dart
RepositoryProvider<ISubscriptionRepository>(
  create: (_) => widget.api.subscriptionFacade,
),
```

---

## 5. Add url_launcher Dependency

**File**: `pubspec.yaml`

Add to dependencies:
```yaml
dependencies:
  url_launcher: ^6.3.1
```

Run:
```sh
flutter pub get
```

---

## 6. Testing Strategy

### 6.1 Unit Tests for Models

**File**: `packages/instamess_api/test/subscription/models/meal_subscription_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:instamess_api/instamess_api.dart';

void main() {
  group('MealSubscription', () {
    test('fromJson creates valid MealSubscription with all fields', () {
      final json = {
        'id': 'cm123abc',
        'name': 'Breakfast',
        'systemActive': true,
        'customerActive': true,
        'startDate': '2025-10-01',
        'endDate': '2025-11-30',
      };

      final mealType = MealSubscription.fromJson(json);

      expect(mealType.id, 'cm123abc');
      expect(mealType.name, 'Breakfast');
      expect(mealType.systemActive, true);
      expect(mealType.customerActive, true);
      expect(mealType.startDate, '2025-10-01');
      expect(mealType.endDate, '2025-11-30');
    });

    test('fromJson handles null dates', () {
      final json = {
        'id': 'cm125ghi',
        'name': 'Dinner',
        'systemActive': true,
        'customerActive': false,
        'startDate': null,
        'endDate': null,
      };

      final mealType = MealType.fromJson(json);

      expect(mealType.startDate, null);
      expect(mealType.endDate, null);
    });

    test('isSubscribed returns true when customerActive and dates exist', () {
      final mealType = MealSubscription(
        id: 'test',
        name: 'Breakfast',
        systemActive: true,
        customerActive: true,
        startDate: '2025-10-01',
        endDate: '2025-11-30',
      );

      expect(mealType.isSubscribed, true);
    });

    test('isSubscribed returns false when dates are null', () {
      final mealType = MealSubscription(
        id: 'test',
        name: 'Dinner',
        systemActive: true,
        customerActive: true,
        startDate: null,
        endDate: null,
      );

      expect(mealType.isSubscribed, false);
    });

    test('isAvailable returns true when systemActive and not customerActive', () {
      final mealType = MealSubscription(
        id: 'test',
        name: 'Lunch',
        systemActive: true,
        customerActive: false,
      );

      expect(mealType.isAvailable, true);
    });

    test('formattedDateRange returns correctly formatted string', () {
      final mealType = MealSubscription(
        id: 'test',
        name: 'Breakfast',
        systemActive: true,
        customerActive: true,
        startDate: '2025-12-02',
        endDate: '2026-01-01',
      );

      expect(mealType.formattedDateRange, '02-December-2025 - 01-January-2026');
    });
  });
}
```

### 6.2 BLoC Tests

**File**: `test/subscriptions/bloc/subscriptions_bloc_test.dart`

```dart
import 'package:api_client/api_client.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/subscriptions/bloc/subscriptions_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionRepository extends Mock implements ISubscriptionRepository {}

void main() {
  late ISubscriptionRepository mockRepository;

  setUp(() {
    mockRepository = MockSubscriptionRepository();
  });

  group('SubscriptionsBloc', () {
    final mockData = SubscriptionData(
      mealSubscriptions: [
        MealSubscription(
          id: '1',
          name: 'Breakfast',
          systemActive: true,
          customerActive: true,
          startDate: '2025-10-01',
          endDate: '2025-11-30',
        ),
      ],
      contact: SubscriptionContact(whatsapp: '+971501234567', phone: '+971501234567'),
    );

    test('initial state is correct', () {
      final bloc = SubscriptionsBloc(subscriptionFacade: mockRepository);
      expect(bloc.state.subscriptionState, isA<DataStateInitial>());
    });

    blocTest<SubscriptionsBloc, SubscriptionsState>(
      'emits loading then success when data is fetched successfully',
      build: () {
        when(() => mockRepository.getSubscription())
            .thenAnswer((_) async => Right(mockData));
        return SubscriptionsBloc(subscriptionFacade: mockRepository);
      },
      act: (bloc) => bloc.add(SubscriptionsLoadedEvent()),
      expect: () => [
        SubscriptionsState(subscriptionState: DataState.loading()),
        SubscriptionsState(subscriptionState: DataState.success(mockData)),
      ],
    );

    blocTest<SubscriptionsBloc, SubscriptionsState>(
      'emits loading then failure when fetch fails',
      build: () {
        when(() => mockRepository.getSubscription())
            .thenAnswer((_) async => left(const UnknownFailure()));
        return SubscriptionsBloc(subscriptionFacade: mockRepository);
      },
      act: (bloc) => bloc.add(SubscriptionsLoadedEvent()),
      expect: () => [
        SubscriptionsState(subscriptionState: DataState.loading()),
        SubscriptionsState(subscriptionState: DataState.failure(const UnknownFailure())),
      ],
    );
  });
}
```

---

## 7. Implementation Checklist

### Phase 1: API Layer (packages/instamess_api)
- [ ] Create `packages/instamess_api/lib/src/subscription/` directory
- [ ] Create `models/` subdirectory
- [ ] Implement `meal_subscription.dart` model (renamed from `meal_type` to avoid conflict)
- [ ] Implement `subscription_contact.dart` model
- [ ] Implement `subscription_data.dart` model
- [ ] Create `models/models.dart` barrel file
- [ ] Create `subscription_facade_interface.dart`
- [ ] Implement `subscription_repository.dart`
- [ ] Create `subscription/subscription.dart` barrel file
- [ ] Update `instamess_api.dart` to export subscription module
- [ ] Add `subscriptionFacade` getter to `InstaMessApi` class

### Phase 2: Feature Layer (lib/subscriptions)
- [ ] Create `lib/subscriptions/bloc/` directory
- [ ] Implement `subscriptions_event.dart`
- [ ] Implement `subscriptions_state.dart`
- [ ] Implement `subscriptions_bloc.dart`
- [ ] Update `subscriptions_screen.dart` to use BLoC
- [ ] Update `subscription_card.dart` to support subscribed/available states
- [ ] Update `promotional_banner.dart` to accept Banner model
- [ ] Update `contact_button.dart` to add onTap callback

### Phase 3: Dependency Injection
- [ ] Register `ISubscriptionRepository` in `app.dart`
- [ ] Add `url_launcher` package to `pubspec.yaml`
- [ ] Run `flutter pub get`

### Phase 4: Testing
- [ ] Write unit tests for `MealSubscription` model
- [ ] Write unit tests for `SubscriptionContact` model
- [ ] Write unit tests for `SubscriptionData` model
- [ ] Write unit tests for `SubscriptionRepository`
- [ ] Write BLoC tests for `SubscriptionsBloc`
- [ ] Write widget tests for `SubscriptionsScreen`

### Phase 5: Manual Testing
- [ ] Test successful data load
- [ ] Test pull-to-refresh
- [ ] Test error state and retry
- [ ] Test WhatsApp contact launch
- [ ] Test phone contact launch
- [ ] Test banner tap navigation
- [ ] Test with different meal type states (subscribed/available)
- [ ] Test with null banner
- [ ] Test empty state (no subscriptions)

---

## 8. Expected Behavior

### 8.1 Loading State
- Show centered `CircularProgressIndicator` while fetching data
- Header remains visible

### 8.2 Success State
- Display subscribed meal types with "Active" badge
- Display available meal types with lighter styling
- Show promotional banner if available
- Show contact buttons with working links
- Pull-to-refresh enabled

### 8.3 Refreshing State
- Keep showing current data
- Show refresh indicator at top
- No full-screen loader

### 8.4 Error State
- Show error icon and message
- Show "Retry" button
- Error message from `Failure.message`

### 8.5 Empty State
- Show "No subscriptions available" message if no meal types returned

---

## 9. Edge Cases to Handle

1. **No meal types**: Display empty state message
2. **Null banner**: Skip banner section
3. **Invalid phone numbers**: Show error snackbar if can't launch
4. **Network timeout**: Repository returns `UnknownFailure`
5. **401 Unauthorized**: Handle via `ApiClient` interceptor (session expired)
6. **Malformed JSON**: Caught in repository, returns `UnknownApiFailure`

---

## 10. Post-Implementation Enhancements (Future)

- [ ] Add subscription purchase flow for available meal types
- [ ] Add subscription cancellation functionality
- [ ] Add notifications when subscription is about to expire
- [ ] Cache subscription data locally for offline viewing
- [ ] Add skeleton loaders instead of plain CircularProgressIndicator

---

## 11. Notes

- Follow the same pattern as `HomeBloc` and `HomeScreen`
- Use `DataState<T>` for all async operations
- Always handle both `left` and `right` in `Either.fold()`
- Use `url_launcher` for WhatsApp and phone links
- Banner navigation uses existing `BannerNavigationHandler`
- Date formatting uses helper method in `MealSubscription` model
- Contact numbers should include country code (+971)
- **Renamed `MealType` → `MealSubscription`** to avoid conflict with existing `MealType` enum in menu module

---

## 12. Architecture Decision: Separate Repositories

### Why Subscriptions and Notifications Should Be Separate

**Subscriptions and Notifications are INDEPENDENT domains** and should each have their own repository:

```
packages/instamess_api/lib/src/
  ├── subscription/     ← Subscription management (this feature)
  └── notifications/    ← Notification management (future)
```

**Reasons:**
1. **Single Responsibility** - Each handles one business domain
2. **Different Models** - Completely unrelated data structures
3. **Independent Evolution** - Changes don't affect each other
4. **Better Testing** - Isolated, focused tests
5. **Follows Pattern** - Consistent with existing `auth/`, `cms/`, `menu/`, `dashboard/`

**Subscriptions Domain:**
- GET `/api/subscription`
- Models: `MealSubscription`, `SubscriptionData`, `SubscriptionContact`
- Purpose: Manage customer's meal subscriptions

**Notifications Domain (Future):**
- GET `/api/notifications`
- Models: `Notification`, `NotificationGroup`, etc.
- Purpose: User notifications and alerts

---

**Generated**: October 31, 2025  
**API Version**: v1  
**Status**: Ready for implementation
