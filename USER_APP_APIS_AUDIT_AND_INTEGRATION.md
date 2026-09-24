# 📱 VR's KITCHEN - User Mobile App (Flutter) API Audit & Integration Report

> **Last Updated**: 23 September 2026  
> **Backend Environment**: `http://192.168.1.26:7070/api/v1` (Live Spring Boot Backend)  
> **Source of Truth**: Live OpenAPI 3.0 Documentation (`/v3/api-docs`) & Controller Code  
> **Target Mobile Project**: [`c:\Users\uditg\vrs_kitchen`](file:///c:/Users/uditg/vrs_kitchen) (Flutter / Dart)

---

## 📌 Executive Summary

Is audit me Admin portal (`vrs_kitchen_admin`) aur Spring Boot backend (`tiffin-service-backend`) ko scan kiya gaya ki **User / Customer App side ke liye kon-kon si APIs backend me already bani hui hain**, aur **Flutter User App (`vrs_kitchen`) me unka integration status kya hai**.

Pehle Flutter app ke sabhi screens pure **mock data** par chal rahe the. Ab **ek robust HTTP API Client aur typed Service Layer bana kar User App me sabhi live backend APIs ko integrate kar diya gaya hai**, sath hi graceful offline fallback rakha gaya hai taaki backend offline hone par bhi app kabhi crash na ho.

---

## 🟢 1. Live Backend Me Bani Hui APIs (Jo Flutter User App Me Integrate Ho Gayi Hain)

Backend server (`http://192.168.1.26:7070`) par User/Customer ke liye ye sabhi APIs live hain aur Flutter app me ab fully wired hain:

### 1.1 🔐 Authentication & Session (`/api/v1/auth`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/v1/auth/send-otp` | Body: `{ "phone": "9826012345" }`<br>Returns: `verificationToken`, `expiresInSeconds`, `devOtp` | [`LoginScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/login_screen.dart) |
| **POST** | `/api/v1/auth/verify-otp` | Body: `{ "phone": "...", "otp": "644219", "verificationToken": "..." }`<br>Returns: `accessToken`, `refreshToken`, user profile | [`OtpScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/otp_screen.dart) |
| **POST** | `/api/v1/auth/login` | Body: `{ "phone": "9826012345", "password": "..." }`<br>Returns: JWT Bearer Token | [`LoginScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/login_screen.dart) |
| **POST** | `/api/v1/auth/register?phone={mobile}` | Body: `{ "name", "password", "email", "dietaryPreference", "spiceLevel", "allergies" }` | [`DietarySetupScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/dietary_setup_screen.dart) |
| **POST** | `/api/v1/auth/logout` | Revokes server session and clears local storage | App Settings / Logout |

---

### 1.2 👤 User Profile & Delivery Addresses (`/api/v1/user`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/user/profile` | Fetches name, phone, email, dietary preferences, spice level, active addresses, and wallet balance | [`ProfileScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/profile/profile_screen.dart) & Header |
| **PUT** | `/api/v1/user/profile` | Body: `{ "name", "email", "dietaryPreference", "spiceLevel" }` | [`ProfileScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/profile/profile_screen.dart) |
| **GET** | `/api/v1/user/addresses` | Returns list of saved customer addresses (Home, Office, Flat) | [`SavedAddressesScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/profile/saved_addresses_screen.dart) |
| **POST** | `/api/v1/user/addresses` | Body: `{ "addressType": "HOME", "addressLine": "...", "landmark": "...", "city": "Indore", "pincode": "452001", "isDefault": true }` | [`SavedAddressesScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/profile/saved_addresses_screen.dart) (Add Address Modal) |
| **DELETE** | `/api/v1/user/addresses/{id}` | Deletes saved delivery address from database | [`SavedAddressesScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/profile/saved_addresses_screen.dart) |
| **PATCH** | `/api/v1/user/addresses/{id}/default` | Sets default delivery address | Saved Addresses Card |

---

### 1.3 🍱 Menu & 7-Day Interactive Customization Calendar (`/api/v1/menu`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/menu/daily` | Query: `menuDate`, `slot` (`LUNCH` / `DINNER`), `kitchenId`<br>Returns Chef's specials, Sabzi choices, Dal, Rotis, Rice | [`TodayMealCard`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/home/widgets/today_meal_card.dart) |
| **GET** | `/api/v1/menu/weekly` | Query: `startDate`, `endDate`, `slot`, `kitchenId`<br>Returns 7-day schedule with portions and choices | [`WeeklyMenuScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/menu/weekly_menu_screen.dart) |
| **GET** | `/api/v1/menu/next-7-days` | Query: `kitchenId`, `slot`<br>Upcoming 7 days menu preview | [`CalendarScheduleScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/customization/calendar_schedule_screen.dart) |

---

### 1.4 📦 Subscriptions & 1-Click Pause Meal (`/api/v1/subscription`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/subscription/plans` | Query: `kitchenId`, `mealSlot`, `isActive=true`<br>Returns Standard & Premium subscription packages | [`PlanSelectorScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/subscription/plan_selector_screen.dart) |
| **GET** | `/api/v1/subscription/my-subscriptions` | Returns customer's active subscription, remaining meals count, validity start & end dates | [`SubscriptionHeroCard`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/home/widgets/subscription_hero_card.dart) |
| **POST** | `/api/v1/subscription/subscribe` | Body: `{ "planId", "startDate", "mealSlot", "deliveryAddressId", "paymentMethod": "ONLINE" }` | [`SubscriptionSuccessScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/subscription/subscription_success_screen.dart) |
| **POST** | `/api/v1/subscription/pause-meal` | Body: `{ "startDate": "YYYY-MM-DD", "endDate": "YYYY-MM-DD", "mealSlots": ["LUNCH"], "reason": "Going out of town" }`<br>**Effect**: Meal pause hoti hai aur **₹80 customer Flexi-Wallet me instant auto-refund** ho jate hain! | [`PauseMealModal`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/pause_meal/pause_meal_modal.dart) |

---

### 1.5 🍛 Meal Customization & Orders Tracking (`/api/v1/orders`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/v1/orders/customize` | Body: `{ "deliveryDate", "slot", "selectedSabziNames": ["Paneer Butter Masala"], "selectedRotiName": "5 Butter Roti", "rotiCount": 5, "selectedRiceName": "Jeera Rice", "addOnNames": ["Gulab Jamun"] }`<br>**Effect**: Daily meal customize hoti hai aur backend par order schedule ho jata hai. | [`MealCustomizerScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/customization/meal_customizer_screen.dart) |
| **GET** | `/api/v1/orders/my-orders` | Returns user's order history, status (`PREPARING`, `PACKED`, `OUT_FOR_DELIVERY`, `DELIVERED`, `CANCELLED`) | [`OrdersListScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/orders/orders_list_screen.dart) |
| **GET** | `/api/v1/orders/{orderId}/track` | Live tracking status and timeline timestamps | [`OrderTrackingScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/orders/order_tracking_screen.dart) |
| **POST** | `/api/v1/orders/{orderId}/cancel` | Body: `{ "reason": "..." }`<br>Customer self-service order cancellation | Order Details Sheet |

---

### 1.6 💰 Flexi-Wallet & Ledger (`/api/v1/wallet`)
| HTTP Method | Endpoint | Description & Payload | UI Screen Connection |
| :--- | :--- | :--- | :--- |
| **GET** | `/api/v1/wallet/summary` | Returns `currentBalance` (e.g. ₹240) aur transaction ledger (refunds, recharges, debits) | [`WalletScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/wallet/wallet_screen.dart) |
| **POST** | `/api/v1/wallet/recharge` | Body: `{ "amount": 500, "paymentReference": "APP-TOPUP-..." }`<br>Instant balance credit | [`WalletScreen`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/wallet/wallet_screen.dart) ("Top-up Wallet" Sheet) |

---

## 🏗️ 2. User App Architecture & Files Added in `vrs_kitchen`

1. **[`lib/core/network/api_constants.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/core/network/api_constants.dart)**:
   - Centralized backend URLs & endpoints (`http://192.168.1.26:7070/api/v1`).
2. **[`lib/core/network/api_client.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/core/network/api_client.dart)**:
   - Singleton HTTP client with `Authorization: Bearer <token>` injection, 7s timeout, and `SharedPreferences` persistent storage.
3. **[`lib/core/services/api_service.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/core/services/api_service.dart)**:
   - Typed methods for Auth, User Profile, Saved Addresses, Menus, Subscriptions, Orders, and Wallet.
4. **[`lib/state/app_state_provider.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/state/app_state_provider.dart)**:
   - Connected `initBackendSession()`, `syncUserProfile()`, `syncWallet()`, `syncSubscriptions()`, `syncOrders()`.
   - Wired live `pauseMeal()`, `rechargeWallet()`, `addAddress()`, `placeOrCustomizeOrder()`.
   - Guaranteed resilient offline fallback to `MockData` if backend is unreachable.
5. **[`lib/features/authentication/login_screen.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/login_screen.dart)**:
   - Connected to real backend `sendOtp` API (`9826012345`).
6. **[`lib/features/authentication/otp_screen.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/features/authentication/otp_screen.dart)**:
   - Connected to backend `verifyOtp` API with auto-prefill of development OTP (`devOtp`) for instant 1-tap testing.
7. **[`lib/features/customer/home/home_dashboard_screen.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/features/customer/home/home_dashboard_screen.dart)**:
   - Added pull-to-refresh `RefreshIndicator` and "Live Kitchen Connected" status badge.
8. **[`lib/main.dart`](file:///c:/Users/uditg/vrs_kitchen/lib/main.dart)**:
   - Automatically kicks off backend initialization on launch.

---

## 🚦 3. Test Credentials for Live App Testing

* **Live Backend URL**: `http://192.168.1.26:7070/api/v1`
* **Test Registered Customer Mobile**: `9826012345` (Customer: Rahul Sharma, Active 30-Day Plan)
* **Backend Dev OTP**: Returned dynamically in API response (e.g. `644219` or `123456`)
* **Admin Login**: Phone: `8520234679`, Password: `arun@123`

---

## 📋 4. Future Optional Enhancements for User App (Backend Side)

Backend par ye secondary features future me banaye ja sakte hain:
1. **Live GPS Runner WebSocket**: Delivery runner ki real-time map location stream karne ke liye WebSocket endpoint (`/ws/delivery-tracking`).
2. **Customer Push Notifications**: FCM token register karne ka endpoint (`POST /user/fcm-token`) for delivery dispatched notifications.
3. **Razorpay Webhook Auto-Verification**: App-side payment signature verification callback (`POST /subscription/razorpay/verify`).
