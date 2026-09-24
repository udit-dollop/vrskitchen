# Customized Tiffin Service Platform
## Software Requirements Specification (SRS) & Product Requirements Document (PRD)

**Document Version:** v2.0 — Dedicated Tiffin PRD  
**Core Focus:** Customized Daily Meal Subscriptions & Trial Meals  
**Target Users:** Students, Corporate Employees & Daily Meal Consumers  
**Target Platforms:** Android & iOS Customer Apps, Web Dashboard, Rider App  
**Date:** August 2026

---

## 1. Executive Summary & Business Vision

The Customized Tiffin Service Platform is designed to solve customer meal fatigue caused by rigid, predefined tiffin menus.

### Key Value Propositions

#### 1.1 Daily Customization Engine
Customers can choose their preferred:

- Vegetable dishes (Sabzi)
- Bread type — Tawa Roti / Butter Roti
- Optional add-ons — Curd, Sweet, Salad
- Daily or weekly meal selections through a calendar

#### 1.2 Flexible Subscription Management
The platform supports:

- 7-day plans
- 15-day plans
- 30-day plans
- Single-click **Pause Meal**
- Automatic credit of unused meal balance to the in-app wallet

#### 1.3 Trial Meal Option
Customers can place a one-time sample/trial order before committing to a long-term subscription.

#### 1.4 Kitchen Operational Efficiency
Customer selections are aggregated before kitchen preparation deadlines to:

- Streamline bulk cooking
- Reduce food wastage
- Optimize delivery packaging
- Provide exact preparation requirements

#### 1.5 Operational Cut-off Automation
Example cut-off times:

- Lunch: **10:00 PM previous night**
- Dinner: **2:00 PM**

After the cut-off, meal customization is locked so the kitchen receives the final demand before preparation begins.

#### 1.6 Error-Free Packing
The system automatically generates QR stickers containing exact customer customizations to reduce packing errors during batch preparation.

---

# 2. System Architecture & Platform Ecosystem

The platform consists of three synchronized components.

| Component | Target Users | Core Functionality | Recommended Tech Stack |
|---|---|---|---|
| Customer App & Web | Students, Office Workers, Monthly Subscribers | Meal customization calendar, subscription builder, trial orders, wallet, live map tracking | Flutter / React Native, React.js / Next.js |
| Admin & Kitchen Dashboard | Kitchen Operations Manager, Master Chef | Demand aggregation, menu publishing, sticker generation, inventory tracking | React.js / Node.js, PostgreSQL / MongoDB |
| Delivery Partner App | In-house Delivery Drivers | Batch pickup, QR scanning, route optimization, delivery proof | Flutter / Android Native, Google Maps API |

---

# 3. Complete User Flows & Journey Maps

## 3.1 Customer User Flow

```text
App Launch
    ↓
Onboarding / OTP Login
    ↓
Mode Selection
    ├── Trial Meal
    │    ├── Select Meal Slot
    │    ├── Select Delivery Date & Time Slot
    │    ├── Customize Meal
    │    ├── Input Address
    │    ├── Checkout
    │    ├── Payment
    │    └── Order Confirmed → Real-Time Tracking
    │
    └── Subscription
         ├── Select Plan Duration (7 / 15 / 30 Days)
         ├── Select Included Meals (Lunch / Dinner / Both)
         ├── Customize Meal
         ├── Set Default Preferences
         ├── Set Start Date
         ├── Select Home / Office Address
         ├── Advance Payment
         └── Active Subscription

Daily Customization Loop
    ↓
Push Notification: "Customize tomorrow's meal!"
    ↓
Calendar View
    ↓
Customer Selection
    ↓
Cut-off Time
    ↓
Selection Locked
    ↓
Optional Pause Meal
    ↓
Unused Meal Credit → Wallet
```

### Customer Dietary Preferences

The customer profile supports:

- Veg
- Non-Veg
- Pure Veg
- Jain
- Spice level
- Allergy warnings

### Dual Address Management

Separate addresses can be maintained for:

- **Office** — Lunch slot
- **Home** — Dinner slot

---

## 3.2 Admin & Kitchen Management Flow

```text
Admin Login
    ↓
Live Kitchen Operations Dashboard
    ├── Kitchen Preparation
    │    ├── Cut-off Lock
    │    ├── Demand Summary
    │    ├── Aggregate Raw Material
    │    └── Send Preparation Sheet
    │
    ├── Label & Sticker Print
    │    ├── Auto-generate Labels
    │    ├── Batch Print QR Stickers
    │    └── Attach to Sealed Containers
    │
    └── Inventory & Finance
         ├── Track Consumption & Waste
         └── Revenue & Delivery Analytics
```

---

## 3.3 Delivery Partner Flow

```text
Rider Duty ON
    ↓
Receive Batch Assignment
    ↓
Reach Kitchen
    ↓
QR Verification
    ↓
Scan Tiffin QR Codes
    ↓
Mark Batch Loaded
    ↓
Route Optimization
    ↓
Optimized Navigation
    ↓
Customer Delivery
    ├── Handover
    │    ├── Scan Container QR
    │    ├── Mark Delivered
    │    └── Next Route Point
    │
    └── Drop-off / Unreachable
         ├── Call Customer
         ├── Leave at Gate
         ├── Take Photo
         └── Upload Proof & Mark Delivered
```

---

# 4. Detailed Functional Requirements

## 4.1 Customer Platform Module

### Onboarding & Dietary Profile
OTP authentication with profile settings for:

- Dietary preference
- Spice level
- Allergy warnings

### Trial Meal / One-Time Order
Customers can book a single meal without a long-term commitment.

### Interactive Customization Engine

The customer gets a **7-day calendar interface** with:

- 3–4 daily Sabzi choices
- Tawa Roti
- Butter Roti
- Rice options
- Curd
- Sweet
- Salad

### Cut-off Time Enforcement

The system automatically locks customization after the configured preparation cut-off.

Example:

- Lunch → 10:00 PM previous night
- Dinner → 2:00 PM

### Subscription Pause / Flexi-Wallet

Customers can pause meals while travelling.

Unused meal credits are automatically returned to the in-app wallet.

### Dual Address Management

Separate address mapping is supported for:

- Office / Lunch
- Home / Dinner

---

# 5. Admin & Kitchen Operations Module

## 5.1 Automated Demand Aggregation

After the cut-off, the system calculates exact kitchen preparation quantities.

Example:

```text
Paneer Gravy     → 75
Bhindi Masala    → 45
Tawa Roti        → 360
Butter Roti      → 120
```

## 5.2 Smart QR Labeling System

QR/barcode stickers contain:

- Customer Name
- Delivery Slot
- Customized Dish Items
- Address
- Token Number

## 5.3 Raw Material Inventory Tracker

Tracks:

- Vegetables
- Dry spices
- Consumption
- Reorder requirements

The system alerts kitchen staff when reorders are required.

## 5.4 Zone & Driver Dispatch

Orders are automatically grouped into delivery batches based on:

- Spatial proximity
- Pincode

Batches are then assigned to riders.

---

# 6. Delivery Partner Module

## 6.1 Batch Pickup Verification

The rider app requires QR scanning of containers before departure to reduce wrong-item deliveries.

## 6.2 Route Optimization

The platform integrates with Google Maps API to sequence delivery stops efficiently.

## 6.3 Proof of Delivery

Delivery confirmation requires:

- QR scan confirmation, or
- Photo proof for unattended drop-offs

---

# 7. Technical Architecture

## 7.1 Recommended Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| Mobile Applications | Flutter / React Native | Single codebase for Android & iOS |
| Web Dashboard & Admin | React.js / Next.js | Fast rendering, modular UI, real-time dashboard updates |
| Backend | Node.js (Express) / Python (FastAPI) | High concurrency, cut-off routines, live order updates |
| Database | PostgreSQL + Redis | PostgreSQL for relational data, Redis for fast session caching |
| Location & Mapping | Google Maps Directions & Distance Matrix API | Multi-stop route optimization |
| Payment Gateway | Razorpay / Cashfree / UPI Intent | UPI, wallet top-ups, subscription payments |

---

# 8. Database Schema

## 8.1 Users

**Primary Key:** `user_id`

Attributes:

```text
phone
name
email
dietary_pref
default_address_id
wallet_balance
created_at
```

## 8.2 Subscriptions

**Primary Key:** `subscription_id`  
**Foreign Key:** `user_id`

Attributes:

```text
plan_type
start_date
end_date
meals_included
status
```

Supported plan types:

```text
7 Days
15 Days
30 Days
```

Meals:

```text
Lunch
Dinner
Both
```

## 8.3 Daily_Menus

**Primary Key:** `menu_id`

Attributes:

```text
date
meal_slot
sabzi_option_a
sabzi_option_b
sabzi_option_c
cut_off_time
```

## 8.4 Customized_Orders

**Primary Key:** `order_id`  
**Foreign Key:** `user_id`

Attributes:

```text
delivery_date
slot
selected_sabzi
roti_type
add_ons
qr_code_hash
status
```

## 8.5 Deliveries

**Primary Key:** `delivery_id`  
**Foreign Key:** `order_id`

Attributes:

```text
rider_id
batch_id
route_sequence
delivery_status
proof_photo_url
delivered_at
```

---

# 9. UI/UX Screen Checklist

## 9.1 Customer App

Required screens:

1. Onboarding & Dietary Preference Setup
2. Home Dashboard
   - Trial Order vs Subscription Switcher
3. Weekly Interactive Calendar Menu Customizer
4. Flexi-Wallet & Subscription Pause Modal
5. Real-time Live Order Map Tracking

Additional customer screens implied by the customer flow:

- OTP Login
- Trial Meal
- Subscription Plans
- Meal Customization
- Address Selection
- Checkout
- Payment
- Order Confirmation
- Order History
- Profile
- Dietary Preferences

---

## 9.2 Admin Dashboard

Required screens:

1. Real-time Kitchen Preparation Summary
2. Automated Sticker Generator & Printer Preview
3. Weekly Menu & Cut-off Configurator
4. User Subscription & Flexi-Wallet Manager

Additional operational modules:

- Inventory
- Delivery Dispatch
- Revenue Analytics
- Waste Tracking
- Demand Aggregation

---

## 9.3 Rider App

Required screens:

1. Daily Assigned Batch Checklist
2. QR Code Verification Camera Scanner
3. Optimized Navigation & Route Guidance Screen

Additional flow screens:

- Batch Loaded
- Customer Delivery
- Unreachable Customer
- Photo Proof
- Delivery Completed
- Delivery History

---

# 10. Flutter Application Structure

Recommended project structure:

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── network/
│   ├── routes/
│   └── utils/
│
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
│
├── features/
│   ├── auth/
│   ├── home/
│   ├── subscription/
│   ├── customization/
│   ├── calendar/
│   ├── wallet/
│   ├── orders/
│   ├── tracking/
│   └── profile/
│
├── widgets/
│   ├── meal_card.dart
│   ├── custom_button.dart
│   ├── app_header.dart
│   └── loading_view.dart
│
└── main.dart
```

### Suggested Flutter Architecture

```text
UI
 ↓
ViewModel / Controller
 ↓
Repository
 ↓
API Service
 ↓
Backend
 ↓
PostgreSQL / Redis
```

---

# 11. Main Customer Screens

## Splash Screen

Brand introduction and application loading.

## Onboarding

Explain:

- Fresh homemade meals
- Daily customization
- Subscription flexibility
- Trial meal option

## OTP Login

Authentication using mobile number and OTP.

## Home Dashboard

Should prominently show:

- Active subscription
- Trial meal option
- Today's Lunch
- Today's Dinner
- Customize CTA
- Wallet
- Order tracking

## Subscription Plans

Plans:

- 7 Days
- 15 Days
- 30 Days

Each plan should show included meals and customization benefits.

## Meal Customization

Customer selects:

```text
Sabzi
 ↓
Roti Type
 ↓
Rice
 ↓
Add-ons
 ↓
Save Selection
```

## Meal Calendar

A weekly calendar allows customers to customize upcoming meals before the cut-off.

## Pause Meal

Customer selects:

```text
From Date
To Date
```

Unused meal balance is credited to the wallet.

## Wallet

Shows:

```text
Available Balance
Credits
Debits
Refunds
Top-ups
Meal Charges
```

## Order Tracking

Shows:

```text
Order Picked Up
      ↓
On the Way
      ↓
Arriving Soon
      ↓
Delivered
```

with live map tracking.

---

# 12. Design System

## Brand Direction

The UI should communicate:

- Fresh food
- Trust
- Health
- Simplicity
- Daily convenience

### Suggested Color Tokens

```text
Primary Green: #087A3D
Dark Green:    #075D30
Soft Green:    #E8F6EE
Background:    #F7F9F7
Text:          #18221C
Muted Text:    #68746C
Accent:        #F39A38
```

### Typography

```text
H1: 28px / 34px — Bold
H2: 23px / 29px — Bold
H3: 19px / 24px — Bold
Body: 15px / 22px
Button: 14px / 18px — Bold
```

### Component Guidelines

```text
Screen horizontal padding: 20px
Card radius: 18–22px
Input radius: 14px
Button height: 48px
Small spacing: 8px
Medium spacing: 12–16px
Large spacing: 20–24px
```

---

# 13. Business Rules

## Cut-off Rule

Once the cut-off time is reached, the customer's meal customization becomes locked.

## Pause Rule

When a subscription is paused:

```text
Unused Meal
    ↓
Credit Calculation
    ↓
Flexi Wallet
```

## QR Rule

Each customized container gets a QR/barcode label containing the information required for accurate packing and delivery.

## Delivery Rule

Rider must verify the assigned containers before leaving the kitchen.

## Address Rule

Lunch and dinner can use different saved addresses.

---

# 14. Production Integration Requirements

The SRS defines the following integrations:

### Authentication

- OTP authentication

### Payment

- Razorpay
- Cashfree
- UPI Intent

### Maps

- Google Maps Directions API
- Google Maps Distance Matrix API

### Database

- PostgreSQL
- Redis

### Backend

- Node.js / Express
- or Python / FastAPI

### Mobile

- Flutter / React Native

### Web

- React.js / Next.js

---

# 15. Implementation Phases

## Phase 1 — Flutter UI

- Theme
- Navigation
- Onboarding
- OTP UI
- Home
- Subscription
- Trial Meal
- Calendar
- Customization
- Wallet
- Orders
- Tracking
- Profile

## Phase 2 — Backend

- Authentication
- User APIs
- Menu APIs
- Subscription APIs
- Customization APIs
- Order APIs
- Wallet APIs
- Delivery APIs

## Phase 3 — Payments & Notifications

- Payment gateway
- Wallet top-up
- Subscription payment
- Push notifications
- Daily customization reminder

## Phase 4 — Kitchen/Admin

- Kitchen dashboard
- Demand aggregation
- Menu management
- QR label generation
- Inventory
- Dispatch management

## Phase 5 — Rider

- Batch assignment
- QR scanner
- Route optimization
- Delivery status
- Proof of delivery

## Phase 6 — Production

- Error handling
- Loading states
- Offline handling
- Analytics
- Logging
- Security
- Performance optimization
- App Store / Play Store deployment

---

# 16. Important Production Considerations

The UI alone is not enough for this product. The most important business logic should be enforced on the backend, especially:

- Cut-off time locking
- Subscription validity
- Pause/refund calculation
- Wallet balance
- Payment verification
- QR validation
- Delivery status
- Rider assignment
- Menu availability

The client app should never be trusted as the source of truth for these operations.

---

# 17. Final Product Scope

The complete ecosystem contains:

```text
                    CUSTOMIZED TIFFIN PLATFORM
                              │
             ┌────────────────┼────────────────┐
             │                │                │
       CUSTOMER APP      ADMIN/KITCHEN     RIDER APP
             │                │                │
       ┌─────┼─────┐      ┌───┼────┐       ┌───┼────┐
       │     │     │      │   │    │       │   │    │
   Trial  Subscription  Kitchen QR Inventory  QR Route Delivery
       │     │             │   │      │       │   │
       └─────┼─────────────┴───┴──────┴───────┴───┘
             │
        Customization
             │
       Order Management
             │
        Wallet / Pause
             │
        Delivery Tracking
```

---

## Source

This document is structured from the provided **Software Requirements Specification (SRS) & PRD — Customized Tiffin Service Platform, Version v2.0**, dated August 2026.
