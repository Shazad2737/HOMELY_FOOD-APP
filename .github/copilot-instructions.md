# Homely App - AI Copilot Instructions

## Project Overview

This is a **multi-flavor Flutter application** (development, staging, production) for an instant messaging/food delivery platform. The project uses **BLoC for state management**, **Functional Programming patterns (fpdart)**, and **modular package architecture** following Very Good CLI conventions.

## Architecture & Project Structure

### Three-Layer Modular Architecture

```
lib/                    # Main app (presentation + routing)
packages/
  ├── core/            # Utilities, enums, helpers, form validators
  ├── api_client/      # HTTP client, failure models, DataState wrapper
  ├── app_ui/          # Shared UI components, themes, styles
  └── homely_api/   # API domain layer + session management
```

**Key principle**: Each package is self-contained. The main app primarily depends on `homely_api` for domain facades, and also directly uses `core` (e.g., `DataState`, form inputs), and `app_ui` (components/tokens). Network calls must go through `homely_api` facades — avoid using `ApiClient` directly in the app layer.

### Feature Structure

Each feature (auth, home, menu, profile) follows this pattern:

```
lib/feature_name/
  ├── bloc/            # BLoC logic with event/state (3 files: topic_bloc.dart, topic_event.dart, topic_state.dart, state and event can be part files)
  ├── view/            # Screens and widgets
  ├── models/          # Feature-specific models (if needed)
  └── sub-feature/     # Sub-features
```

## Critical Architectural Patterns

### 1. DataState<T> - Async UI State Management

All async operations use the `DataState<T>` sealed class (from the `core` package):

```dart
DataState<HomePageData> →
  .initial()     // No request made yet
  .loading()     // Fetching data
  .success(data) // Success with data
  .failure(failure)  // Error occurred
  .refreshing(currentData)  // Pulling fresh data while showing stale data
```

**Usage pattern** in BLoCs:

```dart
state.copyWith(homePageState: DataState.loading());
// Then fold the repository response:
result.fold(
  (failure) => state.copyWith(homePageState: DataState.failure(failure)),
  (data) => state.copyWith(homePageState: DataState.success(data)),
);
```

Extend the pattern with a non-blocking refresh: when you already have data and trigger a refresh (e.g., pull-to-refresh), emit `DataState.refreshing(currentData)` so the UI keeps showing the last good content while indicating a background refresh.

**UI consumption** with `.map()` or `.maybeMap()`:

```dart
state.homePageState.map(
  initial: (_) => LoadingWidget(),
  loading: (_) => LoadingWidget(),
  success: (s) => SuccessContent(data: s.data),
  failure: (f) => ErrorContent(failure: f.failure),
  refreshing: (r) => SuccessContent(data: r.currentData), // Show stale + indicator
)
```

Refreshing vs Loading — quick guide:

- Use loading when:
  - First fetch with no existing data
  - Navigating to a screen where data is unknown
  - Retrying after an error and there’s no cached data
- Use refreshing when:
  - You already have data and trigger pull-to-refresh
  - App regains focus/connection and you want to revalidate
  - Background revalidate while user keeps viewing content
- Retry behavior:
  - If current state is success, prefer refreshing on retry
  - If current state is failure and there’s no prior data, use loading
- UI pairing:
  - loading: full-page spinner/skeleton (e.g., SliverFillRemaining)
  - refreshing: keep success UI; show RefreshIndicator/inline progress
- Expected transitions:
  - success → refreshing → success/failure
  - initial/loading → success/failure
  - failure(no data) → loading → success/failure

### 2. Functional Error Handling with fpdart

All repository methods return `Either<Failure, T>`:

```dart
Future<Either<Failure, HomePageData>> getHomePage();
```

**Always use `.fold()`** to handle both left (failure) and right (success) cases:

```dart
result.fold(
  (failure) { /* handle error */ },
  (data) { /* handle success */ },
);
```

Sealed `Failure` classes in `api_client/lib/src/failures/`:

- `UnknownFailure` - Generic unknown error
- `ApiFailure` (sealed) - Base for API errors
  - `ApiValidationFailure` - 422 validation errors with field-level errors
  - `UnknownApiFailure` - API returned error but didn't match expected schema
- `StorageFailure` - Local storage operations failed

### 3. Authentication Flow & Session Management

**SessionManager** (in `homely_api`) is the single source of truth:

- Stores token and user in secure storage
- Emits reactive streams: `token$`, `user$`, `session$`
- AuthBloc listens to `session$` changes and emits auth state
- Router uses AuthBloc state for navigation guarding

**Auth States** (in `auth_bloc.dart`):

- `AuthInitial` → Starting up
- `Authenticated(user)` → User logged in, proceed to shell
- `Unauthenticated([message])` → Show login/signup screens

**Auth Flow**: Splash → LoginBloc → SignupBloc → DeliveryAddressBloc → MainShellRoute (nested)

Route guarding rules (see `lib/router/guards/auth_guard.dart`):

- Public routes when unauthenticated: `LoginRoute`, `SignupRoute`, `DeliveryAddressRoute`, `OtpRoute`.
- Authenticated users navigating to `Splash`, `Login`, `Signup`, or `Otp` are redirected to `MainShellRoute` via `replaceAll`.
- Unauthenticated access to protected routes replaces the stack with `LoginRoute`.
- Guard uses `router.root.topRoute` checks to avoid double navigation.

### 4. Multi-Flavor Configuration

Defined in `lib/main_*.dart` (development, staging, production):

```dart
final api = HomelyApi(baseUrl: 'http://localhost:4000'); // Dev example
return App(api: api, releaseMode: ReleaseMode.development);
```

**Build commands**:

```sh
flutter run --flavor development --target lib/main_development.dart
flutter run --flavor staging --target lib/main_staging.dart
flutter run --flavor production --target lib/main_production.dart
```

The `ReleaseMode` enum adds a banner in dev/staging builds for clarity.

### 5. Routing with AutoRoute

- `AppRouter` extends `RootStackRouter` and uses `AuthGuard` to protect routes
- Routes defined in `lib/router/router.dart`
- Generated code in `lib/router/router.gr.dart` (do NOT edit manually)

- Screens must be annotated with `@RoutePage()` for AutoRoute to generate routes.
- **After modifying routes**: Run `flutter pub run build_runner build --delete-conflicting-outputs` (watch mode optional if preferred).
- After rebuild is complete, update router.dart routes list to include new routes.

**Route Structure**:

```
Splash (initial: true)
  → Login / Signup / OTP / DeliveryAddress
  → MainShellRoute (nested tabs)
    ├── Home (initial: true)
    ├── Menu
    ├── OrderForm
    ├── Subscriptions
    └── Profile
```

### 6. BLoC Event Handling Pattern

Always use **sealed event classes** and exhaustive `switch` statements when you don't need complex event handling; otherwise use multiple `on<Event>` handlers (with transformers as needed).

```dart
class MyBloc extends Bloc<MyEvent, MyState> {
  MyBloc() : super(MyState.initial()) {
    on<MyEvent>((event, emit) async {
      switch (event) {
        case MyLoadedEvent():
          await _onLoadedEvent(event, emit);
        case MyRefreshedEvent():
          await _onRefreshedEvent(event, emit);
        // Compiler enforces all cases covered
      }
    });
  }

  Future<void> _onLoadedEvent(MyLoadedEvent event, Emitter<MyState> emit) async {
    // Handler methods
  }
}
```

## Form Handling with Formz

- Use `Formz` for input validation; states can implement `FormzMixin` to expose `isValid` based on inputs.
- Reuse validated inputs from `core/lib/src/form_inputs/` (`Name`, `Phone`, `Password`, `ConfirmedPassword`).
- Toggle `showErrorMessages` to drive validation UI, and guard submissions with `if (!state.isValid) return;`.
- Example pattern in state classes: see `lib/auth/signup/bloc/signup_state.dart`.

## Code Quality & Linting

- **Analysis**: Uses `very_good_analysis` for strict linting
- **Formatting**: Run `dart format .` before commits
- **Disable lints locally** with `// ignore: rule_name` only when justified

Check `analysis_options.yaml` for disabled rules (currently `public_member_api_docs` is disabled).

## Dependency Injection & Service Location

**No GetIt/Provider—Dependencies injected via constructor**:

```dart
// In app.dart, BlocProviders are set up:
BlocProvider<HomeBloc>(
  create: (context) => HomeBloc(cmsFacade: context.read<ICmsRepository>()),
),

// Inject via RepositoryProvider or context.read in BloCs
```

**API instance** created in `main_*.dart` and passed to `App`, then exposed via repositories in the widget tree:

```dart
MultiRepositoryProvider(
  providers: [
    RepositoryProvider(create: (_) => widget.api.cmsFacade),
    RepositoryProvider(create: (_) => widget.api.authFacade),
  ],
  // ...
)
```

Additional DI guidance:

- Create long-lived BLoCs (e.g., `AuthBloc`) at app bootstrap (`AppState.initState`) and provide via `MultiBlocProvider`.
- Screen-scoped BLoCs (e.g., `HomeBloc`) can be created in the screen's `build()` with `BlocProvider` when their state is not shared.
- Acquire facades via `context.read<ICmsRepository>()` / `context.read<IAuthFacade>()`; do not instantiate repositories in widgets.

SessionManager and cancellation:

- `SessionManager` provides a session-scoped `cancelToken`. Long-running requests should opt-in to cancellation when a session ends (logout).

## Common Workflows

### Adding a New Feature

1. Create folder in `lib/feature_name/` with `bloc/`, `view/`, `models/` subdirs
2. Create sealed event/state classes in `bloc/`
3. Create BLoC with exhaustive `switch` on events
4. Create screens/widgets in `view/` with `@RoutePage()` annotation
5. Run `flutter pub run build_runner build --delete-conflicting-outputs`
6. Add route in `lib/router/router.dart` route list
7. Create corresponding repository method in `packages/homely_api/`

### Adding a New API Endpoint

1. Add method to facade interface in `packages/homely_api/lib/src/facades/`
2. Implement in repository (e.g., `cms_repository.dart`)
3. Use `apiClient.get<>()` or `.post<>()`, fold the result, parse JSON
4. Handle errors with appropriate `Failure` subclass
5. Return `Either<Failure, T>`

### Handling API Errors

Always check the response structure:

```dart
final body = response.data;
if (body == null) return left(const UnknownApiFailure(0, 'No response body'));
final success = body['success'] as bool? ?? false;
if (!success) {
  // Parse error message from response
  final message = body['message'] ?? 'Unknown error';
  return left(UnknownApiFailure(response.statusCode ?? 0, message));
}
```

For validation errors (400/422), use `ApiValidationFailure`:

```dart
if (response.statusCode == 422) {
  final errors = ApiValidationFailure.fromJson(body);
  return left(errors);
}
```

Error messages in UI:

- UI surfaces `Failure.message` (e.g., in `HomeScreen` error content). Ensure repository layers set a user-friendly `message`; avoid leaking raw technical errors.

## Key Files to Know

| File                                         | Purpose                                             |
| -------------------------------------------- | --------------------------------------------------- |
| `lib/bootstrap.dart`                         | App initialization, BLoC observer setup             |
| `lib/app/view/app.dart`                      | Root MaterialApp.router, MultiProvider setup, theme |
| `lib/router/router.dart`                     | Route definitions (edit here)                       |
| `lib/router/guards/auth_guard.dart`          | Route protection logic                              |
| `packages/homely_api/lib/homely_api.dart`    | Main API facade export                              |
| `packages/core/lib/src/misc/data_state.dart` | DataState sealed class                              |
| `lib/auth/bloc/auth_bloc.dart`               | Auth state machine & session listener               |
| `lib/main_development.dart`                  | Entry point for dev flavor                          |

## Red Flags & Common Mistakes

❌ **Don't**:

- Directly call `apiClient` in BLoCs—use injected repository
- Use `Provider.of()` without `listen: false` in event handlers
- Forget to run `build_runner` after changing routes
- Mix `Either` folding—always use `.fold((l) => ..., (r) => ...)` consistently
- Create global singletons—pass via constructor/context
- Ignore `@immutable` on states—use `@immutable` or `copyWith()`
- Always try to run app after changes as user maybe already running it
- Create unnecessary summary files unless they add value or specifically requested

✅ **Do**:

- Inject all dependencies via constructor
- Use `sealed class` for events/states to ensure exhaustive handling
- Always handle both `left` and `right` in `Either.fold()`
- Use `DataState<T>` for all async UI operations
- Write descriptive event class names: `HomeLoadedEvent`, not `LoadEvent`
- Check `isSuccess`, `isLoading`, `isFailure` getters on `DataState` in UI
- Always refactor with meaningful names and structure for clarity
- Always refactor widgets into smaller components for better readability and maintainability, use widget classes for this. Don't use functions for widgets unless absolutely necessary.

## Logging & Debugging

- `AppBlocObserver` logs `onChange` and `onError` for all blocs (see `lib/bootstrap.dart`).
- Route guard logs with `AuthGuard:` prefix show authentication decisions and redirects.
- Prefer concise `log()` statements in repositories/blocs to trace network and state transitions.

## UI Consistency

- Use `app_ui` components and tokens for visual consistency.
- Do not use `AppTextStyles` directly. Prefer Flutter's text theme via `context.textTheme` (e.g., `context.textTheme.titleLarge`).
- Keep spacing, colors, and shapes aligned with shared components; avoid ad-hoc styling in feature widgets when an `app_ui` component exists.

## Performance and rebuild hygiene

- Use `BlocBuilder`'s `buildWhen` to prevent unnecessary rebuilds when unrelated parts of the state change.
- Use `BlocListener`'s `listenWhen` to avoid redundant side effects.
- Split large widgets into smaller ones and prefer const constructors where possible.

## Build & Run

```sh
# Get dependencies
flutter pub get

# Format code
dart format .

# Run analysis
dart analyze

# Run all tests with coverage
very_good test --coverage --test-randomize-ordering-seed random

# Build for a specific flavor
flutter run --flavor development --target lib/main_development.dart

# Generate routes & code (after editing router.dart)
flutter pub run build_runner build --delete-conflicting-outputs
```

## Session & Token Management Deep Dive

The `SessionManager` (from `homely_api`) provides:

- **Token storage**: Securely stores JWT in platform-specific storage
- **User data storage**: Stores logged-in user object
- **Atomic operations**: `setSession(token, user)` updates both or neither
- **Reactive streams**: Any auth changes flow through `session$` stream
- **Cancel token management**: Invalidates pending requests on logout

**AuthBloc subscribes to `session$`** and emits `Authenticated`/`Unauthenticated` based on whether session exists. This is the app's single source of truth for auth state.

---

Generated: October 27, 2025  
Framework: Flutter 3.35+ | Dart 3.9+  
State Management: BLoC 9.x with fpdart for functional error handling
