class ApiConstants {
  // Base URL pointing to active Spring Boot backend
  static const String baseUrl = 'http://192.168.1.70:7070/api/v1';

  // Auth Endpoints
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // User Profile & Addresses
  static const String userProfile = '/user/profile';
  static const String userAddresses = '/user/addresses';
  static const String userAllergies = '/user/allergies';
  static const String userLocation = '/user/location';

  // Menu Endpoints
  static const String menuDaily = '/menu/daily';
  static const String menuWeekly = '/menu/weekly';
  static const String menuNext7Days = '/menu/next-7-days';
  static const String menuItems = '/menu-items';

  // Subscriptions
  static const String subscriptionPlans = '/subscription/plans';
  static const String mySubscriptions = '/subscription/my-subscriptions';
  static const String subscribe = '/subscription/subscribe';
  static const String pauseMeal = '/subscription/pause-meal';
  static const String razorpayOrder = '/subscription/razorpay/create-order';

  // Meal Orders
  static const String customizeOrder = '/orders/customize';
  static const String myOrders = '/orders/my-orders';
  static const String calendarOrders = '/orders/calendar-view';

  // Flexi-Wallet
  static const String walletSummary = '/wallet/summary';
  static const String walletRecharge = '/wallet/recharge';

  // Kitchen Discovery
  static const String kitchens = '/kitchen/all';
  
  // Categories & Items
  static const String categories = '/categories';
  static String categoryItems(String categoryId) => '/categories/$categoryId/items';
}
