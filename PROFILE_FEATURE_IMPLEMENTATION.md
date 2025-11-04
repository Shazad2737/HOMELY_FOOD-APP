# Profile Feature Implementation

## Summary

This document describes the profile-related features that have been implemented, including user profile display, delivery address management, and all necessary infrastructure.

## Features Implemented

### 1. User Profile Display
- **ProfileScreen**: Displays real user data fetched from the backend
- Shows profile picture (with fallback icon), name, mobile, and email
- Includes pull-to-refresh functionality
- Shows loading, error, and success states using DataState pattern

### 2. Delivery Address Management
- **AddressesScreen**: Lists all user delivery addresses
- Features:
  - View all saved addresses
  - Add new addresses
  - Edit existing addresses
  - Delete addresses (with confirmation dialog)
  - Set default address
  - Empty state when no addresses exist
  - Pull-to-refresh functionality
  - Operation status indicators (loading, success, error)

- **AddressFormScreen**: Form for creating/editing addresses
  - Dynamic location and area dropdowns from CMS
  - Form validation
  - Support for both create and edit modes
  - Fields: type, location, area, name, building, room, zip, mobile
  - Set as default checkbox
  - Loading states for dependent fields (areas depend on location)

### 3. Architecture & Code Organization

#### Models Created
Location: `packages/instamess_api/lib/src/user/models/`

- `customer_profile.dart` - Complete customer profile with stats
- `profile_stats.dart` - Profile statistics (orders, subscriptions, addresses)
- `customer_address.dart` - Customer address with location hierarchy
  - `AddressCountry`, `AddressLocation`, `AddressArea` sub-models
- `addresses_response.dart` - API response for address list
- `create_address_request.dart` - Request for creating new address
- `update_address_request.dart` - Request for updating address (partial)
- `update_profile_request.dart` - Request for profile updates (future use)

#### Repository Methods Added
Location: `packages/instamess_api/lib/src/user/`

Interface: `user_repository_interface.dart`
Implementation: `user_repository.dart`

**Profile Operations:**
- `getProfile()` - Fetch customer profile with stats
- `updateProfilePicture(filePath)` - Upload new profile picture

**Address Operations:**
- `getAddresses()` - Fetch all customer addresses
- `createAddress(request)` - Create new address
- `updateAddress(addressId, request)` - Update existing address
- `deleteAddress(addressId)` - Soft delete address
- `setDefaultAddress(addressId)` - Mark address as default

#### BLoCs Created

**ProfileBloc**
Location: `lib/profile/bloc/`
- Events: `ProfileLoadedEvent`, `ProfileRefreshedEvent`, `ProfilePictureUpdatedEvent`
- State: `ProfileState` with `DataState<CustomerProfile>`
- Manages profile data fetching and refresh

**AddressesBloc**
Location: `lib/profile/addresses/bloc/`
- Events: Load, Refresh, Create, Update, Delete, SetDefault
- State: `AddressesState` with multiple operation states
- Handles all CRUD operations for addresses
- Automatically reloads list after successful operations

**AddressFormBloc**
Location: `lib/profile/addresses/view/bloc/`
- Manages address form state and validation
- Handles dependent field loading (locations → areas)
- Supports both create and edit modes
- Pre-fills form when editing existing address

#### Screens Created

1. **ProfileScreen** - `lib/profile/view/profile_screen.dart`
   - Updated to show real data using ProfileBloc
   - Navigation to Orders and Addresses
   - Logout functionality

2. **AddressesScreen** - `lib/profile/addresses/view/addresses_screen.dart`
   - List view with address cards
   - FAB for adding new address
   - Popup menu for edit/delete/set default actions

3. **AddressFormScreen** - `lib/profile/addresses/view/address_form_screen.dart`
   - Comprehensive form with validation
   - Reusable for both create and edit
   - Integrates with CMS repository for locations/areas

#### Routes Added
Location: `lib/router/router.dart`

- `/addresses` - AddressesRoute
- `/addresses/form` - AddressFormRoute (supports optional address parameter for editing)

## Backend API Integration

All endpoints are correctly integrated per the API documentation:

### Profile Endpoints
- GET `/api/customer/profile` - ✅ Implemented
- PATCH `/api/customer/profile-picture` - ✅ Implemented

### Address Endpoints
- GET `/api/customer/addresses` - ✅ Implemented
- POST `/api/customer/addresses` - ✅ Implemented
- PATCH `/api/customer/addresses/:addressId` - ✅ Implemented
- DELETE `/api/customer/addresses/:addressId` - ✅ Implemented
- PATCH `/api/customer/addresses/:addressId/set-default` - ✅ Implemented

## Design Patterns Used

1. **BLoC Pattern** - Consistent with existing codebase
2. **DataState Pattern** - For unified loading/success/failure states
3. **Functional Error Handling** - Using `Either<Failure, T>` from fpdart
4. **Repository Pattern** - Separation of data layer from presentation
5. **Feature-First Organization** - Each feature in its own directory

## Not Implemented (Intentionally)

1. **Change Password** - No dedicated authenticated endpoint in API spec
   - Current flow requires OTP-based reset which is for password recovery
   - Would need backend enhancement for authenticated password change

2. **Profile Edit Screen** - No profile update endpoint in API (except picture)
   - Backend returns profile data but doesn't provide update endpoint
   - Can be added when backend supports it

## Next Steps (Required by Developer)

### 1. Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
This generates the router code for the new routes.

### 2. Fix Any Compilation Errors
After code generation, check for any errors:
```bash
flutter analyze
```

### 3. Test the Features
- Profile screen loads and displays user data
- Pull to refresh works on profile screen
- Navigation to addresses screen works
- Add new address flow (all fields, validation)
- Edit existing address
- Delete address (with confirmation)
- Set default address
- Empty state shows correctly
- Error handling and retry buttons work
- Loading states display correctly

### 4. API Base URL Configuration
Ensure the API base URL is configured correctly in your environment:
- Development: Check `main_development.dart`
- The base URL should point to your backend server

## Files Modified

### New Files Created:
- Models (7 files in `packages/instamess_api/lib/src/user/models/`)
- ProfileBloc (3 files in `lib/profile/bloc/`)
- AddressesBloc (3 files in `lib/profile/addresses/bloc/`)
- AddressFormBloc (3 files in `lib/profile/addresses/view/bloc/`)
- Screens (2 new: AddressesScreen, AddressFormScreen)

### Modified Files:
- `packages/instamess_api/lib/src/user/user_repository_interface.dart`
- `packages/instamess_api/lib/src/user/user_repository.dart`
- `packages/instamess_api/lib/src/user/models/models.dart`
- `lib/profile/view/profile_screen.dart`
- `lib/router/router.dart`

## Known Limitations

1. Profile picture upload uses file path - ensure file picker is implemented in UI
2. Address coordinates (lat/lng) are optional - no map integration yet
3. Country selection is not implemented (countryId is optional in forms)
4. No offline support or caching (can be added if needed)

## Architecture Validation

✅ Follows existing BLoC patterns
✅ Uses DataState for async operations
✅ Functional error handling with Either
✅ Proper separation of concerns
✅ Consistent with order_form feature structure
✅ Repository pattern for data layer
✅ Feature-first directory structure
