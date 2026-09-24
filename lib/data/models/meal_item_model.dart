enum MealCategory { sabzi, dal, roti, rice, sweet, salad, addon }

class MealItemModel {
  final String id;
  final String name;
  final String description;
  final MealCategory category;
  final bool isVeg;
  final bool isJainAvailable;
  final double extraPrice; // For special items or addons
  final String imagePath;

  const MealItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.isVeg = true,
    this.isJainAvailable = true,
    this.extraPrice = 0.0,
    required this.imagePath,
  });
}
