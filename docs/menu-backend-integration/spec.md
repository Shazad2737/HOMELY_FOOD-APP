# Menu & Subscription API Documentation for Frontend

## Overview
The Menu system allows customers to view available meals organized by categories and plans, and manage their meal subscriptions. The API provides endpoints to retrieve menu data and subscription information.

---

## 1. Menu API Endpoint

### GET `/api/menu/:categoryId`
**Purpose:** Fetch the complete menu for a specific category along with available plans and meal types.

**Authentication:** Required (Bearer token in Authorization header)

**Path Parameters:**
- `categoryId` (string, required): The ID of the category (e.g., "Authentic", "Diet")

**Query Parameters:**
- `planId` (string, optional): Filter menu items by a specific plan (Basic, Premium, Ultimate)
- `search` (string, optional): Search menu items by name, description, or item code

**Response Structure:**
```json
{
  "statusCode": 200,
  "message": "Menu data fetched successfully",
  "data": {
    "availablePlans": [
      {
        "id": "plan_id",
        "name": "Basic",
        "type": "BASIC|PREMIUM|ULTIMATE",
        "imageUrl": "url_to_plan_image"
      }
    ],
    "mealTypes": [
      {
        "id": "meal_type_id",
        "type": "BREAKFAST|LUNCH|DINNER",
        "name": "Breakfast",
        "description": "Morning meal",
        "startTime": "07:00 AM",
        "endTime": "09:00 AM",
        "sortOrder": 1
      }
    ],
    "menu": {
      "breakfast": [
        {
          "id": "item_id",
          "name": "Dosa",
          "code": "DOSA_001",
          "description": "South Indian crepe",
          "imageUrl": "url_to_item_image",
          "cuisine": "SOUTH_INDIAN|NORTH_INDIAN|KERALA|CHINESE|CONTINENTAL|ITALIAN|MEXICAN|OTHER",
          "style": "SOUTH_INDIAN|NORTH_INDIAN|KERALA|PUNJABI|BENGALI|GUJARATI|RAJASTHANI|FUSION|OTHER",
          "price": 150.00,
          "isVegetarian": true,
          "isVegan": false,
          "deliveryMode": "SEPARATE|WITH_OTHER",
          "deliverWith": {
            "id": "meal_type_id",
            "name": "Lunch",
            "type": "LUNCH"
          },
          "availableDays": [
            { "dayOfWeek": "MONDAY" },
            { "dayOfWeek": "TUESDAY" },
            { "dayOfWeek": "WEDNESDAY" }
          ]
        }
      ],
      "lunch": [...],
      "dinner": [...]
    }
  }
}
```

**Key Features:**
- **Plan-based Filtering:** When a `planId` is provided, only food items available for that plan are returned
- **Meal Type Organization:** Menu items are grouped by meal type (breakfast, lunch, dinner)
- **Availability Tracking:** Each item shows which days of the week it's available
- **Dietary Information:** Vegetarian and vegan flags for each item
- **Delivery Mode:** Indicates whether an item is delivered separately or bundled with another meal
- **Search Capability:** Filter items by name, description, or internal code

---

## 2. Subscription API Endpoint

### GET `/api/subscription`
**Purpose:** Fetch the customer's subscription status and meal preferences.

**Authentication:** Required (Bearer token in Authorization header)

**Query Parameters:** None

**Response Structure:**
```json
{
  "statusCode": 200,
  "message": "Subscription fetched successfully",
  "data": {
    "mealTypes": [
      {
        "id": "meal_type_id",
        "name": "Breakfast",
        "systemActive": true,
        "customerActive": true,
        "startDate": "2025-01-01",
        "endDate": "2025-03-31"
      },
      {
        "id": "meal_type_id",
        "name": "Lunch",
        "systemActive": true,
        "customerActive": false,
        "startDate": null,
        "endDate": null
      }
    ],
    "banner": {
      "id": "banner_id",
      "images": [
        {
          "id": "image_id",
          "imageUrl": "url_to_banner_image",
          "redirectUrl": "url_to_redirect",
          "caption": "Special offer banner"
        }
      ]
    }
  }
}
```

**Key Features:**
- **Meal Type Status:** Shows which meal types the customer has subscribed to
- **Subscription Period:** Displays start and end dates for active subscriptions
- **System vs Customer Active:** `systemActive` indicates if the meal type is available system-wide, `customerActive` shows if the customer has an active subscription for it
- **Promotional Banners:** Returns subscription page banners with promotional content

---

## 3. Data Models & Relationships

### Plan Model
- **Types:** BASIC, PREMIUM, ULTIMATE
- **ULTIMATE plans:** Have `isUnlimited: true` for unlimited meal quantities
- **Plan Uniqueness:** One plan type per category

### Meal Type Model
- **Types:** BREAKFAST, LUNCH, DINNER
- **Time Windows:** Each has `startTime` and `endTime` for ordering windows
- **Global:** Meal types are shared across all categories

### Food Item Model
- **Cuisines:** KERALA, NORTH_INDIAN, SOUTH_INDIAN, CHINESE, CONTINENTAL, ITALIAN, MEXICAN, OTHER
- **Dietary Info:** Includes vegetarian and vegan flags
- **Delivery Modes:**
  - `SEPARATE`: Delivered at regular time based on meal type
  - `WITH_OTHER`: Bundled with another meal type (e.g., breakfast delivered with lunch)
- **Availability:** Available for specific days of the week and specific plans

### Subscription Model
- **Status:** ACTIVE, EXPIRED, CANCELLED
- **Scope:** Customer subscribes to a specific category within a brand
- **Meal Selection:** Subscriptions can include multiple meal types via SubscriptionMealType

### Category Model
- Represents meal categories (e.g., "Authentic", "Diet", "Premium Meals")
- Multiple plans can exist within a category
- Food items belong to specific categories

---

## 4. API Features & Capabilities

### For Menu Screen:
show category list, reuse home screen category list if needed. 
1. **Display Plans:** Show available plans (Basic, Premium, Ultimate) as cards/tabs
2. **Organize by Meal Time:** Group menu items by breakfast, lunch, dinner. we need the current design to be folowed. dont chane the current style 
3. **Filter by Plan:** When user selects a plan, display only items available for that plan. item cards must follow current design
4. **Search Functionality:** Real-time search across item names, descriptions, and codes
5. **Dietary Indicators:** Display vegetarian/vegan badges
6. **Pricing Display:** Show item prices (when applicable)
7. **Availability Calendar:** Show which days each item is available
8. **Combo Information:** Display when items are delivered together (deliveryMode: WITH_OTHER)

### For Subscription Screen: not to be implemented now. 
1. **View Subscribed Meals:** Show which meal types the customer is subscribed to
2. **Subscription Dates:** Display subscription period (start and end dates)
3. **Status Indication:** Show if a subscription is active
4. **Optional Meals:** Show available meal types that the customer hasn't subscribed to
5. **Promotional Banners:** Display subscription page banners for promotions

---

## 5. Authentication & Authorization
- All menu and subscription endpoints require authentication
- User identity is extracted from the JWT token (Bearer token)
- Brand context is determined from the authenticated user's `brandId`
- Location filtering may apply based on customer's selected location

---

## 6. Error Handling
Standard error responses include:
- `401 Unauthorized`: Missing or invalid authentication token
- `400 Bad Request`: Missing required parameters or invalid input
- `404 Not Found`: Category, plan, or meal type not found
- `500 Internal Server Error`: Server-side error

---

## 7. Caching Strategy
- Menu data may be cached in Redis for performance optimization
- Cache invalidation happens when menu items or plans are updated via admin panel

---