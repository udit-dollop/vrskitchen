import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/models/subscription_model.dart';
import '../data/models/daily_menu_model.dart';
import '../data/models/order_model.dart';
import '../data/models/wallet_transaction_model.dart';
import '../data/models/kitchen_prep_model.dart';
import '../data/models/rider_delivery_model.dart';
import '../data/models/meal_item_model.dart';
import '../data/models/add_on_model.dart';
import '../core/services/api_service.dart';
import '../core/network/api_client.dart';

enum DemoRole { customer, admin, rider }

class AppStateProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final ApiClient _apiClient = ApiClient();

  ApiService get apiService => _apiService;
  ApiClient get apiClient => _apiClient;

  // Backend Sync State
  bool _isLoadingBackend = false;
  bool get isLoadingBackend => _isLoadingBackend;

  bool _isBackendConnected = false;
  bool get isBackendConnected => _isBackendConnected;

  String? _backendError;
  String? get backendError => _backendError;

  // Current Active Demo Role
  DemoRole _activeRole = DemoRole.customer;
  DemoRole get activeRole => _activeRole;

  void setRole(DemoRole role) {
    _activeRole = role;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 1. User Profile State (Initialized as Empty - populated ONLY by API)
  // ---------------------------------------------------------------------------
  UserModel _user = const UserModel(
    id: "",
    name: "",
    phone: "",
    email: "",
    dietaryPreference: "",
    spiceLevel: "",
    allergies: [],
    addresses: [],
    selectedAddressId: "",
  );
  UserModel get user => _user;

  void updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? dietaryPreference,
    String? spiceLevel,
    List<String>? allergies,
    String? selectedAddressId,
  }) {
    _user = _user.copyWith(
      name: name,
      phone: phone,
      email: email,
      dietaryPreference: dietaryPreference,
      spiceLevel: spiceLevel,
      allergies: allergies,
      selectedAddressId: selectedAddressId,
    );
    notifyListeners();

    if (_apiClient.isAuthenticated) {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;
      if (dietaryPreference != null) {
        updateData['dietaryPreference'] = dietaryPreference.toUpperCase().replaceAll(' ', '_');
      }
      if (spiceLevel != null) updateData['spiceLevel'] = spiceLevel.toUpperCase();

      _apiService.updateUserProfile(updateData).catchError((_) => <String, dynamic>{});
    }
  }

  void addAddress(AddressModel address) {
    final updatedList = List<AddressModel>.from(_user.addresses)..add(address);
    _user = _user.copyWith(addresses: updatedList);
    notifyListeners();

    if (_apiClient.isAuthenticated) {
      _apiService.addUserAddress(
        tag: address.tag,
        addressLine: address.addressLine,
        landmark: address.landmark,
        isDefault: address.isDefault,
      ).then((_) => syncAddresses()).catchError((_) => <String, dynamic>{});
    }
  }

  Future<void> syncAddresses() async {
    try {
      final list = await _apiService.getUserAddresses();
      final addresses = <AddressModel>[];
      for (var a in list) {
        final m = a as Map<String, dynamic>;
        addresses.add(AddressModel(
          id: m['id']?.toString() ?? '',
          tag: m['addressType']?.toString().toLowerCase().capitalize() ?? 'Home',
          addressLine: m['addressLine']?.toString() ?? '',
          landmark: m['landmark']?.toString() ?? '',
          isDefault: m['isDefault'] == true,
        ));
      }
      _user = _user.copyWith(
        addresses: addresses,
        selectedAddressId: addresses.isNotEmpty ? addresses.first.id : '',
      );
      notifyListeners();
    } catch (_) {}
  }

  Future<void> deleteAddressBackend(String addressId) async {
    _user = _user.copyWith(
      addresses: _user.addresses.where((a) => a.id != addressId).toList(),
    );
    notifyListeners();
    if (_apiClient.isAuthenticated) {
      try {
        await _apiService.deleteUserAddress(addressId);
      } catch (_) {}
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Subscription State (Null if not subscribed on backend)
  // ---------------------------------------------------------------------------
  UserSubscriptionModel? _currentSubscription;
  UserSubscriptionModel? get currentSubscription => _currentSubscription;
  bool get hasActiveSubscription => _currentSubscription != null && _currentSubscription!.isActive;

  void activateSubscription({
    required PackageType packageType,
    required int mealsCount,
    required double price,
    required String slot,
  }) {
    _currentSubscription = UserSubscriptionModel(
      id: "SUB_VR_${DateTime.now().millisecondsSinceEpoch % 10000}",
      packageType: packageType,
      totalMeals: mealsCount,
      remainingMeals: mealsCount,
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: mealsCount == 30 ? 30 : 56)),
      slot: slot,
      amountPaid: price,
      isActive: true,
      isPaused: false,
    );
    notifyListeners();
  }

  void pauseMeal({required DateTime fromDate, required DateTime toDate, double credit = 80.0}) {
    if (_currentSubscription != null) {
      _currentSubscription = _currentSubscription!.copyWith(isPaused: true);
    }
    addWalletTransaction(
      title: "Paused Meal Credit",
      description: "Credit for paused meal on ${fromDate.day}/${fromDate.month}",
      amount: credit,
      type: TransactionType.credit,
    );
    notifyListeners();

    if (_apiClient.isAuthenticated) {
      final startStr = "${fromDate.year}-${fromDate.month.toString().padLeft(2, '0')}-${fromDate.day.toString().padLeft(2, '0')}";
      final endStr = "${toDate.year}-${toDate.month.toString().padLeft(2, '0')}-${toDate.day.toString().padLeft(2, '0')}";
      _apiService.pauseMeal(startDate: startStr, endDate: endStr).then((_) {
        syncWallet();
        syncSubscriptions();
      }).catchError((_) {});
    }
  }

  void resumeMeal() {
    if (_currentSubscription != null) {
      _currentSubscription = _currentSubscription!.copyWith(isPaused: false);
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // 3. Flexi-Wallet State (Starts at 0.0 - populated ONLY by API)
  // ---------------------------------------------------------------------------
  double _walletBalance = 0.0;
  double get walletBalance => _walletBalance;
  final List<WalletTransactionModel> _walletTransactions = [];
  List<WalletTransactionModel> get walletTransactions => _walletTransactions;

  void addWalletTransaction({
    required String title,
    required String description,
    required double amount,
    required TransactionType type,
  }) {
    if (type == TransactionType.credit) {
      _walletBalance += amount;
    } else {
      _walletBalance -= amount;
    }
    _walletTransactions.insert(
      0,
      WalletTransactionModel(
        id: "TXN_${DateTime.now().millisecondsSinceEpoch % 10000}",
        title: title,
        description: description,
        amount: amount,
        type: type,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();

    if (_apiClient.isAuthenticated && type == TransactionType.credit) {
      _apiService.rechargeWallet(amount: amount).then((_) => syncWallet()).catchError((_) {});
    }
  }

  Future<void> syncWallet() async {
    try {
      final data = await _apiService.getWalletSummary();
      if (data.isNotEmpty) {
        if (data['currentBalance'] != null) {
          _walletBalance = (data['currentBalance'] as num).toDouble();
        }
        final txns = data['recentTransactions'];
        _walletTransactions.clear();
        if (txns is List && txns.isNotEmpty) {
          for (var t in txns) {
            final m = t as Map<String, dynamic>;
            final isCredit = (m['transactionType']?.toString().contains('CREDIT') ?? true);
            _walletTransactions.add(
              WalletTransactionModel(
                id: m['id']?.toString() ?? '',
                title: m['transactionType']?.toString().replaceAll('_', ' ') ?? 'Transaction',
                description: m['description']?.toString() ?? '',
                amount: ((m['amount'] ?? 0) as num).toDouble(),
                type: isCredit ? TransactionType.credit : TransactionType.debit,
                timestamp: DateTime.tryParse(m['timestamp']?.toString() ?? '') ?? DateTime.now(),
              ),
            );
          }
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // 4. Menu & Customization State (Empty until published on backend)
  // ---------------------------------------------------------------------------
  List<DailyMenuModel> _weeklyMenu = [];
  List<DailyMenuModel> get weeklyMenu => _weeklyMenu;

  String _selectedSabzi = "";
  String get selectedSabzi => _selectedSabzi;

  String _selectedRoti = "";
  String get selectedRoti => _selectedRoti;

  String _selectedRice = "";
  String get selectedRice => _selectedRice;

  final Map<String, int> _selectedAddOns = {};
  Map<String, int> get selectedAddOns => _selectedAddOns;

  void updateMealCustomization({
    required String sabzi,
    required String roti,
    required String rice,
    required Map<String, int> addOns,
  }) {
    _selectedSabzi = sabzi;
    _selectedRoti = roti;
    _selectedRice = rice;
    _selectedAddOns.clear();
    _selectedAddOns.addAll(addOns);

    if (_orders.isNotEmpty) {
      final todayOrder = _orders.first;
      todayOrder.status = OrderStatus.preparing;
    }
    notifyListeners();
    // API call is handled by MealCustomizerScreen — do NOT call it here
  }

  final Map<String, String> _calendarCustomizedDays = {};
  Map<String, String> get calendarCustomizedDays => _calendarCustomizedDays;

  void setCalendarStatus(String dateKey, String status) {
    _calendarCustomizedDays[dateKey] = status;
    notifyListeners();
  }

  Future<void> syncWeeklyMenu() async {
    try {
      final now = DateTime.now();
      final startStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final end = now.add(const Duration(days: 7));
      final endStr = "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      final list = await _apiService.getWeeklyMenu(startDate: startStr, endDate: endStr);
      if (list.isNotEmpty) {
        final List<DailyMenuModel> menus = [];
        for (var item in list) {
          final m = item as Map<String, dynamic>;
          final dateParsed = DateTime.tryParse(m['menuDate']?.toString() ?? '') ?? DateTime.now();
          final dayName = _getDayName(dateParsed.weekday);

          final sabzis = <MealItemModel>[];
          if (m['sabziOptions'] is List) {
            for (var s in m['sabziOptions']) {
              sabzis.add(MealItemModel(
                id: s['id']?.toString() ?? '',
                name: s['name']?.toString() ?? '',
                description: s['description']?.toString() ?? '',
                category: MealCategory.sabzi,
                imagePath: "assets/images/paneer_butter.png",
              ));
            }
          }
          if (sabzis.isEmpty) {
            final sabziName = m['sabziName']?.toString() ??
                m['mainSabzi']?.toString() ??
                m['name']?.toString() ??
                "Chef's Special Sabzi";
            sabzis.add(MealItemModel(
              id: 'sabzi_default',
              name: sabziName,
              description: 'Fresh seasonal vegetable preparation',
              category: MealCategory.sabzi,
              imagePath: "assets/images/paneer_butter.png",
            ));
          }

          final rotiModel = MealItemModel(
            id: 'roti',
            name: m['rotiName']?.toString() ?? 'Butter Roti',
            description: '',
            category: MealCategory.roti,
            imagePath: 'assets/images/butter_roti.png',
          );
          final riceModel = MealItemModel(
            id: 'rice',
            name: m['riceName']?.toString() ?? 'Jeera Rice',
            description: '',
            category: MealCategory.rice,
            imagePath: 'assets/images/jeera_rice.png',
          );

          menus.add(
            DailyMenuModel(
              date: dateParsed,
              dayName: dayName,
              lunchSabzis: sabzis,
              lunchDal: MealItemModel(
                id: 'dal',
                name: m['dalName']?.toString() ?? 'Tadka Dal',
                description: '',
                category: MealCategory.dal,
                imagePath: 'assets/images/dal_tadka.png',
              ),
              lunchRotis: [rotiModel],
              lunchRice: [riceModel],
              lunchAddons: [],
              dinnerSabzis: sabzis,
              dinnerDal: MealItemModel(
                id: 'dal',
                name: m['dalName']?.toString() ?? 'Tadka Dal',
                description: '',
                category: MealCategory.dal,
                imagePath: 'assets/images/dal_tadka.png',
              ),
              dinnerRotis: [rotiModel],
              dinnerRice: [riceModel],
              dinnerAddons: [],
            ),
          );
        }
        _weeklyMenu = menus;
        if (menus.isNotEmpty && menus.first.lunchSabzis.isNotEmpty) {
          _selectedSabzi = menus.first.lunchSabzis.first.name;
          _selectedRoti = "5 Butter Roti";
          _selectedRice = "Jeera Rice";
        }
        notifyListeners();
      } else {
        _weeklyMenu = [];
      }
    } catch (_) {
      _weeklyMenu = [];
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return "Monday";
      case 2: return "Tuesday";
      case 3: return "Wednesday";
      case 4: return "Thursday";
      case 5: return "Friday";
      case 6: return "Saturday";
      case 7: return "Sunday";
      default: return "Today";
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Orders State (Empty until fetched from API)
  // ---------------------------------------------------------------------------
  List<OrderItemModel> _orders = [];
  List<OrderItemModel> get orders => _orders;

  void addNewOrder(OrderItemModel order) {
    _orders.insert(0, order);
    if (_currentSubscription != null && _currentSubscription!.remainingMeals > 0) {
      _currentSubscription = _currentSubscription!.copyWith(
        remainingMeals: _currentSubscription!.remainingMeals - 1,
      );
    }
    notifyListeners();
  }

  Future<void> syncOrders() async {
    try {
      final list = await _apiService.getMyOrders();
      final newOrders = <OrderItemModel>[];
      if (list.isNotEmpty) {
        for (var item in list) {
          final m = item as Map<String, dynamic>;
          final statusStr = m['orderStatus']?.toString() ?? 'PREPARING';
          OrderStatus st = OrderStatus.preparing;
          if (statusStr == 'DELIVERED') st = OrderStatus.delivered;
          if (statusStr == 'OUT_FOR_DELIVERY') st = OrderStatus.outForDelivery;
          if (statusStr == 'PAUSED') st = OrderStatus.paused;

          newOrders.add(
            OrderItemModel(
              orderId: m['orderToken']?.toString() ?? (m['id']?.toString().substring(0, 8) ?? 'ORD'),
              planName: m['planName']?.toString() ?? 'Standard Thali',
              date: DateTime.tryParse(m['deliveryDate']?.toString() ?? '') ?? DateTime.now(),
              slot: m['slot']?.toString() == 'DINNER' ? 'Dinner (8:00 PM - 10:00 PM)' : 'Lunch (12:00 PM - 2:00 PM)',
              sabzi: (m['selectedSabziNames'] is List && (m['selectedSabziNames'] as List).isNotEmpty)
                  ? (m['selectedSabziNames'] as List).first.toString()
                  : '',
              dal: m['selectedDalName']?.toString() ?? '',
              roti: "${m['rotiCount'] ?? 5} Butter Roti",
              rice: m['selectedRiceName']?.toString() ?? '',
              addOns: (m['addOnNames'] is List) ? (m['addOnNames'] as List).map((e) => e.toString()).toList() : [],
              amount: ((m['totalAmountPaid'] ?? m['baseAmount'] ?? 0) as num).toDouble(),
              status: st,
              deliveryAddress: m['deliveryAddressText']?.toString() ?? '',
            ),
          );
        }
      }
      _orders = newOrders;
      notifyListeners();
    } catch (_) {
      _orders = [];
    }
  }

  Future<void> syncSubscriptions() async {
    try {
      final list = await _apiService.getMySubscriptions();
      if (list.isNotEmpty) {
        final m = list.first as Map<String, dynamic>;
        _currentSubscription = UserSubscriptionModel(
          id: m['id']?.toString() ?? 'SUB_LIVE',
          packageType: (m['planName']?.toString().toLowerCase().contains('premium') ?? false)
              ? PackageType.premium
              : PackageType.standard,
          totalMeals: m['durationDays'] != null ? (m['durationDays'] as num).toInt() : 30,
          remainingMeals: m['durationDays'] != null ? (m['durationDays'] as num).toInt() : 28,
          startDate: DateTime.tryParse(m['startDate']?.toString() ?? '') ?? DateTime.now(),
          expiryDate: DateTime.tryParse(m['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 30)),
          slot: m['mealSlot']?.toString() ?? 'LUNCH',
          amountPaid: ((m['pricePerMeal'] ?? 80) as num).toDouble() * 30,
          isActive: m['status']?.toString() == 'ACTIVE',
          isPaused: m['status']?.toString() == 'PAUSED',
        );
      } else {
        _currentSubscription = null;
      }
      notifyListeners();
    } catch (_) {
      _currentSubscription = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Subscription Plans Catalog State (Fetched strictly from Backend API)
  // ---------------------------------------------------------------------------
  List<SubscriptionPackageModel> _subscriptionPlans = [];
  List<SubscriptionPackageModel> get subscriptionPlans => _subscriptionPlans;

  Future<void> syncSubscriptionPlans() async {
    try {
      final list = await _apiService.getSubscriptionPlans();
      if (list.isNotEmpty) {
        final List<SubscriptionPackageModel> plans = [];
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            plans.add(SubscriptionPackageModel.fromJson(item));
          }
        }
        _subscriptionPlans = plans;
      } else {
        _subscriptionPlans = [];
      }
      notifyListeners();
    } catch (_) {
      _subscriptionPlans = [];
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Available Add-ons State (Fetched strictly from Backend Menu Items)
  // ---------------------------------------------------------------------------
  List<AddOnItem> _availableAddOns = [];
  List<AddOnItem> get availableAddOns => _availableAddOns;

  Future<void> syncAddOns() async {
    try {
      final list = await _apiClient.get('/menu-items/active');
      if (list is List && list.isNotEmpty) {
        final List<AddOnItem> items = [];
        for (var item in list) {
          if (item is Map<String, dynamic>) {
            final cat = item['categoryCode']?.toString().toUpperCase() ?? '';
            final extraPrice = (item['extraPrice'] as num?)?.toDouble() ?? 0.0;
            if (cat == 'SWEETS' || cat == 'ADDON' || cat == 'EXTRA' || extraPrice > 0) {
              items.add(AddOnItem(
                id: item['id']?.toString() ?? '',
                name: item['name']?.toString() ?? '',
                description: item['description']?.toString() ?? '',
                price: extraPrice > 0 ? extraPrice : 20.0,
                imagePath: 'assets/images/gulab_jamun.png',
              ));
            }
          }
        }
        _availableAddOns = items;
      } else {
        _availableAddOns = [];
      }
      notifyListeners();
    } catch (_) {
      _availableAddOns = [];
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Master Initializer & Sync (Strict Live API - No Mocks)
  // ---------------------------------------------------------------------------
  Future<void> initBackendSession() async {
    _isLoadingBackend = true;
    _backendError = null;
    notifyListeners();

    try {
      await _apiClient.init();

      // If accessToken is missing or expired, but refreshToken exists, refresh it
      if (!_apiClient.isAuthenticated && _apiClient.refreshToken != null && _apiClient.refreshToken!.isNotEmpty) {
        await _apiClient.refreshTokenSession();
      }

      if (_apiClient.isAuthenticated) {
        _isBackendConnected = true;
        await Future.wait([
          syncUserProfile(),
          syncWallet(),
          syncSubscriptions(),
          syncSubscriptionPlans(),
          syncAddOns(),
          syncOrders(),
          syncWeeklyMenu(),
        ]).catchError((_) => []);
      }
    } catch (e) {
      _backendError = e.toString();
      _isBackendConnected = false;
    } finally {
      _isLoadingBackend = false;
      notifyListeners();
    }
  }

  Future<void> syncUserProfile() async {
    try {
      final p = await _apiService.getUserProfile();
      if (p.isNotEmpty) {
        _user = _user.copyWith(
          id: p['id']?.toString() ?? '',
          name: p['name']?.toString() ?? '',
          phone: p['phone']?.toString() ?? '',
          email: p['email']?.toString() ?? '',
          dietaryPreference: p['dietaryPreference']?.toString().replaceAll('_', ' ').toLowerCase().capitalize() ?? 'Veg',
          spiceLevel: p['spiceLevel']?.toString().toLowerCase().capitalize() ?? 'Medium',
        );
        await syncAddresses();
        notifyListeners();
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Authentication Actions
  // ---------------------------------------------------------------------------
  Future<bool> loginWithCredentials(String phone, String password) async {
    _isLoadingBackend = true;
    _backendError = null;
    notifyListeners();
    try {
      final res = await _apiService.login(phone: phone, password: password);
      if (res['accessToken'] != null) {
        _isBackendConnected = true;
        await syncUserProfile();
        await syncWallet();
        await syncSubscriptions();
        await syncSubscriptionPlans();
        await syncAddOns();
        await syncOrders();
        await syncWeeklyMenu();
        _isLoadingBackend = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _backendError = e.toString();
      _isLoadingBackend = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> sendOtpForLogin(String phone) async {
    return await _apiService.sendOtp(phone);
  }

  Future<bool> verifyOtpForLogin({required String phone, required String otp, required String token}) async {
    _isLoadingBackend = true;
    _backendError = null;
    notifyListeners();
    try {
      final res = await _apiService.verifyOtp(phone: phone, otp: otp, verificationToken: token);
      if (res['accessToken'] != null) {
        _isBackendConnected = true;
        await syncUserProfile();
        await syncWallet();
        await syncSubscriptions();
        await syncSubscriptionPlans();
        await syncAddOns();
        await syncOrders();
        await syncWeeklyMenu();
        _isLoadingBackend = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _backendError = e.toString();
      _isLoadingBackend = false;
      notifyListeners();
      return false;
    }
  }

  bool get isAuthenticated => _apiClient.isAuthenticated;

  Future<void> logout() async {
    await _apiService.logout();
    _isBackendConnected = false;
    _user = const UserModel(
      id: "",
      name: "",
      phone: "",
      email: "",
      dietaryPreference: "",
      spiceLevel: "",
      allergies: [],
      addresses: [],
      selectedAddressId: "",
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Admin & Rider State (Clean Empty Lists)
  // ---------------------------------------------------------------------------
  final List<KitchenPrepItem> _kitchenPrepItems = [];
  List<KitchenPrepItem> get kitchenPrepItems => _kitchenPrepItems;

  void updateKitchenItemStatus(String id, PrepStatus newStatus) {
    final index = _kitchenPrepItems.indexWhere((it) => it.id == id);
    if (index != -1) {
      _kitchenPrepItems[index].status = newStatus;
      notifyListeners();
    }
  }

  final List<InventoryItemModel> _inventoryItems = [];
  List<InventoryItemModel> get inventoryItems => _inventoryItems;

  void addInventoryStock(String id, double addedQty) {
    final index = _inventoryItems.indexWhere((it) => it.id == id);
    if (index != -1) {
      final current = _inventoryItems[index];
      _inventoryItems[index] = InventoryItemModel(
        id: current.id,
        name: current.name,
        currentStock: current.currentStock + addedQty,
        minRequired: current.minRequired,
        unit: current.unit,
        isLowStock: (current.currentStock + addedQty) < current.minRequired,
      );
      notifyListeners();
    }
  }

  bool _isRiderOnDuty = true;
  bool get isRiderOnDuty => _isRiderOnDuty;

  void toggleRiderDuty(bool val) {
    _isRiderOnDuty = val;
    notifyListeners();
  }

  final List<DeliveryStopModel> _riderStops = [];
  List<DeliveryStopModel> get riderStops => _riderStops;

  void verifyStopQr(String orderId) {
    final index = _riderStops.indexWhere((s) => s.orderId == orderId);
    if (index != -1) {
      _riderStops[index].isQrVerified = true;
      notifyListeners();
    }
  }

  void markStopDelivered(String orderId) {
    final index = _riderStops.indexWhere((s) => s.orderId == orderId);
    if (index != -1) {
      _riderStops[index].status = DeliveryStatus.delivered;
    }
    final customerOrder = _orders.where((o) => o.orderId == orderId).firstOrNull;
    if (customerOrder != null) {
      customerOrder.status = OrderStatus.delivered;
    }
    notifyListeners();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return '';
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
