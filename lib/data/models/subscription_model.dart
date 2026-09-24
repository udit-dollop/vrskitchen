enum PackageType { standard, premium }

class SubscriptionPackageModel {
  final String id;
  final PackageType type;
  final String title;
  final String subtitle;
  final int durationDays;
  final String mealSlot;
  final double basePrice;
  final double perMealPrice;
  final double trialPrice;
  final double price30Meals;
  final double price56Meals;
  final List<String> inclusions;
  final bool isPopular;

  const SubscriptionPackageModel({
    this.id = '',
    required this.type,
    required this.title,
    required this.subtitle,
    this.durationDays = 30,
    this.mealSlot = 'BOTH',
    this.basePrice = 2400.0,
    required this.perMealPrice,
    required this.trialPrice,
    required this.price30Meals,
    required this.price56Meals,
    required this.inclusions,
    this.isPopular = false,
  });

  double get pricePerMeal => perMealPrice;

  factory SubscriptionPackageModel.fromJson(Map<String, dynamic> json) {
    final name = json['name']?.toString() ?? 'Subscription Plan';
    final isPremium = name.toLowerCase().contains('premium') || name.toLowerCase().contains('deluxe');
    final pPrice = (json['pricePerMeal'] as num?)?.toDouble() ?? 40.0;
    final duration = (json['durationDays'] as num?)?.toInt() ?? 30;
    final bPrice = (json['basePrice'] as num?)?.toDouble() ?? (pPrice * duration);
    final slot = json['mealSlot']?.toString() ?? 'BOTH';

    List<String> incList = [];
    if (json['categoryQuotas'] is List) {
      for (var q in (json['categoryQuotas'] as List)) {
        if (q is Map) {
          final catName = q['categoryName']?.toString() ?? q['categoryCode']?.toString() ?? '';
          final count = q['allowedCount'] ?? 1;
          final itemsList = (q['availableItems'] is List)
              ? (q['availableItems'] as List).map((i) => i is Map ? i['name']?.toString() ?? '' : '').where((s) => s.isNotEmpty).toList()
              : <String>[];
          if (catName.isNotEmpty) {
            final itemsStr = itemsList.isNotEmpty ? ' (${itemsList.join(', ')})' : '';
            incList.add('$count x $catName$itemsStr');
          }
        }
      }
    }

    if (incList.isEmpty && json['description'] != null && json['description'].toString().isNotEmpty) {
      incList = json['description']
          .toString()
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return SubscriptionPackageModel(
      id: json['id']?.toString() ?? '',
      type: isPremium ? PackageType.premium : PackageType.standard,
      title: name,
      subtitle: json['description']?.toString() ?? 'Authentic homestyle cooking with zero commitment anxiety.',
      durationDays: duration,
      mealSlot: slot,
      basePrice: bPrice,
      perMealPrice: pPrice,
      trialPrice: pPrice,
      price30Meals: duration == 30 ? bPrice : (pPrice * 30),
      price56Meals: (pPrice * 56),
      inclusions: incList,
      isPopular: json['isPopular'] == true || isPremium,
    );
  }
}

class UserSubscriptionModel {
  final String id;
  final PackageType packageType;
  final int totalMeals;
  final int remainingMeals;
  final DateTime startDate;
  final DateTime expiryDate;
  final bool isActive;
  final bool isPaused;
  final String slot; // Lunch, Dinner, Both
  final double amountPaid;

  const UserSubscriptionModel({
    required this.id,
    required this.packageType,
    required this.totalMeals,
    required this.remainingMeals,
    required this.startDate,
    required this.expiryDate,
    this.isActive = true,
    this.isPaused = false,
    required this.slot,
    required this.amountPaid,
  });

  UserSubscriptionModel copyWith({
    int? remainingMeals,
    bool? isActive,
    bool? isPaused,
  }) {
    return UserSubscriptionModel(
      id: id,
      packageType: packageType,
      totalMeals: totalMeals,
      remainingMeals: remainingMeals ?? this.remainingMeals,
      startDate: startDate,
      expiryDate: expiryDate,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      slot: slot,
      amountPaid: amountPaid,
    );
  }
}
