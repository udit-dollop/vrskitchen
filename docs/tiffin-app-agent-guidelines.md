# Customized Tiffin Service — Developer & Agent Guidelines

This document is the permanent technical, architectural, UI/UX, development, and implementation guideline for the **Customized Tiffin Service — Customer Mobile Application**.

All developers and AI agents working on this project MUST read and follow this document before making any changes.

The purpose of this document is to ensure that the application remains:

- Consistent
- Maintainable
- Scalable
- Reusable
- Responsive
- Testable
- Architecturally consistent
- Visually consistent
- Free from duplicate implementations

---

# 1. PROJECT OVERVIEW

## 1.1 Application

**Application Name:**
Customized Tiffin Service — Customer App

**Package Name:**
`com.dollop.tiffinservice`
*(assumption — update if the actual package differs)*

**Platform:**
Android

**Language:**
Kotlin

**Target Users:**
Students, Corporate Employees, Daily Meal Consumers

## 1.2 Application Purpose

The Customer App lets subscribers customize their daily tiffin (sabzi, roti, add-ons), manage flexible subscription plans, place trial/one-time orders, track deliveries live, and manage an in-app wallet.

The application may contain modules such as:

- Authentication (OTP-based)
- Dietary Preference & Profile Setup
- Home Dashboard (Trial vs Subscription switcher)
- Trial / One-Time Order Flow
- Subscription Plan Builder
- Weekly Interactive Calendar — Meal Customizer
- Flexi-Wallet & Subscription Pause
- Live Order Tracking
- Address Management (Office / Home)
- Order History
- Notifications
- Other consumer-facing features

Feature scope may evolve over time.

New features must always follow the architecture and rules defined in this document.

---

# 2. PROJECT SOURCE OF TRUTH

The Customer App is an independent Android application.

This project has its own:

- Architecture
- MVVM implementation
- Hilt Dependency Injection
- Repository layer
- Networking layer
- Validation system
- Navigation system
- Session management
- Reusable UI components
- Theme and design system
- Coding standards
- Utility classes
- Database layer where required (Room, for offline menu/wallet caching)

All future development must be based on the existing Customer App codebase and the rules defined in this document.

The project must not depend on another application's (e.g. Admin Dashboard, Rider App) source code, business logic, package structure, or implementation.

---

## 2.1 Tiffin App Design System

The design language should feel warm and appetizing — food-tech, but home-cooked-meal oriented, not generic corporate SaaS.

Use consistently across the app for:

- Theme
- Colors
- Fonts
- Typography
- Dimensions
- SDP
- SSP
- Screen backgrounds
- Cards
- Buttons
- Dialogs
- Bottom sheets
- Date / Time pickers
- Gradients
- Drawables
- General UI appearance

**Default screen background:**
```xml
@color/white
```

**Primary/brand colors (reference — adjust to final brand kit):**
```xml
@color/terracotta   <!-- #C1502E -->
@color/mustard       <!-- #E1A93E -->
@color/deep_green    <!-- #2F5233 -->
@color/cream_bg      <!-- #FBF6EE -->
```

Brand accent colors must not be used as the default full-screen background.

---

## 2.2 Tiffin App Technical Architecture

The app owns and maintains its complete technical architecture:

- MVVM
- Hilt Dependency Injection
- Repository Pattern
- Retrofit + OkHttp + Gson
- ApiResult / ApiCallback
- Validation
- SavedData (session, wallet cache)
- BaseActivity / BaseFragment
- Room (menu cache, wallet transactions, offline order drafts)
- Firebase Cloud Messaging (cutoff reminders — "Customize tomorrow's meal!")
- Google Maps SDK (live delivery tracking)
- Razorpay/Cashfree SDK (payments)
- Utils
- Centralized navigation
- Reusable Custom Components

All new functionality must be implemented inside the Customer App.

Before creating a new class, utility, component, or helper, search the existing project first.

If an existing implementation can be reused, reuse it.

If it can be extended safely, extend it.

Only create a new implementation when the existing implementation cannot satisfy the requirement.

---

## 2.3 Independent Project Rule

The Customer App must remain completely independent from the Admin/Kitchen Dashboard (web) and the Rider App (separate Android app).

Do NOT:

- Reference another application's package.
- Copy another application's business logic.
- Copy unrelated feature modules (e.g. rider batch/route logic, kitchen prep-sheet logic).
- Copy unrelated API endpoints.
- Copy unrelated models.
- Copy unrelated repositories.
- Copy unrelated resources.
- Create dependencies between applications.
- Assume another project's source code will remain available.
- Introduce another application's naming conventions unnecessarily.

The Customer App must be capable of being maintained, built, tested, and released independently.

---

# 3. TECHNICAL ARCHITECTURE

The Customer App follows a clean MVVM-based architecture:

```text
Activity / Fragment
        ↓
    ViewModel
        ↓
    Repository
        ↓
ApiService / Room Database
```

## 3.1 Architecture Ownership

All architecture belongs to the Customer App project.

The implementation must use the existing project classes and utilities.

Before creating a new implementation, search the project first.

If an existing utility or component already solves the problem, reuse it.

Do not create duplicate implementations.

---

# 4. CORE FEATURE MODULES (Reference)

Keep implementations grouped consistently by module — do not scatter related logic across unrelated packages.

| Module | Key Screens |
|---|---|
| Auth | Splash, OTP Login, Dietary Preference Setup |
| Dashboard | Home (Trial vs Subscription switcher), Cutoff countdown banner |
| Trial Order | Meal slot select, date/time slot, menu select, checkout, payment |
| Subscription | Plan duration select (7/15/30), meals included, start date, dual address, checkout |
| Calendar Customizer | 7-day calendar strip, sabzi/roti/rice/add-on selector, lock state, cutoff timer |
| Wallet | Balance card, transaction history, Pause Meal bottom sheet |
| Tracking | Live map, rider ETA, status timeline, rider contact |
| Profile | Preferences edit, saved addresses, order history, support |

Cutoff-lock logic (e.g. 10:00 PM previous night for Lunch, 2:00 PM for Dinner) must be centralized in one utility/ViewModel logic path — do not duplicate cutoff-time calculation across screens.

---

# 29. NAVIGATION & SCREEN-TO-SCREEN NAVIGATION

All navigation from one Activity/screen to another MUST use the existing navigation utility functions from `Utils`.

Do NOT create direct navigation using `Intent` in every Activity unless there is a specific technical requirement that cannot be handled by the existing utility.

The existing navigation pattern is:

```kotlin
Utils.I(
    activity,
    TargetActivity::class.java,
    bundle
)
```

For navigation where the current Activity must be cleared:

```kotlin
Utils.I_clear(
    activity,
    TargetActivity::class.java,
    bundle
)
```

## 29.1 Normal Navigation

Use:
```kotlin
Utils.I(
    this,
    MealCustomizerActivity::class.java,
    bundle
)
```

instead of repeatedly writing:
```kotlin
val intent = Intent(
    this,
    MealCustomizerActivity::class.java
)
intent.putExtras(bundle)
startActivity(intent)
```

## 29.2 Clear-Stack Navigation

Use `Utils.I_clear(...)` for flows such as:
```text
Login → Dashboard
```
or
```text
Splash → Login / Dashboard
```
depending on authentication/subscription state.

## 29.3 Passing Data Between Screens

```kotlin
val bundle = Bundle().apply {
    putString("order_id", orderId)
    putString("delivery_date", deliveryDate)
}

Utils.I(
    this,
    OrderTrackingActivity::class.java,
    bundle
)
```

Do not create a new navigation/data-passing framework.

## 29.4 Navigation From Fragments

Use the existing `Utils` navigation method and the Fragment's Activity context according to the existing implementation. Do not create a different navigation architecture for Fragments (e.g. Calendar Customizer day-tabs, Wallet bottom-sheet triggers).

## 29.5 Do NOT Duplicate Navigation Logic

Do NOT create separate helpers such as:
- `NavigationHelper`
- `AppNavigator`
- `TiffinNavigationManager`
- `ActivityNavigator`

if the existing `Utils` navigation methods already provide the required functionality.

## 29.6 Navigation Rules

- Check whether `Utils.I()` already supports the required navigation.
- Use `Utils.I()` for normal screen-to-screen navigation.
- Use `Utils.I_clear()` when the previous Activity stack must be cleared.
- Use Bundle arguments when data must be passed.
- Do not put navigation/business logic inside repositories or API services.

## 29.7 Navigation Examples

**Open another screen**:
```kotlin
Utils.I(this, SubscriptionPlanActivity::class.java, bundle)
```

**Open another screen without data**:
```kotlin
Utils.I(this, WalletActivity::class.java, null)
```

**Clear previous screen stack**:
```kotlin
Utils.I_clear(this, DashboardActivity::class.java, null)
```

**Pass an order ID**:
```kotlin
val bundle = Bundle().apply {
    putString("order_id", orderId)
}
Utils.I(this, OrderTrackingActivity::class.java, bundle)
```

## 29.8 Navigation Consistency

```text
Login
  ↓ Utils.I_clear()
Dashboard
  ↓ Utils.I()
Subscription Plan Builder
  ↓ Utils.I()
Calendar Customizer
  ↓ Utils.I()
Checkout / Payment
```

Do not mix `Utils.I()`, `Intent()`, Navigation Component, `startActivity()`, or custom navigators randomly.

## 29.9 Navigation and Back Stack

Normal navigation:
```text
A → B → C   (Back: C → B → A)
```
Clear navigation:
```text
A → B   (A removed from stack when appropriate)
```

## 29.10 AI Rule

Before creating navigation code, the AI agent MUST search for existing navigation utilities and usages, and prefer `Utils.I(...)` / `Utils.I_clear(...)` over creating new navigation code.

## 29.11 Definition of Done — Navigation

- [ ] Correct `Utils` navigation method is used.
- [ ] `Utils.I()` used for normal navigation where applicable.
- [ ] `Utils.I_clear()` used when the back stack must be cleared.
- [ ] Required Bundle data passed correctly (order_id, subscription_id, delivery_date etc.).
- [ ] Receiving Activity reads the data correctly.
- [ ] Back button behavior is correct.
- [ ] No unnecessary direct `Intent` navigation exists.
- [ ] No duplicate navigation helper was created.
- [ ] Navigation works after API success.
- [ ] Navigation works after auth/subscription state changes.

---

# 51. CODING STYLE & WAY OF WRITING CODE

## 51.1 Follow Existing Project Code Style First

Before writing a new class:

1. Search the project for a similar implementation.
2. Read how the existing implementation works.
3. Follow the existing naming, structure, and method organization.
4. Reuse the existing implementation where possible.
5. Extend an existing component when appropriate.
6. Create a new implementation only when necessary.

## 51.2 Kotlin Naming

### Classes (PascalCase)
```kotlin
LoginActivity
CalendarCustomizerViewModel
SubscriptionRepository
MealOptionAdapter
WalletModel
```

### Functions (camelCase)
```kotlin
loginUser()
getDailyMenu()
submitMealSelection()
pauseSubscription()
showCutoffTimer()
```

### Variables (camelCase)
```kotlin
walletBalance
isLoading
subscriptionId
cutoffTime
```

### Constants
```kotlin
const val CUTOFF_LUNCH_HOUR = 22 // 10:00 PM previous night
const val CUTOFF_DINNER_HOUR = 14 // 2:00 PM
```
Do not randomly mix multiple constant naming styles.

## 51.3 Class Organization

```kotlin
@HiltViewModel
class CalendarCustomizerViewModel @Inject constructor(
    private val repository: MenuRepository,
    private val validation: Validation
) : ViewModel() {

    // LiveData / State

    // Validation

    // API methods

    // Private helper methods
}
```

## 51.4 ViewModel Code

```kotlin
@HiltViewModel
class SubscriptionViewModel @Inject constructor(
    private val repository: SubscriptionRepository
) : ViewModel() {

    private val _planResult = MutableLiveData<ApiResult<SubscriptionResponse>>()
    val planResult: LiveData<ApiResult<SubscriptionResponse>> = _planResult

    fun createSubscription(request: Map<String, String>) {
        viewModelScope.launch {
            repository.createSubscription(request, object : ApiCallback<SubscriptionResponse> {
                override fun onSuccess(result: ApiResult.Success<SubscriptionResponse>) {
                    _planResult.postValue(result)
                }

                override fun onError(result: ApiResult.Error<SubscriptionResponse>) {
                    _planResult.postValue(result)
                }
            })
        }
    }
}
```

## 51.5 Repository Code

```kotlin
class SubscriptionRepository @Inject constructor(
    private val apiService: ApiService
) {

    suspend fun createSubscription(
        request: Map<String, String>,
        apiCallback: ApiCallback<SubscriptionResponse>
    ) {
        try {
            val response = apiService.createSubscription(request)

            if (response.isSuccessful) {
                response.body()?.let {
                    apiCallback.onSuccess(ApiResult.Success(it, response.code()))
                }
            } else {
                // handle error
            }

        } catch (e: Exception) {
            apiCallback.onError(ApiResult.Error(e.message, null))
        }
    }
}
```

## 51.6 Activity / Fragment Code

```kotlin
class CalendarCustomizerActivity : BaseActivity() {

    private lateinit var binding: ActivityCalendarCustomizerBinding
    private val viewModel: CalendarCustomizerViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding = DataBindingUtil.setContentView(
            this,
            R.layout.activity_calendar_customizer
        )

        initView()
        initListener()
        observeData()
    }

    private fun initView() { ... }
    private fun initListener() { ... }
    private fun observeData() { ... }
}
```

## 51.7 UI Method Organization

```text
onCreate()
    ↓
initView()
    ↓
initListener()
    ↓
observeData()
```

## 51.8 Avoid Giant Methods

Prefer:
```kotlin
private fun submitMealSelection() {
    validateSelection()
    checkCutoffStatus()
    callSaveSelectionApi()
}
```
over one massive click-handler method.

## 51.9 Avoid Unnecessary Abstraction

Do not create:
- `BaseTiffinRepository`
- `BaseTiffinViewModel`
- `UniversalApiManager`
- `GenericScreenManager`

unless genuinely required. Reuse the existing architecture.

## 51.10 Null Safety

Prefer `?.let { }`. Avoid unnecessary `!!`.

## 51.11 Coroutines

```kotlin
viewModelScope.launch {
    ...
}
```
Do not launch unmanaged `GlobalScope.launch`.

## 51.12 API Calls

```text
View → ViewModel → Repository → ApiService
```
No direct API calls from Activity, Fragment, Adapter, or CustomView.

## 51.13 RecyclerView Adapters

Adapters handle binding, UI callbacks, item state only. No API/business logic inside adapters.

```kotlin
class SabziOptionAdapter(
    private val onOptionSelected: (SabziOptionModel) -> Unit
)
```

## 51.14 Binding

Use the project's existing ViewBinding / DataBinding approach consistently. Avoid `findViewById()` when binding is available.

## 51.15 Click Listeners

```kotlin
private fun initListener() {
    binding.btnConfirmMeal.setOnClickListener {
        validateAndSubmitMeal()
    }

    binding.btnPauseMeal.setOnClickListener {
        openPauseMealSheet()
    }
}
```

## 51.16 String / Resource Usage

Never: `binding.tvTitle.text = "Customize Meal"`
Use: `binding.tvTitle.text = getString(R.string.customize_meal)`

## 51.17 Colors

Never: `setTextColor(Color.parseColor("#C1502E"))`
Use: `ContextCompat.getColor(this, R.color.terracotta)` or `android:textColor="@color/terracotta"`.

## 51.18 Dimensions

Never raw pixels. Use SDP (`@dimen/_Xsdp`) / SSP (`@dimen/_Xssp`).

## 51.19 Fonts

Never `android:textStyle="bold"`. Use `@font/<font>_bold`.

## 51.20 Error Handling

Do not silently ignore exceptions (`catch (e: Exception) {}`).

## 51.21 Logging

Use the existing project logging utility (`Utils.E(...)`). No temporary debug logs in production. No second logging framework.

## 51.22 Comments

Only for non-obvious business behavior (e.g. cutoff-lock edge cases, wallet-credit rounding logic).

## 51.23 Magic Numbers & Magic Strings

Avoid. Use `StatusCodeConstant`, enums, or named constants (e.g. `CUTOFF_LUNCH_HOUR`).

## 51.24 Boolean & Function Naming

`isLoading`, `isSubscriptionActive`, `hasPausedMeal`. Functions describe actions: `loadDailyMenu()`, `submitMealSelection()`, `pauseSubscription()`.

## 51.25 Code Reuse & Modification Strategy

SEARCH EXISTING CODE → CAN IT BE REUSED? → YES: REUSE → NO: EXTEND → ONLY IF NECESSARY: CREATE NEW COMPONENT.

## 51.26 New Feature Coding Pattern

```text
Model → ApiService endpoint → Repository → ViewModel → Activity/Fragment → Adapter/Custom Component → Validation → Loading → Success/Error
```

## 51.27 Code Review Standard

* **Architecture**: MVVM, Hilt, Repository, API logic outside UI?
* **Code**: Clear naming, focused methods, no duplicates, null-safe, no unnecessary abstractions?
* **UI**: White background, brand colors & fonts, SDP, SSP, `strings.xml`?
* **State**: Loading, Success, Error, Validation, Duplicate-click prevention, Cutoff-lock state?
* **Build**: `./gradlew assembleDebug` succeeds cleanly.

---

# 52. DEVELOPMENT PHILOSOPHY

```text
READ → UNDERSTAND → SEARCH → REUSE → IMPLEMENT → TEST → BUILD → DOCUMENT
```

Never:
```text
GUESS → CREATE NEW CODE → DUPLICATE EXISTING LOGIC → FIX LATER
```

---

# 53. CLICK LISTENER ARCHITECTURE (`View.OnClickListener`)

All Activities and Fragments handling user click events MUST follow the centralized `View.OnClickListener` implementation pattern.

Do NOT write individual inline lambda click listeners for multiple views inside a screen.

## 53.1 Required Pattern

```kotlin
class SubscriptionPlanActivity : BaseActivity(), View.OnClickListener {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = DataBindingUtil.setContentView(this, R.layout.activity_subscription_plan)
        initView()
        initListener()
    }

    private fun initListener() {
        binding.btnContinue.setOnClickListener(this)
        binding.cv7Days.setOnClickListener(this)
        binding.cv15Days.setOnClickListener(this)
        binding.cv30Days.setOnClickListener(this)
    }

    override fun onClick(view: View?) {
        when (view) {
            binding.btnContinue -> { proceedToAddressSelection() }
            binding.cv7Days -> { selectPlan(PlanType.SEVEN_DAYS) }
            binding.cv15Days -> { selectPlan(PlanType.FIFTEEN_DAYS) }
            binding.cv30Days -> { selectPlan(PlanType.THIRTY_DAYS) }
        }
    }
}
```

## 53.2 Rules for Click Handling

- Class MUST implement `View.OnClickListener`.
- `initListener()` MUST register views with `.setOnClickListener(this)`.
- Central `override fun onClick(view: View?)` MUST handle all view clicks via a `when (view)` block.
- Delegate complex logic (e.g. cutoff validation, wallet debit) to ViewModels or private helper methods.

---

# 54. KOTLIN PROPERTY & MODEL GUIDELINES (NO MANUAL GETTERS / SETTERS)

- Do NOT write Java-style getter/setter functions (e.g. `getSabziName()`, `setSabziName()`).
- Do NOT include comments such as `// Getters and Setters`.
- Kotlin automatically provides idiomatic property accessors for `val`/`var`.
- Keep model classes (e.g. `SabziOptionModel`, `SubscriptionModel`, `WalletTransactionModel`) clean, concise, standard data classes.

---

# 55. LAYOUT QUALITY & INTERACTION RULES (TOUCH FEEDBACK & TEXT INTEGRITY)

## 55.1 Mandatory Touch Feedback (Ripple Effect)

Every clickable container/view (sabzi option cards, plan cards, wallet transaction rows, etc.) MUST include:
- `android:clickable="true"`
- `android:focusable="true"`
- `android:foreground="?attr/selectableItemBackground"` (or `app:rippleColor` / state-list `app:cardBackgroundColor` for `MaterialCardView`).
- NEVER leave any tappable element without a press/ripple state.

## 55.2 Complete Text Integrity (No Mid-Word / Mid-Phrase Truncation)

- Sabzi names, plan descriptions, and add-on labels must NEVER render truncated mid-phrase.
- Never pair subtitle/description `TextView`s with `maxLines="1"` and fixed narrow widths if text can overflow (e.g. long dish names like "Paneer Butter Masala with Tawa Roti").
- Allow `maxLines="2"`, set `android:gravity="center"`, adjust padding, and use appropriate SDP/SSP sizing so phrases render completely.

---

# 56. TIFFIN-SPECIFIC DOMAIN RULES

## 56.1 Cutoff-Lock Logic
- Cutoff time calculation (Lunch: 10:00 PM previous night, Dinner: 2:00 PM) must live in a single centralized utility (e.g. `CutoffManager`), never duplicated per screen.
- Once locked, the Calendar Customizer day UI must visually disable selection (greyed out + lock icon) — do not just disable the button while leaving the UI looking editable.

## 56.2 Wallet & Pause-Meal Consistency
- Any action that credits/debits the wallet (Pause Meal, refund, trial-to-subscription upgrade) must go through a single `WalletRepository` method — never update wallet balance directly from UI state.

## 56.3 Dual Address Handling
- Office (Lunch) and Home (Dinner) addresses must be modeled as distinct fields on the user/subscription model, not as a generic "addresses list" unless the API explicitly supports multiple tagged addresses.

## 56.4 QR / Order Status
- Order status values (Confirmed, Preparing, Out for Delivery, Delivered) must use a shared enum/constant class, consistent with whatever the Rider/Admin backend emits — do not hardcode status strings per screen.
