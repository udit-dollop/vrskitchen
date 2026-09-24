import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/ui_helpers.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/vrs_app_bar.dart';
import '../../../core/widgets/vrs_button.dart';
import '../../../core/widgets/vrs_card.dart';
import '../../../data/models/daily_menu_api_model.dart';
import '../../../state/app_state_provider.dart';

class MealCustomizerScreen extends StatefulWidget {
  final ApiService? apiService;
  final String? initialSlot;
  final String? menuDate; // yyyy-MM-dd format, e.g. "2026-09-25"

  const MealCustomizerScreen({
    super.key,
    this.apiService,
    this.initialSlot,
    this.menuDate,
  });

  @override
  State<MealCustomizerScreen> createState() => _MealCustomizerScreenState();
}

class _MealCustomizerScreenState extends State<MealCustomizerScreen> {
  late final ApiService _apiService;

  bool _isLoading = true;
  String? _errorMessage;
  List<DailyMenuResponseModel> _dailyMenus = [];
  String _activeSlot = 'LUNCH';

  // Selections per category
  // For non-quantity based categories: categoryId -> selected item id
  final Map<String, String> _singleSelections = {};

  // For quantity based categories: "${categoryId}_${itemId}" -> quantity
  final Map<String, int> _quantitySelections = {};

  // Track if saving
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    if (widget.initialSlot != null && widget.initialSlot!.isNotEmpty) {
      _activeSlot = widget.initialSlot!.toUpperCase();
    }
    _loadDailyMenu();
  }

  DailyMenuResponseModel? get _currentMenu {
    if (_dailyMenus.isEmpty) return null;
    final match = _dailyMenus.firstWhere(
      (m) => m.slot.toUpperCase() == _activeSlot.toUpperCase(),
      orElse: () => _dailyMenus.first,
    );
    return match;
  }

  Future<void> _loadDailyMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the date passed from the calendar, or fall back to today
      final String dateStr;
      if (widget.menuDate != null && widget.menuDate!.isNotEmpty) {
        dateStr = widget.menuDate!;
      } else {
        final now = DateTime.now();
        dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      }

      // Fetch LUNCH and DINNER in parallel — slot param matches API's expected values
      var results = await Future.wait([
        _apiService.getDailyMenusTyped(menuDate: dateStr, slot: 'LUNCH'),
        _apiService.getDailyMenusTyped(menuDate: dateStr, slot: 'DINNER'),
      ]);
      final menus = [...results[0], ...results[1]];

      if (mounted) {
        setState(() {
          _dailyMenus = menus;
          _isLoading = false;
        });

        if (menus.isNotEmpty) {
          // Keep _activeSlot if it exists in response, else fall back to first
          if (!menus.any((m) => m.slot.toUpperCase() == _activeSlot)) {
            _activeSlot = menus.first.slot.toUpperCase();
          }

          // Auto-switch: if current slot is CLOSED but another slot is OPEN, switch to it
          final currentMenu = menus.firstWhere(
            (m) => m.slot.toUpperCase() == _activeSlot,
            orElse: () => menus.first,
          );
          if (!currentMenu.isOpen) {
            final openMenu = menus.where((m) => m.isOpen).toList();
            if (openMenu.isNotEmpty) {
              _activeSlot = openMenu.first.slot.toUpperCase();
            }
          }

          _initializeSelectionsForCurrentMenu();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Called when user taps Lunch/Dinner tab — fetches that slot fresh from API
  Future<void> _switchSlot(String slot) async {
    if (_activeSlot == slot) return;

    setState(() {
      _activeSlot = slot;
    });

    // Check if we already have this slot's data loaded
    final alreadyLoaded = _dailyMenus.any((m) => m.slot.toUpperCase() == slot);
    if (alreadyLoaded) {
      setState(() {
        _initializeSelectionsForCurrentMenu();
      });
      return;
    }

    // Slot not yet loaded — fetch it now
    setState(() => _isLoading = true);

    try {
      final String dateStr;
      if (widget.menuDate != null && widget.menuDate!.isNotEmpty) {
        dateStr = widget.menuDate!;
      } else {
        final now = DateTime.now();
        dateStr =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      }

      var slotMenus = await _apiService.getDailyMenusTyped(menuDate: dateStr, slot: slot);

      if (mounted) {
        setState(() {
          // Merge: remove any old entry for this slot and add fresh data
          _dailyMenus = [
            ..._dailyMenus.where((m) => m.slot.toUpperCase() != slot),
            ...slotMenus,
          ];
          _isLoading = false;
          _initializeSelectionsForCurrentMenu();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _initializeSelectionsForCurrentMenu() {
    final menu = _currentMenu;
    if (menu == null) return;

    for (var cat in menu.categoryMenus) {
      if (cat.isQuantityBased) {
        // Quantity-based items: initialize default items with count 1
        for (var item in cat.allItems) {
          final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
          final isDefault = cat.defaultItems.any((d) =>
              (d.id.isNotEmpty && d.id == item.id) ||
              (d.name.isNotEmpty && d.name == item.name));
          if (!_quantitySelections.containsKey(key)) {
            _quantitySelections[key] = isDefault ? 1 : 0;
          }
        }
      } else {
        // Single selection per category
        if (!_singleSelections.containsKey(cat.categoryId)) {
          if (cat.defaultItems.isNotEmpty) {
            final defaultItem = cat.defaultItems.first;
            _singleSelections[cat.categoryId] =
                defaultItem.id.isNotEmpty ? defaultItem.id : defaultItem.name;
          } else if (cat.availableOptions.isNotEmpty) {
            final firstOption = cat.availableOptions.first;
            _singleSelections[cat.categoryId] =
                firstOption.id.isNotEmpty ? firstOption.id : firstOption.name;
          }
        }
      }
    }
  }

  double _calculateExtraPrice() {
    final menu = _currentMenu;
    if (menu == null) return 0.0;

    double extra = 0.0;
    for (var cat in menu.categoryMenus) {
      if (cat.isQuantityBased) {
        for (var item in cat.allItems) {
          final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
          final qty = _quantitySelections[key] ?? 0;
          if (qty > 0 && item.extraPrice > 0) {
            extra += item.extraPrice * qty;
          }
        }
      } else {
        final selectedId = _singleSelections[cat.categoryId];
        if (selectedId != null) {
          final selectedItem = cat.allItems.firstWhere(
            (it) => (it.id.isNotEmpty && it.id == selectedId) || it.name == selectedId,
            orElse: () => const CategoryMenuItemModel(id: '', name: ''),
          );
          if (selectedItem.extraPrice > 0) {
            extra += selectedItem.extraPrice;
          }
        }
      }
    }
    return extra;
  }

  int _getCategoryTotalQty(CategoryMenuModel cat) {
    int total = 0;
    for (var item in cat.allItems) {
      final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
      total += _quantitySelections[key] ?? 0;
    }
    return total;
  }

  Future<void> _confirmCustomization() async {
    final menu = _currentMenu;
    if (menu == null) return;

    if (!menu.isOpen) {
      UiHelpers.showErrorSnackbar(
        context,
        "Customization for this meal slot is closed. Cut-off time has passed.",
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Build categorySelections as per API contract:
      // [{ categoryId, categoryCode, itemIds: [id], quantity }]
      final categorySelections = _buildCategorySelectionsPayload(menu);

      // deliveryDate: extract date portion from menuDate (yyyy-MM-dd)
      final String deliveryDate;
      if (menu.menuDate.isNotEmpty) {
        deliveryDate = menu.menuDate.length >= 10
            ? menu.menuDate.substring(0, 10)
            : menu.menuDate;
      } else if (widget.menuDate != null && widget.menuDate!.isNotEmpty) {
        deliveryDate = widget.menuDate!;
      } else {
        final now = DateTime.now();
        deliveryDate =
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      }

      final payload = <String, dynamic>{
        'kitchenId': menu.kitchenId,
        'deliveryDate': deliveryDate,
        'slot': menu.slot,               // LUNCH or DINNER
        'orderType': 'SUBSCRIPTION_MEAL',
        'deliveryAddressId': '',
        'categorySelections': categorySelections,
        'specialInstructions': '',
      };

      await _apiService.placeOrCustomizeOrder(payload);

      // Sync local AppStateProvider for UI display consistency
      _syncAppState(menu);

      if (mounted) {
        UiHelpers.showSuccessSnackbar(
          context,
          "Meal customized successfully! Kitchen has received your preferences.",
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.showErrorSnackbar(
          context,
          "Failed to save customization. Please try again.",
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Builds categorySelections payload matching API contract:
  /// [{ categoryId, categoryCode, itemIds: [id1], quantity }]
  /// - Single-select → itemIds has 1 item, quantity = 1
  /// - Quantity-based → one entry per item with qty > 0
  List<Map<String, dynamic>> _buildCategorySelectionsPayload(DailyMenuResponseModel menu) {
    final list = <Map<String, dynamic>>[];

    for (final cat in menu.categoryMenus) {
      if (cat.isQuantityBased) {
        for (final item in cat.allItems) {
          final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
          final qty = _quantitySelections[key] ?? 0;
          if (qty > 0) {
            list.add({
              'categoryId': cat.categoryId,
              'categoryCode': cat.categoryCode,
              'itemIds': [item.id],
              'quantity': qty,
            });
          }
        }
      } else {
        final selectedKey = _singleSelections[cat.categoryId];
        if (selectedKey != null) {
          final selectedItem = cat.allItems.firstWhere(
            (it) => (it.id.isNotEmpty && it.id == selectedKey) || it.name == selectedKey,
            orElse: () => const CategoryMenuItemModel(id: '', name: ''),
          );
          if (selectedItem.id.isNotEmpty) {
            list.add({
              'categoryId': cat.categoryId,
              'categoryCode': cat.categoryCode,
              'itemIds': [selectedItem.id],
              'quantity': 1,
            });
          }
        }
      }
    }
    return list;
  }

  /// Syncs selected item names into AppStateProvider for local UI display
  void _syncAppState(DailyMenuResponseModel menu) {
    String sabziName = '';
    String rotiName = '';
    String riceName = '';
    final activeAddons = <String, int>{};

    for (final cat in menu.categoryMenus) {
      final lowerCat = cat.categoryName.toLowerCase();
      if (cat.isQuantityBased) {
        for (final item in cat.allItems) {
          final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
          final qty = _quantitySelections[key] ?? 0;
          if (qty > 0) activeAddons[item.name] = qty;
        }
      } else {
        final selectedKey = _singleSelections[cat.categoryId];
        if (selectedKey == null) continue;
        final selectedItem = cat.allItems.firstWhere(
          (it) => (it.id.isNotEmpty && it.id == selectedKey) || it.name == selectedKey,
          orElse: () => const CategoryMenuItemModel(id: '', name: ''),
        );
        if (selectedItem.name.isEmpty) continue;
        if (lowerCat.contains('sabzi') || lowerCat.contains('vegetable') || lowerCat.contains('curry')) {
          sabziName = selectedItem.name;
        } else if (lowerCat.contains('roti') || lowerCat.contains('bread') || lowerCat.contains('paratha')) {
          rotiName = selectedItem.name;
        } else if (lowerCat.contains('rice') || lowerCat.contains('pulao') || lowerCat.contains('biryani')) {
          riceName = selectedItem.name;
        } else {
          activeAddons[selectedItem.name] = 1;
        }
      }
    }

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.updateMealCustomization(
      sabzi: sabziName.isNotEmpty ? sabziName : appState.selectedSabzi,
      roti: rotiName.isNotEmpty ? rotiName : appState.selectedRoti,
      rice: riceName.isNotEmpty ? riceName : appState.selectedRice,
      addOns: activeAddons,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      appBar: const VrsAppBar(title: "Customize Your Meal", showBack: true),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.goldPrimary),
      );
    }

    if (_errorMessage != null && _dailyMenus.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: "Unable to Load Menu",
          subtitle: "Please check your network connection and try again.",
          buttonText: "Retry",
          onButtonPressed: _loadDailyMenu,
        ),
      );
    }

    if (_dailyMenus.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadDailyMenu,
        color: AppColors.goldPrimary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            EmptyStateWidget(
              icon: Icons.restaurant_menu_rounded,
              title: "No Daily Menu Available",
              subtitle: "Today's meal menu has not been published yet. Please pull down to refresh.",
              buttonText: "Refresh Menu",
              onButtonPressed: _loadDailyMenu,
            ),
          ],
        ),
      );
    }

    final menu = _currentMenu;
    if (menu == null) {
      return const SizedBox.shrink();
    }

    final extraCharges = _calculateExtraPrice();

    return Column(
      children: [
        // Cut-Off Banner
        _buildCutoffBanner(menu),

        // Slot Tabs (if multiple slots available or Lunch & Dinner)
        _buildSlotSelector(),

        // Dynamic Menu Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadDailyMenu,
            color: AppColors.goldPrimary,
            child: ListView(
              padding: const EdgeInsets.all(AppDimens.space16),
              children: [
                // Header with Kitchen info & Plan
                _buildHeaderCard(menu),
                const SizedBox(height: AppDimens.space16),

                // Category menus dynamically generated from API response
                ...menu.categoryMenus.asMap().entries.map((entry) {
                  final index = entry.key + 1;
                  final cat = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppDimens.space16),
                    child: _buildCategorySection(index, cat, menu.isOpen),
                  );
                }),

                const SizedBox(height: AppDimens.space40),
              ],
            ),
          ),
        ),

        // Sticky Bottom Summary Bar
        _buildBottomStickyBar(menu, extraCharges),
      ],
    );
  }

  Widget _buildCutoffBanner(DailyMenuResponseModel menu) {
    final isOpen = menu.isOpen;
    final cutoffText = menu.formattedCutOff.isNotEmpty ? menu.formattedCutOff : "cut-off time";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.space16, vertical: 9),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.goldBackground : const Color(0xFFFEE2E2),
        border: Border(
          bottom: BorderSide(
            color: isOpen ? AppColors.goldPrimary.withValues(alpha: 0.3) : const Color(0xFFFCA5A5),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isOpen ? Icons.access_time_rounded : Icons.lock_clock_rounded,
            size: 16,
            color: isOpen ? AppColors.navyDark : AppColors.nonVegRed,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isOpen
                  ? "Customization closes at $cutoffText. Changes are instant."
                  : "Customization for this slot is CLOSED ($cutoffText passed).",
              style: AppTypography.caption.copyWith(
                color: isOpen ? AppColors.navyDark : AppColors.nonVegRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotSelector() {
    // Always show both tabs regardless of what API returned
    const slotsToDisplay = ['LUNCH', 'DINNER'];

    return Container(
      margin: const EdgeInsets.fromLTRB(AppDimens.space16, AppDimens.space12, AppDimens.space16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: AppDimens.borderMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: slotsToDisplay.map((slot) {
          final isSelected = _activeSlot == slot;
          final isLunch = slot == 'LUNCH';
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchSlot(slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.navyPrimary : Colors.transparent,
                  borderRadius: AppDimens.borderSM,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.navyPrimary.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isLunch ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded,
                      size: 16,
                      color: isSelected ? AppColors.goldPrimary : AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLunch ? "Lunch Menu" : "Dinner Menu",
                      style: AppTypography.titleSmall.copyWith(
                        color: isSelected ? Colors.white : AppColors.textDark,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeaderCard(DailyMenuResponseModel menu) {
    return VrsCard(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.goldBackground,
              borderRadius: AppDimens.borderMD,
            ),
            child: const Icon(Icons.restaurant_rounded, color: AppColors.goldDark, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.planName.isNotEmpty ? menu.planName : "Daily Meal Thali",
                  style: AppTypography.headingSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  menu.kitchenName.isNotEmpty
                      ? "Kitchen: ${menu.kitchenName}"
                      : "Homestyle Fresh Preparation",
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: menu.isOpen ? AppColors.vegGreen.withValues(alpha: 0.12) : const Color(0xFFFEE2E2),
              borderRadius: AppDimens.borderFull,
              border: Border.all(
                color: menu.isOpen ? AppColors.vegGreen : AppColors.nonVegRed,
                width: 1,
              ),
            ),
            child: Text(
              menu.isOpen ? "OPEN" : "CLOSED",
              style: AppTypography.caption.copyWith(
                color: menu.isOpen ? AppColors.vegGreen : AppColors.nonVegRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(int index, CategoryMenuModel cat, bool isMenuOpen) {
    final items = cat.allItems;
    final isQtyBased = cat.isQuantityBased;

    String subtitle;
    if (isQtyBased) {
      final currentQty = _getCategoryTotalQty(cat);
      subtitle = cat.allowedCount > 0
          ? "Selected: $currentQty (Allowed up to ${cat.allowedCount})"
          : "Add items as per your preference";
    } else {
      subtitle = "Select 1 option (Included in meal)";
    }

    return VrsCard(
      padding: const EdgeInsets.all(AppDimens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getCategoryIcon(cat.categoryName), size: 20, color: AppColors.goldDark),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$index. ${cat.categoryName}",
                      style: AppTypography.headingSmall,
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.space16),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "No options available for this category.",
                style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic),
              ),
            )
          else
            ...items.map((item) {
              if (isQtyBased) {
                return _buildQuantityTile(cat, item, isMenuOpen);
              } else {
                return _buildSingleChoiceTile(cat, item, isMenuOpen);
              }
            }),
        ],
      ),
    );
  }

  Widget _buildSingleChoiceTile(CategoryMenuModel cat, CategoryMenuItemModel item, bool isMenuOpen) {
    final itemKey = item.id.isNotEmpty ? item.id : item.name;
    final isSelected = _singleSelections[cat.categoryId] == itemKey;

    return InkWell(
      onTap: isMenuOpen
          ? () {
              setState(() {
                _singleSelections[cat.categoryId] = itemKey;
              });
            }
          : null,
      borderRadius: AppDimens.borderMD,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(AppDimens.space12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.goldBackground : AppColors.surfaceWhite,
          borderRadius: AppDimens.borderMD,
          border: Border.all(
            color: isSelected ? AppColors.goldPrimary : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            _buildDietaryIndicator(item.dietaryTag),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? AppColors.navyDark : AppColors.textDark,
                          ),
                        ),
                      ),
                      if (item.extraPrice > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.goldBackground,
                            borderRadius: AppDimens.borderSM,
                            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            "+ ₹${item.extraPrice.toInt()}",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.goldDark,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (item.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppColors.goldDark : AppColors.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityTile(CategoryMenuModel cat, CategoryMenuItemModel item, bool isMenuOpen) {
    final key = "${cat.categoryId}_${item.id.isNotEmpty ? item.id : item.name}";
    final qty = _quantitySelections[key] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: qty > 0 ? AppColors.goldBackground : AppColors.backgroundLight,
        borderRadius: AppDimens.borderMD,
        border: Border.all(
          color: qty > 0 ? AppColors.goldPrimary : AppColors.borderLight,
          width: qty > 0 ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          _buildDietaryIndicator(item.dietaryTag),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navyPrimary,
                  ),
                ),
                Row(
                  children: [
                    if (item.extraPrice > 0)
                      Text(
                        "+ ₹${item.extraPrice.toInt()} each",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.goldDark,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        "Included in plan",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.vegGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (isMenuOpen)
            Row(
              children: [
                if (qty > 0) ...[
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      size: 22,
                      color: AppColors.navyPrimary,
                    ),
                    onPressed: () {
                      setState(() {
                        _quantitySelections[key] = qty - 1;
                      });
                    },
                  ),
                  Text(
                    "$qty",
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
                IconButton(
                  icon: const Icon(Icons.add_circle, size: 24, color: AppColors.goldDark),
                  onPressed: () {
                    // Check limit if allowedCount is set
                    final currentCatTotal = _getCategoryTotalQty(cat);
                    if (cat.allowedCount > 0 && currentCatTotal >= cat.allowedCount && item.extraPrice <= 0) {
                      UiHelpers.showInfoSnackbar(
                        context,
                        "Maximum allowed quantity for ${cat.categoryName} is ${cat.allowedCount}.",
                      );
                      return;
                    }
                    setState(() {
                      _quantitySelections[key] = qty + 1;
                    });
                  },
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                "Qty: $qty",
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDietaryIndicator(String tag) {
    final upper = tag.toUpperCase();
    final isVeg = upper == 'VEG';
    final isJain = upper == 'JAIN';
    final color = isVeg
        ? AppColors.vegGreen
        : (isJain ? const Color(0xFFD97706) : AppColors.nonVegRed);

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('sabzi') || lower.contains('vegetable') || lower.contains('curry')) {
      return Icons.eco_rounded;
    } else if (lower.contains('roti') || lower.contains('bread') || lower.contains('paratha')) {
      return Icons.circle_outlined;
    } else if (lower.contains('rice') || lower.contains('biryani') || lower.contains('pulao')) {
      return Icons.grain_rounded;
    } else if (lower.contains('dal') || lower.contains('soup')) {
      return Icons.soup_kitchen_rounded;
    } else if (lower.contains('sweet') || lower.contains('dessert') || lower.contains('halwa')) {
      return Icons.cake_rounded;
    } else if (lower.contains('salad') || lower.contains('raita') || lower.contains('curd')) {
      return Icons.local_dining_rounded;
    }
    return Icons.lunch_dining_rounded;
  }

  Widget _buildBottomStickyBar(DailyMenuResponseModel menu, double extraCharges) {
    final isOpen = menu.isOpen;

    return Container(
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
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  extraCharges > 0 ? "Extra Charges" : "Included in Plan",
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                Text(
                  extraCharges > 0 ? UiHelpers.formatCurrency(extraCharges) : "₹0 Extra",
                  style: AppTypography.priceTag.copyWith(
                    color: extraCharges > 0 ? AppColors.goldDark : AppColors.vegGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppDimens.space20),
            Expanded(
              child: VrsButton(
                text: _isSubmitting
                    ? "Saving..."
                    : (isOpen ? "Confirm Meal" : "Customization Closed"),
                onPressed: (isOpen && !_isSubmitting) ? _confirmCustomization : null,
                variant: isOpen ? VrsButtonVariant.gold : VrsButtonVariant.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
