import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../state/app_state_provider.dart';

class _AllergyCategory {
  final String id;
  final String name;
  final String? code;
  final String icon;
  final Color bgColor;

  const _AllergyCategory({
    required this.id,
    required this.name,
    this.code,
    required this.icon,
    required this.bgColor,
  });

  factory _AllergyCategory.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? 'Category';
    final code = json['code']?.toString();
    return _AllergyCategory(
      id: json['id']?.toString() ?? '',
      name: name,
      code: code,
      icon: _getCategoryIcon(name, code),
      bgColor: _getCategoryColor(name, code),
    );
  }
}

class _FoodAllergyItem {
  final String id;
  final String name;
  final String categoryId;
  final String subtitle;
  final String? imageUrl;
  final String icon;
  final Color bgColor;
  final String? dietaryTag;
  final double extraPrice;

  const _FoodAllergyItem({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.subtitle,
    this.imageUrl,
    required this.icon,
    required this.bgColor,
    this.dietaryTag,
    this.extraPrice = 0,
  });

  factory _FoodAllergyItem.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? '';
    final categoryName = json['categoryName']?.toString();
    final description = json['description']?.toString() ?? '';
    final subtitle = description.isNotEmpty
        ? description
        : (categoryName != null && categoryName.isNotEmpty
            ? "Common ${categoryName.toLowerCase()}"
            : "Common food allergen");
    final imgUrl = json['imageUrl']?.toString();
    final extraPrice = (json['extraPrice'] as num?)?.toDouble() ?? 0.0;
    final dietaryTag = json['dietaryTag']?.toString();

    return _FoodAllergyItem(
      id: json['id']?.toString() ?? '',
      name: name,
      categoryId: json['categoryId']?.toString() ?? '',
      subtitle: subtitle,
      imageUrl: imgUrl != null && imgUrl.isNotEmpty ? imgUrl : null,
      icon: _getItemIcon(name, categoryName),
      bgColor: _getItemColor(name),
      dietaryTag: dietaryTag,
      extraPrice: extraPrice,
    );
  }
}

String _getCategoryIcon(String name, String? code) {
  final lower = ('$name ${code ?? ""}').toLowerCase();
  if (lower.contains("veg")) return "🥦";
  if (lower.contains("rice") || lower.contains("chawal")) return "🍚";
  if (lower.contains("grain") || lower.contains("wheat") || lower.contains("bread") || lower.contains("roti")) {
    return "🌾";
  }
  if (lower.contains("dairy") || lower.contains("milk") || lower.contains("paneer")) return "🥛";
  if (lower.contains("nut") || lower.contains("peanut") || lower.contains("dry fruit")) return "🥜";
  if (lower.contains("seafood") || lower.contains("fish")) return "🐟";
  if (lower.contains("fruit")) return "🍎";
  if (lower.contains("spice") || lower.contains("masala")) return "🌶️";
  if (lower.contains("sweet") || lower.contains("dessert")) return "🍨";
  if (lower.contains("drink") || lower.contains("beverage")) return "🧃";
  return "🍽️";
}

Color _getCategoryColor(String name, String? code) {
  final lower = ('$name ${code ?? ""}').toLowerCase();
  if (lower.contains("veg")) return const Color(0xFFE8F5E9);
  if (lower.contains("rice")) return const Color(0xFFFFF8E1);
  if (lower.contains("grain") || lower.contains("wheat")) return const Color(0xFFFFF3E0);
  if (lower.contains("dairy") || lower.contains("milk")) return const Color(0xFFE1F5FE);
  if (lower.contains("nut")) return const Color(0xFFEFEBE9);
  if (lower.contains("seafood") || lower.contains("fish")) return const Color(0xFFE0F7FA);
  if (lower.contains("fruit")) return const Color(0xFFFFEBEE);
  if (lower.contains("spice")) return const Color(0xFFFFEBEE);
  return const Color(0xFFF3E5F5);
}

String _getItemIcon(String name, String? categoryName) {
  final lower = ('$name ${categoryName ?? ""}').toLowerCase();
  if (lower.contains("potato") || lower.contains("aloo")) return "🥔";
  if (lower.contains("tomato") || lower.contains("tamatar")) return "🍅";
  if (lower.contains("onion") || lower.contains("pyaz") || lower.contains("pyaaz")) return "🧅";
  if (lower.contains("brinjal") || lower.contains("eggplant") || lower.contains("baingan")) return "🍆";
  if (lower.contains("cauliflower") || lower.contains("gobhi") || lower.contains("gobi") || lower.contains("broccoli")) {
    return "🥦";
  }
  if (lower.contains("carrot") || lower.contains("gajar")) return "🥕";
  if (lower.contains("garlic") || lower.contains("lahsun")) return "🧄";
  if (lower.contains("ginger") || lower.contains("adrak")) return "🫚";
  if (lower.contains("capsicum") || lower.contains("shimla") || lower.contains("pepper")) return "🫑";
  if (lower.contains("mushroom")) return "🍄";
  if (lower.contains("paneer")) return "🧀";
  if (lower.contains("milk") || lower.contains("doodh")) return "🥛";
  if (lower.contains("curd") || lower.contains("dahi") || lower.contains("yogurt")) return "🍶";
  if (lower.contains("ghee") || lower.contains("butter") || lower.contains("makhan")) return "🧈";
  if (lower.contains("cheese")) return "🧀";
  if (lower.contains("peanut") || lower.contains("mungfali") || lower.contains("groundnut")) return "🥜";
  if (lower.contains("cashew") || lower.contains("kaju")) return "🌰";
  if (lower.contains("almond") || lower.contains("badam")) return "🌰";
  if (lower.contains("walnut") || lower.contains("akhrot")) return "🌰";
  if (lower.contains("sesame") || lower.contains("til")) return "⚪";
  if (lower.contains("wheat") || lower.contains("atta") || lower.contains("maida") || lower.contains("roti") || lower.contains("gluten")) {
    return "🍞";
  }
  if (lower.contains("barley") || lower.contains("jau")) return "🌾";
  if (lower.contains("oat")) return "🥣";
  if (lower.contains("corn") || lower.contains("makka") || lower.contains("maize")) return "🌽";
  if (lower.contains("soy")) return "🫘";
  if (lower.contains("rice") || lower.contains("chawal") || lower.contains("pulao") || lower.contains("biryani")) {
    return "🍚";
  }
  if (lower.contains("fish") || lower.contains("machli")) return "🐟";
  if (lower.contains("prawn") || lower.contains("shrimp")) return "🦐";
  if (lower.contains("crab")) return "🦀";
  if (lower.contains("egg") || lower.contains("anda")) return "🥚";
  if (lower.contains("mango") || lower.contains("aam")) return "🥭";
  if (lower.contains("lemon") || lower.contains("nimbu") || lower.contains("citrus")) return "🍋";
  if (lower.contains("banana") || lower.contains("kela")) return "🍌";
  if (lower.contains("pineapple") || lower.contains("ananas")) return "🍍";
  if (lower.contains("strawberry")) return "🍓";
  if (lower.contains("mustard") || lower.contains("sarson") || lower.contains("rai")) return "🟡";
  if (lower.contains("chilli") || lower.contains("mirch") || lower.contains("paprika")) return "🌶️";
  if (lower.contains("fenugreek") || lower.contains("methi")) return "🌿";
  if (lower.contains("dal") || lower.contains("lentil")) return "🥣";
  return "🥗";
}

Color _getItemColor(String name) {
  final lower = name.toLowerCase();
  if (lower.contains("tomato") || lower.contains("chilli") || lower.contains("strawberry")) {
    return const Color(0xFFFFEBEE);
  }
  if (lower.contains("onion") || lower.contains("brinjal")) return const Color(0xFFF3E5F5);
  if (lower.contains("carrot") || lower.contains("orange")) return const Color(0xFFFFF3E0);
  if (lower.contains("cauliflower") || lower.contains("capsicum") || lower.contains("methi")) {
    return const Color(0xFFE8F5E9);
  }
  if (lower.contains("potato") || lower.contains("corn") || lower.contains("mustard") || lower.contains("lemon")) {
    return const Color(0xFFFFFDE7);
  }
  if (lower.contains("milk") || lower.contains("curd") || lower.contains("fish")) {
    return const Color(0xFFE1F5FE);
  }
  if (lower.contains("paneer") || lower.contains("cheese") || lower.contains("butter") || lower.contains("rice")) {
    return const Color(0xFFFFF8E1);
  }
  return const Color(0xFFFAFAFA);
}

class DietarySetupScreen extends StatefulWidget {
  final ApiService? apiService;
  const DietarySetupScreen({super.key, this.apiService});

  @override
  State<DietarySetupScreen> createState() => _DietarySetupScreenState();
}

class _DietarySetupScreenState extends State<DietarySetupScreen> {
  late final ApiService _apiService;

  bool _isLoadingCategories = true;
  bool _isLoadingItems = false;
  bool _isLoadingUserAllergies = true;
  bool _isSaving = false;
  bool _isInit = false;

  String? _selectedCategoryId;
  String _selectedCategoryName = "";

  List<_AllergyCategory> _categoriesList = [];
  List<_FoodAllergyItem> _currentItems = [];
  final Map<String, List<_FoodAllergyItem>> _categoryItemsCache = {};

  final Set<String> _selectedItemIds = {};
  final Set<String> _selectedItemNames = {};
  final Map<String, String> _itemToCategory = {};
  final Map<String, String> _itemToName = {};
  final Map<String, String> _itemToCategoryName = {};
  final Map<String, String> _itemToNote = {};

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserAllergies(),
      _loadCategories(),
    ]);
  }

  Future<void> _loadUserAllergies() async {
    setState(() => _isLoadingUserAllergies = true);
    try {
      final list = await _apiService.getUserAllergies();
      if (list.isNotEmpty && mounted) {
        for (var catRaw in list) {
          if (catRaw is Map<String, dynamic>) {
            final catId = catRaw['categoryId']?.toString() ?? '';
            final catName = catRaw['categoryName']?.toString() ?? '';
            final itemsList = catRaw['items'];
            if (itemsList is List) {
              for (var itemRaw in itemsList) {
                if (itemRaw is Map<String, dynamic>) {
                  final menuItemId = itemRaw['menuItemId']?.toString() ?? itemRaw['id']?.toString() ?? '';
                  final itemName = itemRaw['itemName']?.toString() ?? itemRaw['name']?.toString() ?? '';
                  final itemCatId = itemRaw['categoryId']?.toString() ?? catId;
                  final itemCatName = itemRaw['categoryName']?.toString() ?? catName;
                  final note = itemRaw['note']?.toString() ?? '';

                  if (menuItemId.isNotEmpty) {
                    _selectedItemIds.add(menuItemId);
                    if (itemCatId.isNotEmpty) {
                      _itemToCategory[menuItemId] = itemCatId;
                    }
                    if (itemCatName.isNotEmpty) {
                      _itemToCategoryName[menuItemId] = itemCatName;
                    }
                    if (note.isNotEmpty) {
                      _itemToNote[menuItemId] = note;
                    }
                  }
                  if (itemName.isNotEmpty) {
                    _selectedItemNames.add(itemName);
                    if (menuItemId.isNotEmpty) {
                      _itemToName[menuItemId] = itemName;
                    }
                  }
                }
              }
            }
          }
        }
        if (mounted) {
          final appState = Provider.of<AppStateProvider>(context, listen: false);
          if (_selectedItemNames.isNotEmpty) {
            appState.updateUserProfile(
              allergies: _selectedItemNames.toList(),
            );
          }
          setState(() {
            _isLoadingUserAllergies = false;
          });
        }
      } else if (mounted) {
        setState(() {
          _isLoadingUserAllergies = false;
        });
      }
    } catch (_) {
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        final existingAllergies = appState.user.allergies;
        if (existingAllergies.isNotEmpty) {
          _selectedItemNames.addAll(
            existingAllergies.where((a) => a != "No Allergies" && a != "None"),
          );
        }
        setState(() {
          _isLoadingUserAllergies = false;
        });
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final list = await _apiService.getCategories();
      if (mounted) {
        final List<_AllergyCategory> categories = [];
        for (var raw in list) {
          if (raw is Map<String, dynamic>) {
            if (raw['isActive'] != false) {
              categories.add(_AllergyCategory.fromJson(raw));
            }
          }
        }

        setState(() {
          _categoriesList = categories;
          _isLoadingCategories = false;
          if (categories.isNotEmpty) {
            final first = categories.first;
            _selectedCategoryId = first.id;
            _selectedCategoryName = first.name;
          } else {
            _selectedCategoryId = null;
            _selectedCategoryName = "";
            _currentItems = [];
          }
        });

        if (categories.isNotEmpty) {
          await _loadItemsForCategory(categories.first.id, categories.first.name);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _categoriesList = [];
          _isLoadingCategories = false;
          _selectedCategoryId = null;
          _selectedCategoryName = "";
          _currentItems = [];
        });
      }
    }
  }

  Future<void> _loadItemsForCategory(String categoryId, String categoryName) async {
    if (_categoryItemsCache.containsKey(categoryId)) {
      setState(() {
        _currentItems = _categoryItemsCache[categoryId]!;
      });
      return;
    }

    setState(() => _isLoadingItems = true);

    try {
      final list = await _apiService.getCategoryItems(categoryId);
      if (mounted) {
        final List<_FoodAllergyItem> items = [];
        for (var raw in list) {
          if (raw is Map<String, dynamic>) {
            if (raw['isActive'] != false) {
              final item = _FoodAllergyItem.fromJson(raw);
              items.add(item);
              _itemToCategory[item.id] = item.categoryId;
              _itemToCategoryName[item.id] = categoryName;
              _itemToName[item.id] = item.name;
              if (_selectedItemNames.contains(item.name)) {
                _selectedItemIds.add(item.id);
              } else if (_selectedItemIds.contains(item.id)) {
                _selectedItemNames.add(item.name);
              }
            }
          }
        }

        _categoryItemsCache[categoryId] = items;
        setState(() {
          _currentItems = items;
          _isLoadingItems = false;
        });
      }
    } catch (_) {
      if (mounted) {
        _categoryItemsCache[categoryId] = [];
        setState(() {
          _currentItems = [];
          _isLoadingItems = false;
        });
      }
    }
  }

  void _onCategorySelected(_AllergyCategory category) {
    if (_selectedCategoryId == category.id && !_isLoadingItems) return;
    setState(() {
      _selectedCategoryId = category.id;
      _selectedCategoryName = category.name;
    });
    _loadItemsForCategory(category.id, category.name);
  }

  void _toggleAllergy(_FoodAllergyItem item) {
    setState(() {
      final isSelected = _selectedItemIds.contains(item.id) || _selectedItemNames.contains(item.name);
      if (isSelected) {
        _selectedItemIds.remove(item.id);
        _selectedItemNames.remove(item.name);
        _itemToCategory.remove(item.id);
        _itemToName.remove(item.id);
        _itemToCategoryName.remove(item.id);
        _itemToNote.remove(item.id);
      } else {
        _selectedItemIds.add(item.id);
        _selectedItemNames.add(item.name);
        _itemToCategory[item.id] = item.categoryId;
        _itemToName[item.id] = item.name;
        _itemToCategoryName[item.id] = _selectedCategoryName;
      }
    });
  }

  Future<void> _onSaveAllergies() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    // Group selected menuItemIds by categoryId
    final Map<String, List<String>> categoryToItemIds = {};
    for (final itemId in _selectedItemIds) {
      final catId = _itemToCategory[itemId] ?? _selectedCategoryId ?? '';
      if (catId.isNotEmpty) {
        categoryToItemIds.putIfAbsent(catId, () => []).add(itemId);
      }
    }

    final List<Map<String, dynamic>> payload = [];
    categoryToItemIds.forEach((catId, menuItemIds) {
      payload.add({
        'categoryId': catId,
        'menuItemIds': menuItemIds,
        'note': 'Severe allergy / cannot eat',
      });
    });

    try {
      await _apiService.saveUserAllergies(payload);
    } catch (_) {}

    if (!mounted) return;

    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final allergiesToSave = _selectedItemNames.isEmpty
        ? <String>["No Allergies"]
        : _selectedItemNames.toList();

    appState.updateUserProfile(
      allergies: allergiesToSave,
    );

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _selectedItemNames.isEmpty
              ? "Allergies updated: No Allergies recorded"
              : "Saved ${_selectedItemNames.length} food allergies successfully",
        ),
        backgroundColor: AppColors.vegGreen,
        duration: const Duration(seconds: 2),
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayedItems = _currentItems;

    return Scaffold(
      backgroundColor: AppColors.backgroundWarm,
      body: SafeArea(
        child: Column(
          children: [
            // Top Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.space20,
                  vertical: AppDimens.space12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Back Button
                    GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
                        }
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceWhite,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.navyPrimary,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.space16),

                    // 2. Header Row with Title & Salad Bowl Banner
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Food Allergies",
                                style: AppTypography.displayMedium.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.navyPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Select the foods you are allergic to so we can provide you a safer and better experience.",
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                "assets/images/food_allergies_banner.png",
                                width: 110,
                                height: 110,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite.withValues(alpha: 0.95),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.vegGreen.withValues(alpha: 0.3)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "Eat Safe\nLive Healthy",
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.vegGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8.5,
                                        height: 1.1,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    const Icon(
                                      Icons.favorite_rounded,
                                      color: AppColors.spicyRed,
                                      size: 11,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.space16),

                    // 2.5 Active/Recorded Allergies Section
                    _buildActiveAllergiesSection(),

                    const SizedBox(height: AppDimens.space24),

                    // 3. Category Selector Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select Category",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        if (!_isLoadingCategories && _categoriesList.isNotEmpty)
                          Text(
                            "${_categoriesList.length} categories",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.space12),

                    // Horizontal Category Cards
                    _isLoadingCategories
                        ? Container(
                            height: 88,
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.vegGreen,
                              ),
                            ),
                          )
                        : _categoriesList.isEmpty
                            ? Container(
                                height: 88,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                                    const SizedBox(width: 8),
                                    Text(
                                      "No categories loaded",
                                      style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: _loadCategories,
                                      child: const Text(
                                        "Retry",
                                        style: TextStyle(
                                          color: AppColors.vegGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : SizedBox(
                                height: 88,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _categoriesList.length,
                                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                                  itemBuilder: (context, index) {
                                    final category = _categoriesList[index];
                                    final isSelected = _selectedCategoryId == category.id;

                                    return GestureDetector(
                                      onTap: () => _onCategorySelected(category),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: 78,
                                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFE8F5E9) : AppColors.surfaceWhite,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected ? AppColors.vegGreen : AppColors.borderLight,
                                            width: isSelected ? 1.8 : 1.0,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: AppColors.vegGreen.withValues(alpha: 0.12),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ]
                                              : [
                                                  BoxShadow(
                                                    color: Colors.black.withValues(alpha: 0.02),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: category.bgColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    category.icon,
                                                    style: TextStyle(
                                                      fontSize: category.icon.length > 2 ? 14 : 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.navyPrimary,
                                                    ),
                                                  ),
                                                ),
                                                if (_selectedItemIds.where((id) => _itemToCategory[id] == category.id).isNotEmpty)
                                                  Positioned(
                                                    top: -3,
                                                    right: -3,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.vegGreen,
                                                        borderRadius: BorderRadius.circular(10),
                                                        border: Border.all(color: Colors.white, width: 1.5),
                                                      ),
                                                      child: Text(
                                                        "${_selectedItemIds.where((id) => _itemToCategory[id] == category.id).length}",
                                                        style: const TextStyle(
                                                          fontSize: 8.5,
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.white,
                                                          height: 1,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              category.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                              style: AppTypography.caption.copyWith(
                                                fontSize: 11,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                color: isSelected ? AppColors.vegGreen : AppColors.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                    const SizedBox(height: AppDimens.space24),

                    // 4. Items List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedCategoryName.isNotEmpty
                              ? "$_selectedCategoryName Items"
                              : "Category Items",
                          style: AppTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyPrimary,
                          ),
                        ),
                        if (!_isLoadingItems && displayedItems.isNotEmpty)
                          Text(
                            "${displayedItems.length} items",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: AppDimens.space12),

                    // 5. Items Cards List
                    _isLoadingItems
                        ? Container(
                            height: 160,
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.vegGreen,
                                  ),
                                ),
                                SizedBox(height: 12),
                                Text(
                                  "Fetching category items...",
                                  style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                                ),
                              ],
                            ),
                          )
                        : displayedItems.isEmpty
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimens.space24,
                                  vertical: AppDimens.space32,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceWhite,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF3F4F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.restaurant_menu_rounded,
                                        color: AppColors.textMuted,
                                        size: 28,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      _selectedCategoryName.isNotEmpty
                                          ? "No items in $_selectedCategoryName"
                                          : "No items available",
                                      style: AppTypography.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "This category does not have any items listed yet.",
                                      textAlign: TextAlign.center,
                                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: displayedItems.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final item = displayedItems[index];
                              final isChecked = _selectedItemIds.contains(item.id) || _selectedItemNames.contains(item.name);

                              return GestureDetector(
                                onTap: () => _toggleAllergy(item),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppDimens.space14,
                                    vertical: AppDimens.space10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isChecked
                                          ? AppColors.vegGreen.withValues(alpha: 0.5)
                                          : AppColors.borderLight,
                                      width: isChecked ? 1.5 : 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Food visual badge
                                      item.imageUrl != null && item.imageUrl!.startsWith('http')
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: Image.network(
                                                item.imageUrl!,
                                                width: 52,
                                                height: 52,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => _buildFallbackBadge(item),
                                                loadingBuilder: (context, child, progress) {
                                                  if (progress == null) return child;
                                                  return Container(
                                                    width: 52,
                                                    height: 52,
                                                    alignment: Alignment.center,
                                                    child: const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: AppColors.vegGreen,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : _buildFallbackBadge(item),
                                      const SizedBox(width: AppDimens.space14),

                                      // Title and Subtitle
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: AppTypography.titleSmall.copyWith(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15,
                                                color: AppColors.navyPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              item.subtitle,
                                              style: AppTypography.caption.copyWith(
                                                color: AppColors.textMuted,
                                                fontSize: 12,
                                              ),
                                            ),
                                            if (isChecked) ...[
                                              const SizedBox(height: 5),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE8F5E9),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.check_circle_rounded, size: 11, color: AppColors.vegGreen),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "Recorded Allergy",
                                                      style: AppTypography.caption.copyWith(
                                                        color: AppColors.vegGreen,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Custom Rounded Checkbox
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: isChecked ? AppColors.vegGreen : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isChecked ? AppColors.vegGreen : const Color(0xFFD1D5DB),
                                            width: 1.8,
                                          ),
                                        ),
                                        child: isChecked
                                            ? const Icon(
                                                Icons.check_rounded,
                                                color: Colors.white,
                                                size: 17,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: AppDimens.space24),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar (Matching Design)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space16,
                vertical: AppDimens.space14,
              ),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left: Leaf icon with text
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_rounded,
                          color: AppColors.vegGreen,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Allergies help us",
                            style: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navyPrimary,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            "personalize your experience",
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Right: Save Allergies (X) Button
                  ElevatedButton(
                    onPressed: _onSaveAllergies,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vegGreen,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppColors.vegGreen.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedItemNames.isEmpty
                              ? "Save Allergies"
                              : "Save Allergies (${_selectedItemNames.length})",
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackBadge(_FoodAllergyItem item) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: item.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.borderLight.withValues(alpha: 0.6),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        item.icon,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }

  Widget _buildActiveAllergiesSection() {
    if (_isLoadingUserAllergies) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.vegGreen,
              ),
            ),
            SizedBox(width: 12),
            Text(
              "Loading your recorded allergies...",
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    final totalCount = _selectedItemNames.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.space14),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: totalCount > 0
              ? AppColors.vegGreen.withValues(alpha: 0.3)
              : AppColors.borderLight,
          width: totalCount > 0 ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: totalCount > 0
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      totalCount > 0
                          ? Icons.verified_user_rounded
                          : Icons.shield_outlined,
                      size: 17,
                      color: totalCount > 0
                          ? AppColors.vegGreen
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Your Recorded Allergies",
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navyPrimary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: totalCount > 0
                                  ? AppColors.vegGreen.withValues(alpha: 0.12)
                                  : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$totalCount",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: totalCount > 0
                                    ? AppColors.vegGreen
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        totalCount > 0
                            ? "Excluded from all your daily meals"
                            : "No food allergies recorded yet",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: _loadUserAllergies,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWarm,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  if (totalCount > 0) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedItemIds.clear();
                          _selectedItemNames.clear();
                          _itemToCategory.clear();
                          _itemToName.clear();
                          _itemToCategoryName.clear();
                          _itemToNote.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.spicyRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Clear All",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.spicyRed,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Chips / Content
          if (totalCount > 0) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedItemNames.map((name) {
                final icon = _getItemIcon(name, null);
                final itemId = _selectedItemIds.firstWhere(
                  (id) => _itemToName[id] == name,
                  orElse: () => '',
                );
                final catId = itemId.isNotEmpty ? _itemToCategory[itemId] : null;
                final catName = itemId.isNotEmpty ? _itemToCategoryName[itemId] : null;

                return InkWell(
                  onTap: catId != null && catId.isNotEmpty
                      ? () {
                          final catMatch = _categoriesList.where((c) => c.id == catId);
                          if (catMatch.isNotEmpty) {
                            _onCategorySelected(catMatch.first);
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.vegGreen.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(icon, style: const TextStyle(fontSize: 13)),
                        const SizedBox(width: 5),
                        Text(
                          name,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.navyPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        if (catName != null && catName.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppColors.vegGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              catName,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.vegGreen,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItemNames.remove(name);
                              if (itemId.isNotEmpty) {
                                _selectedItemIds.remove(itemId);
                                _itemToCategory.remove(itemId);
                                _itemToName.remove(itemId);
                                _itemToCategoryName.remove(itemId);
                                _itemToNote.remove(itemId);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 11,
                              color: AppColors.navyPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_itemToNote.values.any((n) => n.trim().isNotEmpty)) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFF57F17)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Kitchen Note: ${_itemToNote.values.firstWhere((n) => n.trim().isNotEmpty)}",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5D4037),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ] else ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined, size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Tap any item from the categories below to record it as an allergy restriction.",
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 10.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
