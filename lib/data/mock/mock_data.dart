import '../models/user_model.dart';
import '../models/subscription_model.dart';
import '../models/meal_item_model.dart';
import '../models/daily_menu_model.dart';
import '../models/order_model.dart';
import '../models/add_on_model.dart';
import '../models/wallet_transaction_model.dart';
import '../models/kitchen_prep_model.dart';
import '../models/rider_delivery_model.dart';

class MockData {
  MockData._();

  // Primary Mock User
  static UserModel initialUser = const UserModel(
    id: "USR_101",
    name: "Rahul Sharma",
    phone: "+91 98765 43210",
    email: "rahul.sharma@example.com",
    dietaryPreference: "Veg",
    spiceLevel: "Medium",
    allergies: ["No Allergies"],
    selectedAddressId: "ADDR_1",
    addresses: [
      AddressModel(
        id: "ADDR_1",
        tag: "Office",
        addressLine: "Tech Park, 4th Floor, Vijay Nagar",
        landmark: "Near Brilliant Convention Centre, Indore",
        isDefault: true,
      ),
      AddressModel(
        id: "ADDR_2",
        tag: "Home",
        addressLine: "Flat 302, Silver Heights, Scheme 78",
        landmark: "Opposite Apollo Hospital, Indore",
        isDefault: false,
      ),
    ],
  );

  // Subscription Packages
  static const SubscriptionPackageModel standardPackage = SubscriptionPackageModel(
    type: PackageType.standard,
    title: "Standard Package",
    subtitle: "Ideal for people who prefer a balanced homestyle diet with all essentials.",
    perMealPrice: 80.0,
    trialPrice: 110.0,
    price30Meals: 2400.0,
    price56Meals: 4500.0,
    isPopular: true,
    inclusions: [
      "1 Veg Sabzi Variations",
      "1 Dal Variations",
      "5 Butter Roti",
      "1 Rice Variations",
      "Salad (subject to availability)",
    ],
  );

  static const SubscriptionPackageModel premiumPackage = SubscriptionPackageModel(
    type: PackageType.premium,
    title: "Premium Package",
    subtitle: "For those who want a royal meal experience packed with variety and dessert.",
    perMealPrice: 120.0,
    trialPrice: 150.0,
    price30Meals: 3600.0,
    price56Meals: 6700.0,
    isPopular: false,
    inclusions: [
      "1 Paneer / Special Sabzi",
      "1 Sabzi Variations",
      "1 Dal Variations",
      "5 Butter Roti",
      "1 Sweet",
      "Salad",
      "1 Surprise Item occasionally",
    ],
  );

  static List<SubscriptionPackageModel> get allPackages => [standardPackage, premiumPackage];

  // Active User Subscription
  static UserSubscriptionModel initialSubscription = UserSubscriptionModel(
    id: "SUB_VR_882",
    packageType: PackageType.standard,
    totalMeals: 30,
    remainingMeals: 20,
    startDate: DateTime.now().subtract(const Duration(days: 10)),
    expiryDate: DateTime.now().add(const Duration(days: 20)),
    slot: "Lunch",
    amountPaid: 2400.0,
  );

  // Addons matching menu
  static List<AddOnItem> get addOnsList => [
    AddOnItem(
      id: "addon_roti",
      name: "1 Extra Butter Roti",
      description: "Soft whole-wheat phulka with pure desi butter",
      price: 7.0,
      imagePath: "assets/images/thali_special.png",
    ),
    AddOnItem(
      id: "addon_paratha",
      name: "Tawa Paratha",
      description: "Crispy layered homestyle tawa paratha",
      price: 15.0,
      imagePath: "assets/images/thali_special.png",
    ),
    AddOnItem(
      id: "addon_sweet",
      name: "Sweet Variety (Gulab Jamun)",
      description: "Warm delicious gulab jamun (2 pcs)",
      price: 15.0,
      imagePath: "assets/images/thali_special.png",
    ),
    AddOnItem(
      id: "addon_dahi",
      name: "Dahi / Boondi Raita (150ml)",
      description: "Fresh churned curd with roasted cumin and boondi",
      price: 20.0,
      imagePath: "assets/images/thali_special.png",
    ),
    AddOnItem(
      id: "addon_papad",
      name: "Roasted Moong Papad",
      description: "Crisp seasoned lentil papad",
      price: 15.0,
      imagePath: "assets/images/thali_special.png",
    ),
    AddOnItem(
      id: "addon_namkeen",
      name: "Indori Namkeen / Sev",
      description: "Authentic spicy ratlami sev crunchy accompaniment",
      price: 15.0,
      imagePath: "assets/images/thali_special.png",
    ),
  ];

  // Meal Customizer Items
  static const List<MealItemModel> sabziOptions = [
    MealItemModel(
      id: "sbz_paneer",
      name: "Paneer Butter Masala",
      description: "Rich tomato cashew gravy with fresh cottage cheese cubes",
      category: MealCategory.sabzi,
      imagePath: "assets/images/thali_special.png",
    ),
    MealItemModel(
      id: "sbz_bhindi",
      name: "Bhindi Masala",
      description: "Homestyle stir-fried okra with aromatic onion-tomato spices",
      category: MealCategory.sabzi,
      imagePath: "assets/images/thali_special.png",
    ),
    MealItemModel(
      id: "sbz_mixveg",
      name: "Mix Veg Handi",
      description: "Carrots, peas, beans and florets in comforting yellow gravy",
      category: MealCategory.sabzi,
      imagePath: "assets/images/thali_special.png",
    ),
    MealItemModel(
      id: "sbz_aloogobhi",
      name: "Aloo Gobhi Adraki",
      description: "Tender potatoes and spiced cauliflower with ginger juliennes",
      category: MealCategory.sabzi,
      imagePath: "assets/images/thali_special.png",
    ),
  ];

  static const List<MealItemModel> rotiOptions = [
    MealItemModel(
      id: "roti_butter",
      name: "5 Butter Roti",
      description: "Soft whole wheat rotis topped with golden butter",
      category: MealCategory.roti,
      imagePath: "assets/images/thali_special.png",
    ),
    MealItemModel(
      id: "roti_tawa",
      name: "5 Plain Tawa Roti",
      description: "Oil-free light whole wheat phulkas straight from tawa",
      category: MealCategory.roti,
      imagePath: "assets/images/thali_special.png",
    ),
  ];

  static const List<MealItemModel> riceOptions = [
    MealItemModel(
      id: "rice_jeera",
      name: "Jeera Rice",
      description: "Fragrant basmati rice tempered with ghee and cumin seeds",
      category: MealCategory.rice,
      imagePath: "assets/images/thali_special.png",
    ),
    MealItemModel(
      id: "rice_steamed",
      name: "Steamed Plain Rice",
      description: "Fluffy light long-grain steamed white basmati rice",
      category: MealCategory.rice,
      imagePath: "assets/images/thali_special.png",
    ),
  ];

  // Weekly Menu
  static List<DailyMenuModel> generateWeeklyMenu() {
    final now = DateTime.now();
    final dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    final lunchSabzisList = [
      [sabziOptions[0], sabziOptions[1]], // Mon: Paneer + Bhindi
      [sabziOptions[1], sabziOptions[2]], // Tue: Bhindi + Mix Veg
      [sabziOptions[2], sabziOptions[3]], // Wed: Mix Veg + Aloo Gobhi
      [sabziOptions[3], sabziOptions[0]], // Thu: Aloo Gobhi + Paneer
      [sabziOptions[0], sabziOptions[2]], // Fri: Paneer + Mix Veg
      [sabziOptions[1], sabziOptions[3]], // Sat: Bhindi + Aloo Gobhi
      [sabziOptions[0], sabziOptions[1]], // Sun: Special Paneer + Bhindi
    ];

    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      return DailyMenuModel(
        date: date,
        dayName: dayNames[(date.weekday - 1) % 7],
        lunchSabzis: lunchSabzisList[index % 7],
        lunchDal: const MealItemModel(
          id: "dal_tadka",
          name: "Dal Tadka",
          description: "Yellow toor dal with aromatic garlic-jeera tadka",
          category: MealCategory.dal,
          imagePath: "assets/images/thali_special.png",
        ),
        lunchRotis: rotiOptions,
        lunchRice: riceOptions,
        lunchAddons: [addOnsList[2], addOnsList[3], addOnsList[4]],
        dinnerSabzis: lunchSabzisList[(index + 2) % 7],
        dinnerDal: const MealItemModel(
          id: "dal_fry",
          name: "Dal Fry",
          description: "Slow-cooked lentil curry with fresh herbs",
          category: MealCategory.dal,
          imagePath: "assets/images/thali_special.png",
        ),
        dinnerRotis: rotiOptions,
        dinnerRice: riceOptions,
        dinnerAddons: [addOnsList[2], addOnsList[3], addOnsList[5]],
      );
    });
  }

  // Initial Orders
  static List<OrderItemModel> initialOrders = [
    OrderItemModel(
      orderId: "VR10245",
      planName: "Standard Meal",
      date: DateTime.now(),
      slot: "Lunch (1:00 PM - 2:00 PM)",
      sabzi: "Paneer Butter Masala",
      dal: "Dal Tadka",
      roti: "5 Butter Roti",
      rice: "Jeera Rice",
      addOns: ["Green Salad", "Indori Sev"],
      amount: 80.0,
      status: OrderStatus.outForDelivery,
      deliveryAddress: "Tech Park, 4th Floor, Vijay Nagar, Indore",
      riderName: "Rajesh Kumar",
      riderPhone: "+91 98765 01234",
      estimatedMinutes: 18,
    ),
    OrderItemModel(
      orderId: "VR10240",
      planName: "Standard Meal",
      date: DateTime.now().subtract(const Duration(days: 1)),
      slot: "Dinner (8:00 PM - 9:00 PM)",
      sabzi: "Bhindi Masala",
      dal: "Dal Fry",
      roti: "5 Tawa Roti",
      rice: "Steamed Rice",
      addOns: ["Salad"],
      amount: 80.0,
      status: OrderStatus.delivered,
      deliveryAddress: "Flat 302, Silver Heights, Scheme 78, Indore",
      riderName: "Rajesh Kumar",
      riderPhone: "+91 98765 01234",
      estimatedMinutes: 0,
    ),
    OrderItemModel(
      orderId: "VR10235",
      planName: "Trial Meal (Standard)",
      date: DateTime.now().subtract(const Duration(days: 2)),
      slot: "Lunch (1:00 PM - 2:00 PM)",
      sabzi: "Mix Veg Handi",
      dal: "Dal Tadka",
      roti: "5 Butter Roti",
      rice: "Jeera Rice",
      addOns: ["Dahi / Raita"],
      amount: 110.0,
      status: OrderStatus.delivered,
      deliveryAddress: "Tech Park, 4th Floor, Vijay Nagar, Indore",
      riderName: "Sunil Verma",
      riderPhone: "+91 98765 77889",
      estimatedMinutes: 0,
    ),
  ];

  // Initial Wallet Transactions
  static List<WalletTransactionModel> initialWalletTransactions = [
    WalletTransactionModel(
      id: "TXN_901",
      title: "Paused Meal Credit",
      description: "Credit for paused lunch on 8th Sep",
      amount: 80.0,
      type: TransactionType.credit,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
    ),
    WalletTransactionModel(
      id: "TXN_902",
      title: "Dahi Add-on Purchase",
      description: "Deduct for customized lunch add-on",
      amount: 20.0,
      type: TransactionType.debit,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    WalletTransactionModel(
      id: "TXN_903",
      title: "Paused Meal Credit",
      description: "Credit for paused dinner on 5th Sep",
      amount: 80.0,
      type: TransactionType.credit,
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
    ),
    WalletTransactionModel(
      id: "TXN_904",
      title: "Added Money",
      description: "Wallet recharge via UPI",
      amount: 100.0,
      type: TransactionType.credit,
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  // Kitchen Aggregation
  static List<KitchenPrepItem> initialKitchenPrep = [
    KitchenPrepItem(
      id: "prep_1",
      itemName: "Paneer Gravy (Paneer Butter Masala)",
      totalPortions: 75,
      status: PrepStatus.preparing,
    ),
    KitchenPrepItem(
      id: "prep_2",
      itemName: "Bhindi Masala",
      totalPortions: 45,
      status: PrepStatus.preparing,
    ),
    KitchenPrepItem(
      id: "prep_3",
      itemName: "Dal Tadka",
      totalPortions: 80,
      status: PrepStatus.ready,
    ),
    KitchenPrepItem(
      id: "prep_4",
      itemName: "Tawa Roti",
      totalPortions: 360,
      unit: "rotis",
      status: PrepStatus.preparing,
    ),
    KitchenPrepItem(
      id: "prep_5",
      itemName: "Butter Roti",
      totalPortions: 120,
      unit: "rotis",
      status: PrepStatus.ready,
    ),
    KitchenPrepItem(
      id: "prep_6",
      itemName: "Jeera & Steamed Rice",
      totalPortions: 150,
      status: PrepStatus.completed,
    ),
  ];

  // Kitchen Inventory
  static const List<InventoryItemModel> initialInventory = [
    InventoryItemModel(
      id: "inv_1",
      name: "Fresh Paneer",
      currentStock: 12.0,
      minRequired: 25.0,
      unit: "kg",
      isLowStock: true,
    ),
    InventoryItemModel(
      id: "inv_2",
      name: "Basmati Rice",
      currentStock: 35.0,
      minRequired: 20.0,
      unit: "kg",
      isLowStock: false,
    ),
    InventoryItemModel(
      id: "inv_3",
      name: "Chakki Wheat Flour",
      currentStock: 60.0,
      minRequired: 30.0,
      unit: "kg",
      isLowStock: false,
    ),
    InventoryItemModel(
      id: "inv_4",
      name: "Toor & Moong Dal",
      currentStock: 20.0,
      minRequired: 15.0,
      unit: "kg",
      isLowStock: false,
    ),
    InventoryItemModel(
      id: "inv_5",
      name: "Daily Fresh Vegetables",
      currentStock: 18.0,
      minRequired: 30.0,
      unit: "kg",
      isLowStock: true,
    ),
  ];

  // Rider Stops
  static List<DeliveryStopModel> initialRiderStops = [
    DeliveryStopModel(
      orderId: "VR10245",
      customerName: "Rahul Sharma",
      phone: "+91 98765 43210",
      address: "Tech Park, 4th Floor, Vijay Nagar",
      addressTag: "Office",
      distanceKm: "1.2 km",
      mealType: "Lunch",
      items: ["Paneer Butter Masala", "Dal Tadka", "5 Butter Roti", "Jeera Rice", "Sev"],
      isQrVerified: true,
      status: DeliveryStatus.inTransit,
    ),
    DeliveryStopModel(
      orderId: "VR10246",
      customerName: "Amit Kumar",
      phone: "+91 98111 22334",
      address: "Flat 204, Royal Palms, Scheme 78",
      addressTag: "Home",
      distanceKm: "2.4 km",
      mealType: "Lunch",
      items: ["Paneer Butter Masala", "Mix Veg", "Dal", "5 Butter Roti", "Sweet"],
      isQrVerified: true,
      status: DeliveryStatus.pickedUp,
    ),
    DeliveryStopModel(
      orderId: "VR10247",
      customerName: "Priya Jain",
      phone: "+91 98222 33445",
      address: "Corporate Tower, AB Road",
      addressTag: "Office",
      distanceKm: "3.8 km",
      mealType: "Lunch",
      items: ["Jain Mix Veg", "Dal Fry", "5 Tawa Roti", "Plain Rice"],
      isQrVerified: false,
      status: DeliveryStatus.assigned,
    ),
    DeliveryStopModel(
      orderId: "VR10248",
      customerName: "Neha Singh",
      phone: "+91 98333 44556",
      address: "Row House 14, Old Palasia",
      addressTag: "Home",
      distanceKm: "5.1 km",
      mealType: "Lunch",
      items: ["Bhindi Masala", "Dal Tadka", "5 Butter Roti", "Jeera Rice"],
      isQrVerified: false,
      status: DeliveryStatus.assigned,
    ),
  ];
}
