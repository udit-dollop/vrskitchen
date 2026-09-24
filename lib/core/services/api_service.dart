import '../../data/models/daily_menu_api_model.dart';
import '../network/api_client.dart';
import '../network/api_constants.dart';

class ApiService {
  final ApiClient _client = ApiClient();

  // ---------------------------------------------------------------------------
  // 1. AUTHENTICATION APIS
  // ---------------------------------------------------------------------------

  /// Send OTP to user's mobile number
  /// Returns { phone, verificationToken, expiresInSeconds, devOtp }
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '').trim();
    final formattedPhone = cleanPhone.length > 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    final response = await _client.post(
      ApiConstants.sendOtp,
      body: {'phone': formattedPhone},
    );
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  /// Verify OTP and obtain JWT Bearer Token
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    required String verificationToken,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '').trim();
    final formattedPhone = cleanPhone.length > 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    final response = await _client.post(
      ApiConstants.verifyOtp,
      body: {
        'phone': formattedPhone,
        'otp': otp.trim(),
        'verificationToken': verificationToken.trim(),
      },
    );

    if (response is Map<String, dynamic>) {
      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      if (accessToken != null) {
        await _client.setTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      return response;
    }
    return <String, dynamic>{};
  }

  /// Login with Phone & Password
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '').trim();
    final formattedPhone = cleanPhone.length > 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    final response = await _client.post(
      ApiConstants.login,
      body: {
        'phone': formattedPhone,
        'password': password,
      },
    );

    if (response is Map<String, dynamic>) {
      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      if (accessToken != null) {
        await _client.setTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      return response;
    }
    return <String, dynamic>{};
  }

  /// Register customer profile with dietary preferences
  Future<Map<String, dynamic>> register({
    required String phone,
    required String name,
    required String password,
    String? email,
    String? dietaryPreference,
    String? spiceLevel,
    String? allergies,
    String? kitchenId,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '').trim();
    final formattedPhone = cleanPhone.length > 10 ? cleanPhone.substring(cleanPhone.length - 10) : cleanPhone;

    final body = <String, dynamic>{
      'name': name,
      'password': password,
      'email': email ?? '',
      'role': 'ROLE_CUSTOMER',
      'dietaryPreference': dietaryPreference ?? 'VEG',
      'spiceLevel': spiceLevel ?? 'MEDIUM',
      'allergies': allergies ?? '',
    };
    if (kitchenId != null) {
      body['kitchenId'] = kitchenId;
    }

    final response = await _client.post(
      '${ApiConstants.register}?phone=$formattedPhone',
      body: body,
    );

    if (response is Map<String, dynamic>) {
      final accessToken = response['accessToken'] as String?;
      final refreshToken = response['refreshToken'] as String?;
      if (accessToken != null) {
        await _client.setTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
      return response;
    }
    return <String, dynamic>{};
  }

  /// Refresh JWT token using refreshToken
  Future<Map<String, dynamic>> refreshToken({String? refreshToken}) async {
    final tokenToUse = refreshToken ?? _client.refreshToken;
    if (tokenToUse == null || tokenToUse.isEmpty) {
      return <String, dynamic>{};
    }
    final response = await _client.post(
      ApiConstants.refreshToken,
      body: {'refreshToken': tokenToUse},
    );
    if (response is Map<String, dynamic>) {
      final newAccessToken = response['accessToken'] as String?;
      final newRefreshToken = response['refreshToken'] as String? ?? tokenToUse;
      if (newAccessToken != null && newAccessToken.isNotEmpty) {
        await _client.setTokens(accessToken: newAccessToken, refreshToken: newRefreshToken);
      }
      return response;
    }
    return <String, dynamic>{};
  }

  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {}
    await _client.clearTokens();
  }

  // ---------------------------------------------------------------------------
  // 2. USER PROFILE & ADDRESSES APIS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getUserProfile() async {
    final response = await _client.get(ApiConstants.userProfile);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    final response = await _client.put(ApiConstants.userProfile, body: data);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<List<dynamic>> getUserAllergies() async {
    final response = await _client.get(ApiConstants.userAllergies);
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> saveUserAllergies(List<Map<String, dynamic>> payload) async {
    final response = await _client.post(ApiConstants.userAllergies, body: payload);
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  Future<dynamic> updateUserAllergies(dynamic data) async {
    if (data is List<Map<String, dynamic>>) {
      return await saveUserAllergies(data);
    }
    return await _client.post(ApiConstants.userAllergies, body: data);
  }

  Future<List<dynamic>> getUserAddresses() async {
    final response = await _client.get(ApiConstants.userAddresses);
    return response is List ? response : <dynamic>[];
  }

  Future<Map<String, dynamic>> addUserAddress({
    required String tag,
    required String addressLine,
    String? landmark,
    String? city,
    String? pincode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    final body = <String, dynamic>{
      'addressType': tag.toUpperCase(), // HOME, OFFICE, OTHER
      'addressLine': addressLine,
      'landmark': landmark ?? '',
      'city': city ?? 'Indore',
      'pincode': pincode ?? '452001',
      'isDefault': isDefault,
    };
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;

    final response = await _client.post(ApiConstants.userAddresses, body: body);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<void> deleteUserAddress(String addressId) async {
    await _client.delete('${ApiConstants.userAddresses}/$addressId');
  }

  Future<void> setDefaultAddress(String addressId) async {
    await _client.patch('${ApiConstants.userAddresses}/$addressId/default');
  }

  // ---------------------------------------------------------------------------
  // 3. MENU & SCHEDULE APIS
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getDailyMenu({
    String? kitchenId,
    String? menuDate,
    String? slot,
    String? planId,
  }) async {
    final query = <String, dynamic>{};
    if (kitchenId != null && kitchenId.isNotEmpty) query['kitchenId'] = kitchenId;
    if (menuDate != null && menuDate.isNotEmpty) query['menuDate'] = menuDate;
    if (slot != null && slot.isNotEmpty && slot != 'BOTH' && slot != '--') {
      query['slot'] = slot.toUpperCase();
    }
    if (planId != null && planId.isNotEmpty) query['planId'] = planId;

    final response = await _client.get(
      ApiConstants.menuDaily,
      queryParams: query.isEmpty ? null : query,
    );
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  /// Get daily menus typed model list.
  /// Note: As requested, planId and kitchenId are NOT sent in the query parameters.
  Future<List<DailyMenuResponseModel>> getDailyMenusTyped({
    String? menuDate,
    String? slot,
  }) async {
    // Ensure token is loaded from storage before making the request
    if (!_client.isAuthenticated) {
      await _client.init();
    }

    final query = <String, dynamic>{};
    if (menuDate != null && menuDate.isNotEmpty) query['menuDate'] = menuDate;
    if (slot != null && slot.isNotEmpty && slot != 'BOTH' && slot != '--') {
      query['slot'] = slot.toUpperCase();
    }
    // planId and kitchenId are strictly omitted

    final response = await _client.get(
      ApiConstants.menuDaily,
      queryParams: query.isEmpty ? null : query,
    );

    final List<dynamic> list;
    if (response is List) {
      list = response;
    } else if (response is Map<String, dynamic> && response['data'] is List) {
      list = response['data'] as List<dynamic>;
    } else {
      list = <dynamic>[];
    }

    return list
        .whereType<Map<String, dynamic>>()
        .map((e) => DailyMenuResponseModel.fromJson(e))
        .toList();
  }

  Future<List<dynamic>> getWeeklyMenu({
    required String startDate,
    required String endDate,
    String? kitchenId,
    String? planId,
    String? slot,
  }) async {
    final query = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
    };
    if (kitchenId != null) query['kitchenId'] = kitchenId;
    if (planId != null) query['planId'] = planId;
    if (slot != null) query['slot'] = slot;

    final response = await _client.get(ApiConstants.menuWeekly, queryParams: query);
    return response is List ? response : <dynamic>[];
  }

  Future<List<dynamic>> getNext7DaysMenu({String? kitchenId, String? slot}) async {
    final query = <String, dynamic>{};
    if (kitchenId != null) query['kitchenId'] = kitchenId;
    if (slot != null) query['slot'] = slot;

    final response = await _client.get(ApiConstants.menuNext7Days, queryParams: query);
    return response is List ? response : <dynamic>[];
  }

  // ---------------------------------------------------------------------------
  // 4. SUBSCRIPTION APIS
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getSubscriptionPlans({String? kitchenId, String? mealSlot}) async {
    final query = <String, dynamic>{
      'isActive': true,
    };
    if (kitchenId != null) query['kitchenId'] = kitchenId;
    if (mealSlot != null) query['mealSlot'] = mealSlot;

    final response = await _client.get(ApiConstants.subscriptionPlans, queryParams: query);
    return response is List ? response : <dynamic>[];
  }

  Future<List<dynamic>> getMySubscriptions() async {
    final response = await _client.get(ApiConstants.mySubscriptions);
    return response is List ? response : <dynamic>[];
  }

  Future<Map<String, dynamic>> subscribeToPlan({
    required String planId,
    required String startDate,
    required String mealSlot,           // LUNCH, DINNER, BOTH
    String? deliveryAddressId,
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final body = <String, dynamic>{
      'planId': planId,
      'startDate': startDate,
      'paymentMode': 'RAZORPAY',
      'deliveryAddressId': deliveryAddressId ?? '',
      'razorpayOrderId': razorpayOrderId ?? '',
      'razorpayPaymentId': razorpayPaymentId ?? '',
      'razorpaySignature': razorpaySignature ?? '',
    };
    final response = await _client.post(ApiConstants.subscribe, body: body);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  /// Step 1 of Razorpay flow: Create a Razorpay order on the backend.
  /// Returns orderId, amountInPaise, keyId, customerName, customerPhone, etc.
  Future<Map<String, dynamic>> createRazorpayOrder({required String planId}) async {
    if (!_client.isAuthenticated) await _client.init();
    final response = await _client.post(
      ApiConstants.razorpayOrder,
      body: {'planId': planId},
    );
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  /// 1-Click Pause Meal with automatic wallet refund
  Future<Map<String, dynamic>> pauseMeal({
    required String startDate,
    required String endDate,
    List<String>? mealSlots,
    String? reason,
  }) async {
    final body = <String, dynamic>{
      'startDate': startDate,
      'endDate': endDate,
      'mealSlots': mealSlots ?? ['LUNCH', 'DINNER'],
      'reason': reason ?? 'Customer requested meal pause',
    };
    final response = await _client.post(ApiConstants.pauseMeal, body: body);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  // ---------------------------------------------------------------------------
  // 5. ORDERS & LIVE CUSTOMIZATION APIS
  // ---------------------------------------------------------------------------

  /// Submit meal customization — POST /api/v1/orders/customize
  /// Payload matches the API contract exactly:
  /// { kitchenId, deliveryDate, slot, orderType, deliveryAddressId,
  ///   categorySelections: [{ categoryId, categoryCode, itemIds, quantity }],
  ///   specialInstructions }
  Future<Map<String, dynamic>> placeOrCustomizeOrder(Map<String, dynamic> orderPayload) async {
    // Ensure token is loaded before submitting
    if (!_client.isAuthenticated) {
      await _client.init();
    }
    final response = await _client.post(ApiConstants.customizeOrder, body: orderPayload);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<List<dynamic>> getMyOrders() async {
    final response = await _client.get(ApiConstants.myOrders);
    return response is List ? response : <dynamic>[];
  }

  Future<Map<String, dynamic>> getOrderTracking(String orderId) async {
    final response = await _client.get('/orders/$orderId/track');
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<void> cancelOrder(String orderId, {String? reason}) async {
    await _client.post(
      '/orders/$orderId/cancel',
      body: {'reason': reason ?? 'Cancelled by user'},
    );
  }

  // ---------------------------------------------------------------------------
  // 6. FLEXI-WALLET APIS
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> getWalletSummary() async {
    final response = await _client.get(ApiConstants.walletSummary);
    return response is Map<String, dynamic> ? response : <String, dynamic>{};
  }

  Future<void> rechargeWallet({
    required double amount,
    String? paymentReference,
  }) async {
    final body = {
      'amount': amount,
      'paymentReference': paymentReference ?? 'APP-TOPUP-${DateTime.now().millisecondsSinceEpoch}',
    };
    await _client.post(ApiConstants.walletRecharge, body: body);
  }

  // ---------------------------------------------------------------------------
  // 7. KITCHEN DISCOVERY
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getActiveKitchens() async {
    final response = await _client.get(ApiConstants.kitchens);
    return response is List ? response : <dynamic>[];
  }

  // ---------------------------------------------------------------------------
  // 8. CATEGORIES & ALLERGY ITEMS
  // ---------------------------------------------------------------------------

  Future<List<dynamic>> getCategories() async {
    final response = await _client.get(ApiConstants.categories);
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }

  Future<List<dynamic>> getCategoryItems(String categoryId) async {
    final response = await _client.get(ApiConstants.categoryItems(categoryId));
    if (response is List) return response;
    if (response is Map<String, dynamic> && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }
    return <dynamic>[];
  }
}
