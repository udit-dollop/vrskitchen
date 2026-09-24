import 'package:flutter/material.dart';
import '../../features/onboarding/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/otp_screen.dart';
import '../../features/authentication/dietary_setup_screen.dart';
import '../../features/customer/customer_main_shell.dart';
import '../../features/customer/trial/trial_slot_picker_screen.dart';
import '../../features/customer/trial/trial_checkout_screen.dart';
import '../../features/customer/trial/trial_confirmation_screen.dart';
import '../../features/customer/subscription/plan_selector_screen.dart';
import '../../features/customer/subscription/subscription_addons_screen.dart';
import '../../features/customer/subscription/subscription_success_screen.dart';
import '../../features/customer/customization/meal_customizer_screen.dart';
import '../../features/customer/customization/calendar_schedule_screen.dart';
import '../../features/customer/wallet/wallet_screen.dart';
import '../../features/customer/orders/order_tracking_screen.dart';
import '../../features/customer/notifications/notifications_screen.dart';
import '../../features/customer/profile/saved_addresses_screen.dart';
import '../../features/admin/admin_dashboard_screen.dart';
import '../../features/admin/kitchen_prep_screen.dart';
import '../../features/admin/admin_menu_screen.dart';
import '../../features/admin/qr_stickers_screen.dart';
import '../../features/admin/inventory_screen.dart';
import '../../features/admin/subscribers_management_screen.dart';
import '../../features/rider/rider_dashboard_screen.dart';
import '../../features/rider/batch_checklist_screen.dart';
import '../../features/rider/qr_scanner_screen.dart';
import '../../features/rider/delivery_route_screen.dart';
import '../../features/rider/delivery_confirmation_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String dietarySetup = '/dietary-setup';
  static const String customerHome = '/customer-home';
  static const String trialSlot = '/trial-slot';
  static const String trialCheckout = '/trial-checkout';
  static const String trialConfirmation = '/trial-confirmation';
  static const String subscriptionPlans = '/subscription-plans';
  static const String subscriptionAddons = '/subscription-addons';
  static const String subscriptionSuccess = '/subscription-success';
  static const String mealCustomizer = '/meal-customizer';
  static const String calendarSchedule = '/calendar-schedule';
  static const String wallet = '/wallet';
  static const String orderTracking = '/order-tracking';
  static const String notifications = '/notifications';
  static const String savedAddresses = '/saved-addresses';

  // Admin Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String kitchenPrep = '/kitchen-prep';
  static const String adminMenu = '/admin-menu';
  static const String qrStickers = '/qr-stickers';
  static const String inventory = '/inventory';
  static const String subscribers = '/subscribers';

  // Rider Routes
  static const String riderDashboard = '/rider-dashboard';
  static const String batchChecklist = '/batch-checklist';
  static const String qrScanner = '/qr-scanner';
  static const String deliveryRoute = '/delivery-route';
  static const String deliveryConfirmation = '/delivery-confirmation';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboarding: (context) => const OnboardingScreen(),
    login: (context) => const LoginScreen(),
    otp: (context) => const OtpScreen(),
    dietarySetup: (context) => const DietarySetupScreen(),
    customerHome: (context) => const CustomerMainShell(),
    trialSlot: (context) => const TrialSlotPickerScreen(),
    trialCheckout: (context) => const TrialCheckoutScreen(),
    trialConfirmation: (context) => const TrialConfirmationScreen(),
    subscriptionPlans: (context) => const PlanSelectorScreen(),
    subscriptionAddons: (context) => const SubscriptionAddonsScreen(),
    subscriptionSuccess: (context) => const SubscriptionSuccessScreen(),
    mealCustomizer: (context) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? menuDate;
      String? initialSlot;
      if (args is Map<String, dynamic>) {
        menuDate = args['menuDate'] as String?;
        initialSlot = args['initialSlot'] as String?;
      }
      return MealCustomizerScreen(menuDate: menuDate, initialSlot: initialSlot);
    },
    calendarSchedule: (context) => const CalendarScheduleScreen(),
    wallet: (context) => const WalletScreen(),
    orderTracking: (context) => const OrderTrackingScreen(),
    notifications: (context) => const NotificationsScreen(),
    savedAddresses: (context) => const SavedAddressesScreen(),
    adminDashboard: (context) => const AdminDashboardScreen(),
    kitchenPrep: (context) => const KitchenPrepScreen(),
    adminMenu: (context) => const AdminMenuScreen(),
    qrStickers: (context) => const QrStickersScreen(),
    inventory: (context) => const InventoryScreen(),
    subscribers: (context) => const SubscribersManagementScreen(),
    riderDashboard: (context) => const RiderDashboardScreen(),
    batchChecklist: (context) => const BatchChecklistScreen(),
    qrScanner: (context) => const QrScannerScreen(),
    deliveryRoute: (context) => const DeliveryRouteScreen(),
    deliveryConfirmation: (context) => const DeliveryConfirmationScreen(),
  };
}
