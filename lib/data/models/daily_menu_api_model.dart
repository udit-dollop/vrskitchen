class CategoryMenuItemModel {
  final String id;
  final String name;
  final String categoryId;
  final String categoryName;
  final String categoryCode;
  final String dietaryTag; // VEG, NON_VEG, JAIN
  final double extraPrice;
  final String description;
  final String imageUrl;

  const CategoryMenuItemModel({
    required this.id,
    required this.name,
    this.categoryId = '',
    this.categoryName = '',
    this.categoryCode = '',
    this.dietaryTag = 'VEG',
    this.extraPrice = 0.0,
    this.description = '',
    this.imageUrl = '',
  });

  factory CategoryMenuItemModel.fromJson(Map<String, dynamic> json) {
    return CategoryMenuItemModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      categoryCode: json['categoryCode']?.toString() ?? '',
      dietaryTag: (json['dietaryTag']?.toString() ?? 'VEG').toUpperCase(),
      extraPrice: (json['extraPrice'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'dietaryTag': dietaryTag,
      'extraPrice': extraPrice,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}

class CategoryMenuModel {
  final String categoryId;
  final String categoryName;
  final String categoryCode;
  final int allowedCount;
  final bool isQuantityBased;
  final List<CategoryMenuItemModel> defaultItems;
  final List<CategoryMenuItemModel> availableOptions;

  const CategoryMenuModel({
    required this.categoryId,
    required this.categoryName,
    this.categoryCode = '',
    this.allowedCount = 1,
    this.isQuantityBased = false,
    this.defaultItems = const [],
    this.availableOptions = const [],
  });

  factory CategoryMenuModel.fromJson(Map<String, dynamic> json) {
    final defaultList = (json['defaultItems'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => CategoryMenuItemModel.fromJson(e))
            .toList() ??
        const [];

    final optionsList = (json['availableOptions'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => CategoryMenuItemModel.fromJson(e))
            .toList() ??
        const [];

    final isQty = json['isQuantityBased'] == true;
    final rawAllowed = (json['allowedCount'] as num?)?.toInt() ?? 0;
    final allowed = rawAllowed > 0 ? rawAllowed : (isQty ? 5 : 1);

    return CategoryMenuModel(
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      categoryCode: json['categoryCode']?.toString() ?? '',
      allowedCount: allowed,
      isQuantityBased: isQty,
      defaultItems: defaultList,
      availableOptions: optionsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryCode': categoryCode,
      'allowedCount': allowedCount,
      'isQuantityBased': isQuantityBased,
      'defaultItems': defaultItems.map((e) => e.toJson()).toList(),
      'availableOptions': availableOptions.map((e) => e.toJson()).toList(),
    };
  }

  /// Returns combined list of unique items from availableOptions and defaultItems
  List<CategoryMenuItemModel> get allItems {
    final Map<String, CategoryMenuItemModel> map = {};
    for (var item in availableOptions) {
      final key = item.id.isNotEmpty ? item.id : item.name;
      map[key] = item;
    }
    for (var item in defaultItems) {
      final key = item.id.isNotEmpty ? item.id : item.name;
      if (!map.containsKey(key)) {
        map[key] = item;
      }
    }
    if (map.isEmpty) {
      return [...defaultItems, ...availableOptions];
    }
    return map.values.toList();
  }
}

class DailyMenuResponseModel {
  final String id;
  final String kitchenId;
  final String kitchenName;
  final String planName;
  final String planId;
  final String menuDate;
  final String slot; // LUNCH, DINNER, BOTH
  final String cutOffTime;
  final String status; // OPEN, CLOSED
  final List<CategoryMenuModel> categoryMenus;

  const DailyMenuResponseModel({
    required this.id,
    this.kitchenId = '',
    this.kitchenName = '',
    this.planName = '',
    this.planId = '',
    this.menuDate = '',
    this.slot = 'LUNCH',
    this.cutOffTime = '',
    this.status = 'OPEN',
    this.categoryMenus = const [],
  });

  factory DailyMenuResponseModel.fromJson(Map<String, dynamic> json) {
    final catList = (json['categoryMenus'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map((e) => CategoryMenuModel.fromJson(e))
            .toList() ??
        const [];

    return DailyMenuResponseModel(
      id: json['id']?.toString() ?? '',
      kitchenId: json['kitchenId']?.toString() ?? '',
      kitchenName: json['kitchenName']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      menuDate: json['menuDate']?.toString() ?? '',
      slot: (json['slot']?.toString() ?? 'LUNCH').toUpperCase(),
      cutOffTime: json['cutOffTime']?.toString() ?? '',
      status: (json['status']?.toString() ?? 'OPEN').toUpperCase(),
      categoryMenus: catList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kitchenId': kitchenId,
      'kitchenName': kitchenName,
      'planName': planName,
      'planId': planId,
      'menuDate': menuDate,
      'slot': slot,
      'cutOffTime': cutOffTime,
      'status': status,
      'categoryMenus': categoryMenus.map((e) => e.toJson()).toList(),
    };
  }

  bool get isOpen {
    if (status != 'OPEN') return false;
    final dt = cutOffDateTime;
    if (dt != null && DateTime.now().isAfter(dt)) {
      return false;
    }
    return true;
  }

  DateTime? get cutOffDateTime {
    if (cutOffTime.isEmpty) return null;
    return DateTime.tryParse(cutOffTime)?.toLocal();
  }

  String get formattedCutOff {
    final dt = cutOffDateTime;
    if (dt == null) return cutOffTime;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}
