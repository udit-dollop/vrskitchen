import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_badge.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/add_on_model.dart';
import '../../../data/models/subscription_model.dart';
import '../../../data/models/user_model.dart';
import '../../../state/app_state_provider.dart';

class SubscriptionAddonsScreen extends StatefulWidget {
  const SubscriptionAddonsScreen({super.key});

  @override
  State<SubscriptionAddonsScreen> createState() => _SubscriptionAddonsScreenState();
}

class _SubscriptionAddonsScreenState extends State<SubscriptionAddonsScreen> {
  final Map<String, int> _addonQuantities = {};
  bool _isProcessing = false;

  // Razorpay
  late final Razorpay _razorpay;
  Map<String, dynamic>? _pendingArgs;
  double _pendingTotal = 0;
  String? _pendingPlanId;
  String? _pendingStartDate;
  String? _pendingSlot;
  String? _pendingRazorpayOrderId;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      if (appState.availableAddOns.isEmpty) {
        appState.syncAddOns();
      }
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  double _calculateAddonsTotal(List<AddOnItem> addons, int mealsCount) {
    double total = 0;
    for (var a in addons) {
      final qty = _addonQuantities[a.id] ?? 0;
      total += qty * a.price * mealsCount;
    }
    return total;
  }

  /// Entry point — validate profile & address before opening Razorpay
  Future<void> _onSubscribe(Map<String, dynamic> args, double grandTotal) async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Sync latest profile & addresses from backend first
    if (appState.apiClient.isAuthenticated) {
      await appState.syncUserProfile();
      await appState.syncAddresses();
    }

    final user = appState.user;
    final bool profileComplete = user.name.trim().isNotEmpty && user.email.trim().isNotEmpty;
    final bool hasAddress = user.addresses.isNotEmpty;

    if (!profileComplete) {
      // Step 1: Ask user to complete profile
      final completed = await _showProfileSetupSheet();
      if (!completed) return; // user dismissed
    }

    if (!hasAddress) {
      // Step 2: Ask user to add address
      final added = await _showAddressSetupSheet();
      if (!added) return; // user dismissed
    }

    // All checks passed — proceed with payment
    await _startPayment(args, grandTotal);
  }

  /// Bottom sheet to collect Name + Email
  Future<bool> _showProfileSetupSheet() async {
    final nameCtrl = TextEditingController(
      text: Provider.of<AppStateProvider>(context, listen: false).user.name,
    );
    final emailCtrl = TextEditingController(
      text: Provider.of<AppStateProvider>(context, listen: false).user.email,
    );
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text("Complete Your Profile", style: AppTypography.headingSmall),
                const SizedBox(height: 6),
                Text(
                  "We need your name and email to activate the subscription.",
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(borderRadius: AppDimens.borderMD),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Name is required" : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(borderRadius: AppDimens.borderMD),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Email is required";
                    if (!v.contains('@') || !v.contains('.')) return "Enter a valid email";
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.navyPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMD),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final appState = Provider.of<AppStateProvider>(ctx, listen: false);
                        appState.updateUserProfile(
                          name: nameCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                        );
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: Text("Save & Continue", style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    return result == true;
  }

  /// Bottom sheet to add a delivery address
  Future<bool> _showAddressSetupSheet() async {
    final tagCtrl = TextEditingController(text: "Home");
    final addrCtrl = TextEditingController();
    final landCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.goldBackground,
                        borderRadius: AppDimens.borderSM,
                      ),
                      child: const Icon(Icons.location_on_rounded, color: AppColors.goldDark, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text("Add Delivery Address", style: AppTypography.headingSmall),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Where should we deliver your daily meals?",
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: tagCtrl,
                  decoration: InputDecoration(
                    labelText: "Label (Home / Office / Other)",
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    border: OutlineInputBorder(borderRadius: AppDimens.borderMD),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: addrCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: "Street & Building Address",
                    prefixIcon: const Icon(Icons.home_outlined),
                    border: OutlineInputBorder(borderRadius: AppDimens.borderMD),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Address is required" : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: landCtrl,
                  decoration: InputDecoration(
                    labelText: "Landmark & City",
                    prefixIcon: const Icon(Icons.place_outlined),
                    border: OutlineInputBorder(borderRadius: AppDimens.borderMD),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldDark,
                      foregroundColor: AppColors.navyDark,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMD),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final appState = Provider.of<AppStateProvider>(ctx, listen: false);
                        appState.addAddress(AddressModel(
                          id: "ADDR_${DateTime.now().millisecondsSinceEpoch % 100000}",
                          tag: tagCtrl.text.trim().isEmpty ? "Home" : tagCtrl.text.trim(),
                          addressLine: addrCtrl.text.trim(),
                          landmark: landCtrl.text.trim(),
                        ));
                        Navigator.pop(ctx, true);
                      }
                    },
                    child: Text("Save Address & Continue", style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
    return result == true;
  }

  /// Step 1: Create Razorpay order on backend, then open Razorpay checkout
  Future<void> _startPayment(Map<String, dynamic> args, double grandTotal) async {    setState(() => _isProcessing = true);

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final packageType = args["packageType"] as PackageType? ?? PackageType.standard;
    final meals = (args["meals"] as int?) ?? 30;
    final slot = (args["slot"] as String?) ?? "Lunch";
    final planId = args["planId"]?.toString();

    // Store for use in payment callbacks
    _pendingArgs = args;
    _pendingTotal = grandTotal;
    _pendingPlanId = planId;
    _pendingSlot = slot;
    final now = DateTime.now();
    _pendingStartDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    try {
      if (appState.apiClient.isAuthenticated && planId != null && planId.isNotEmpty) {
        // Step 1: Get Razorpay order details from backend
        final orderData = await appState.apiService.createRazorpayOrder(planId: planId);

        _pendingRazorpayOrderId = orderData['orderId']?.toString();

        final String? keyId = orderData['keyId']?.toString();
        // Razorpay SDK requires amount strictly as int (paise)
        final int amountInPaise = (orderData['amountInPaise'] as num?)?.toInt() ?? 0;

        if (keyId == null || keyId.isEmpty) {
          throw Exception("Invalid payment configuration received from server.");
        }
        if (amountInPaise <= 0) {
          throw Exception("Invalid payment amount received from server.");
        }

        // Step 2: Open Razorpay checkout
        final options = <String, dynamic>{
          'key': keyId,
          'amount': amountInPaise,
          'currency': orderData['currency']?.toString() ?? 'INR',
          'name': 'VRS Kitchen',
          'description': orderData['description']?.toString() ?? 'Meal Subscription',
          'order_id': orderData['orderId']?.toString() ?? '',
          'prefill': {
            'contact': orderData['customerPhone']?.toString() ?? '',
            'email': orderData['customerEmail']?.toString() ?? '',
            'name': orderData['customerName']?.toString() ?? '',
          },
          'theme': {'color': '#1A2340'},
        };

        setState(() => _isProcessing = false);
        _razorpay.open(options);
      } else {
        // Not authenticated — activate locally (demo/offline mode)
        appState.activateSubscription(
          packageType: packageType,
          mealsCount: meals,
          price: grandTotal,
          slot: slot,
        );
        setState(() => _isProcessing = false);
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.subscriptionSuccess);
        }
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Payment error: ${e.toString().replaceAll('Exception: ', '')}"),
            backgroundColor: AppColors.nonVegRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Step 3: Payment succeeded — verify with backend and activate subscription
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() => _isProcessing = true);

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final packageType = _pendingArgs?["packageType"] as PackageType? ?? PackageType.standard;
    final meals = (_pendingArgs?["meals"] as int?) ?? 30;

    try {
      await appState.apiService.subscribeToPlan(
        planId: _pendingPlanId ?? '',
        startDate: _pendingStartDate ?? '',
        mealSlot: (_pendingSlot ?? 'LUNCH').toUpperCase().contains('BOTH')
            ? 'BOTH'
            : ((_pendingSlot ?? '').toUpperCase().contains('DINNER') ? 'DINNER' : 'LUNCH'),
        razorpayOrderId: response.orderId ?? _pendingRazorpayOrderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
      );
      await appState.syncSubscriptions();
    } catch (_) {
      // Even if verification call fails, activate locally so UX isn't broken
      appState.activateSubscription(
        packageType: packageType,
        mealsCount: meals,
        price: _pendingTotal,
        slot: _pendingSlot ?? 'Lunch',
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
        Navigator.pushReplacementNamed(context, AppRoutes.subscriptionSuccess);
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (mounted) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.message?.isNotEmpty == true
                ? "Payment failed: ${response.message}"
                : "Payment was cancelled.",
          ),
          backgroundColor: AppColors.nonVegRed,
        ),
      );
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // External wallet selected — nothing to do, Razorpay handles it
  }

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {
      "packageType": PackageType.standard,
      "meals": 30,
      "slot": "Lunch",
      "basePrice": 2400.0,
      "planName": "Subscription Plan",
    };

    final appState = Provider.of<AppStateProvider>(context);
    final availableAddOns = appState.availableAddOns;
    final basePrice = (args["basePrice"] as num?)?.toDouble() ?? 2400.0;
    final mealsCount = (args["meals"] as int?) ?? 30;
    final planName = args["planName"]?.toString() ?? (args['packageType'] == PackageType.standard ? 'Standard' : 'Premium');
    final addonsTotal = _calculateAddonsTotal(availableAddOns, mealsCount);
    final grandTotal = basePrice + addonsTotal;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Add-ons & Checkout", showBack: true),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppDimens.space16),
                children: [
                  // Plan info banner
                  Container(
                    padding: const EdgeInsets.all(AppDimens.space12),
                    decoration: BoxDecoration(
                      color: AppColors.goldBackground,
                      borderRadius: AppDimens.borderMD,
                      border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$planName • $mealsCount Meals (${args['slot']})",
                          style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "₹${basePrice.toInt()}",
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Monthly Add-ons", style: AppTypography.headingMedium),
                      if (availableAddOns.isNotEmpty)
                        Text("Per Meal Rate", style: AppTypography.caption),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Optional extras served with every meal for your entire $mealsCount meal cycle.",
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: AppDimens.space16),

                  // Addons List or Empty State
                  if (availableAddOns.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: AppDimens.borderMD,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.add_shopping_cart_rounded, size: 36, color: AppColors.textMuted),
                          const SizedBox(height: 8),
                          Text("No Add-ons Available", style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            "No additional desserts or sides published by the kitchen currently. You can proceed with your standard plan.",
                            style: AppTypography.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    ...availableAddOns.map((addon) {
                      final qty = _addonQuantities[addon.id] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(AppDimens.space12),
                        decoration: BoxDecoration(
                          color: qty > 0 ? AppColors.goldBackground : AppColors.surfaceWhite,
                          borderRadius: AppDimens.borderMD,
                          border: Border.all(
                            color: qty > 0 ? AppColors.goldPrimary : AppColors.borderLight,
                            width: qty > 0 ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            const VegBadge(size: 14),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    addon.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navyPrimary,
                                    ),
                                  ),
                                  Text(
                                    "₹${addon.price.toInt()} / meal • ₹${(addon.price * mealsCount).toInt()} for month",
                                    style: AppTypography.caption.copyWith(color: AppColors.goldDark, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                if (qty > 0) ...[
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                                    onPressed: () {
                                      setState(() => _addonQuantities[addon.id] = qty - 1);
                                    },
                                  ),
                                  Text(
                                    "$qty",
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: AppColors.goldDark, size: 24),
                                  onPressed: () {
                                    setState(() => _addonQuantities[addon.id] = qty + 1);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: AppDimens.space20),

                  // Delivery Address Card
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery Location", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          appState.user.selectedAddress?.addressLine.isNotEmpty == true
                              ? appState.user.selectedAddress!.addressLine
                              : (appState.user.addresses.isNotEmpty
                                  ? appState.user.addresses.first.addressLine
                                  : "Indore (Delivery address will be set at first delivery)"),
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space20),

                  // Total Bill Summary
                  VrsCard(
                    padding: const EdgeInsets.all(AppDimens.space16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Base Subscription", style: AppTypography.bodySmall),
                            Text("₹${basePrice.toInt()}", style: AppTypography.bodyMedium),
                          ],
                        ),
                        if (addonsTotal > 0) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Add-ons Total ($mealsCount Meals)", style: AppTypography.bodySmall),
                              Text("₹${addonsTotal.toInt()}", style: AppTypography.bodyMedium),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Delivery Charges", style: AppTypography.bodySmall),
                            Text("FREE", style: AppTypography.bodySmall.copyWith(color: AppColors.vegGreen, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Payable", style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                            Text(
                              "₹${grandTotal.toInt()}",
                              style: AppTypography.headingSmall.copyWith(
                                color: AppColors.navyPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimens.space32),
                ],
              ),
            ),

            // Sticky Bottom Subscribe CTA
            Container(
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: VrsButton(
                  text: "Pay ₹${grandTotal.toInt()} & Activate Plan",
                  isLoading: _isProcessing,
                  onPressed: () => _onSubscribe(args, grandTotal),
                  variant: VrsButtonVariant.gold,
                  icon: const Icon(Icons.verified_rounded, color: AppColors.navyDark, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
