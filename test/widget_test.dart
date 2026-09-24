import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vrs_kitchen/core/routes/app_routes.dart';
import 'package:vrs_kitchen/core/services/api_service.dart';
import 'package:vrs_kitchen/data/models/daily_menu_api_model.dart';
import 'package:vrs_kitchen/features/authentication/dietary_setup_screen.dart';
import 'package:vrs_kitchen/features/customer/customization/meal_customizer_screen.dart';
import 'package:vrs_kitchen/features/customer/home/home_dashboard_screen.dart';
import 'package:vrs_kitchen/features/customer/profile/profile_screen.dart';
import 'package:vrs_kitchen/main.dart';
import 'package:vrs_kitchen/state/app_state_provider.dart';

class _FakeTestApiService extends ApiService {
  List<Map<String, dynamic>>? lastSavedPayload;
  final List<dynamic> mockUserAllergies;
  List<DailyMenuResponseModel> mockDailyMenus = [];
  Map<String, dynamic>? lastCustomizedOrderPayload;
  String? lastRequestedMenuDate;
  String? lastRequestedSlot;

  _FakeTestApiService({
    this.mockUserAllergies = const [],
  });

  @override
  Future<List<DailyMenuResponseModel>> getDailyMenusTyped({
    String? menuDate,
    String? slot,
  }) async {
    lastRequestedMenuDate = menuDate;
    lastRequestedSlot = slot;
    return mockDailyMenus;
  }

  @override
  Future<Map<String, dynamic>> placeOrCustomizeOrder(Map<String, dynamic> orderPayload) async {
    lastCustomizedOrderPayload = orderPayload;
    return {'success': true};
  }

  @override
  Future<List<dynamic>> getCategories() async {
    return [
      {
        'id': 'cat-1',
        'name': 'Vegetables',
        'code': 'VEG',
        'isActive': true,
      },
      {
        'id': 'cat-2',
        'name': 'Dairy',
        'code': 'DAIRY',
        'isActive': true,
      }
    ];
  }

  @override
  Future<List<dynamic>> getCategoryItems(String categoryId) async {
    if (categoryId == 'cat-1') {
      return [
        {
          'id': 'item-1',
          'categoryId': 'cat-1',
          'name': 'Potato',
          'description': 'Root vegetable',
          'isActive': true,
        },
        {
          'id': 'item-2',
          'categoryId': 'cat-1',
          'name': 'Tomato',
          'description': 'Fresh red tomato',
          'isActive': true,
        }
      ];
    }
    return [];
  }

  @override
  Future<List<dynamic>> getUserAllergies() async {
    return mockUserAllergies;
  }

  @override
  Future<List<dynamic>> saveUserAllergies(List<Map<String, dynamic>> payload) async {
    lastSavedPayload = payload;
    return [];
  }
}

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VrsKitchenApp());
    expect(find.byType(VrsKitchenApp), findsOneWidget);
  });

  testWidgets('HomeDashboardScreen builds safely without throwing Bad state: No element', (WidgetTester tester) async {
    final provider = AppStateProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: HomeDashboardScreen(),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(HomeDashboardScreen), findsOneWidget);
  });

  testWidgets('DietarySetupScreen builds with Food Allergies UI and toggles items', (WidgetTester tester) async {
    final provider = AppStateProvider();
    final testApi = _FakeTestApiService();
    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: MaterialApp(
          home: DietarySetupScreen(apiService: testApi),
          routes: {
            AppRoutes.customerHome: (_) => const Scaffold(body: Text('Home')),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Food Allergies Title and Header
    expect(find.text('Food Allergies'), findsOneWidget);
    expect(find.text('Select Category'), findsOneWidget);
    expect(find.text('Vegetables'), findsOneWidget);

    // Verify items in category
    expect(find.text('Potato'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);

    // Verify save button appears
    expect(find.textContaining('Save Allergies'), findsOneWidget);

    // Tap on Potato to toggle it
    await tester.ensureVisible(find.text('Potato'));
    await tester.tap(find.text('Potato'));
    await tester.pump();

    expect(find.textContaining('Save Allergies (1)'), findsOneWidget);

    // Tap on Save Allergies button
    await tester.tap(find.textContaining('Save Allergies'));
    await tester.pumpAndSettle();

    // Verify exact payload sent to saveUserAllergies
    expect(testApi.lastSavedPayload, isNotNull);
    expect(testApi.lastSavedPayload!.length, 1);
    expect(testApi.lastSavedPayload![0]['categoryId'], 'cat-1');
    expect(testApi.lastSavedPayload![0]['menuItemIds'], ['item-1']);
    expect(testApi.lastSavedPayload![0]['note'], 'Severe allergy / cannot eat');
  });

  testWidgets('DietarySetupScreen shows pre-loaded allergies from GET API in Your Recorded Allergies UI', (WidgetTester tester) async {
    final provider = AppStateProvider();
    final testApi = _FakeTestApiService(
      mockUserAllergies: [
        {
          'categoryId': 'cat-1',
          'categoryName': 'Vegetables',
          'items': [
            {
              'id': 'allergy-1',
              'categoryId': 'cat-1',
              'categoryName': 'Vegetables',
              'menuItemId': 'item-1',
              'itemName': 'Potato',
              'note': 'Severe allergy',
            }
          ]
        }
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: MaterialApp(
          home: DietarySetupScreen(apiService: testApi),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify "Your Recorded Allergies" card and items
    expect(find.text('Your Recorded Allergies'), findsOneWidget);
    expect(find.text('Recorded Allergy'), findsOneWidget);
    expect(find.textContaining('Save Allergies (1)'), findsOneWidget);
  });

  testWidgets('ProfileScreen shows recorded allergies preview pills when user has allergies', (WidgetTester tester) async {
    final provider = AppStateProvider();
    provider.updateUserProfile(allergies: ['Peanuts', 'Tomato']);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Food Allergies'), findsOneWidget);
    expect(find.text('2 active restrictions recorded'), findsOneWidget);
    expect(find.text('Peanuts'), findsOneWidget);
    expect(find.text('Tomato'), findsOneWidget);
  });

  testWidgets('MealCustomizerScreen loads daily menu from API and renders dynamic categories with single and quantity selection', (WidgetTester tester) async {
    final provider = AppStateProvider();
    final testApi = _FakeTestApiService();
    testApi.mockDailyMenus = [
      const DailyMenuResponseModel(
        id: 'menu-101',
        kitchenId: 'k-101',
        kitchenName: 'Central Rasoi',
        planName: 'Deluxe Homestyle Thali',
        menuDate: '2026-09-24',
        slot: 'LUNCH',
        cutOffTime: '2026-09-24T18:00:00.000Z',
        status: 'OPEN',
        categoryMenus: [
          CategoryMenuModel(
            categoryId: 'cat-sabzi',
            categoryName: 'Sabzi Preparation',
            allowedCount: 1,
            isQuantityBased: false,
            defaultItems: [
              CategoryMenuItemModel(
                id: 'item-paneer',
                name: 'Paneer Butter Masala',
                description: 'Rich cottage cheese gravy',
                dietaryTag: 'VEG',
                extraPrice: 0,
              ),
            ],
            availableOptions: [
              CategoryMenuItemModel(
                id: 'item-paneer',
                name: 'Paneer Butter Masala',
                description: 'Rich cottage cheese gravy',
                dietaryTag: 'VEG',
                extraPrice: 0,
              ),
              CategoryMenuItemModel(
                id: 'item-mixveg',
                name: 'Mix Veg Kolhapuri',
                description: 'Spicy seasonal vegetables',
                dietaryTag: 'VEG',
                extraPrice: 15,
              ),
            ],
          ),
          CategoryMenuModel(
            categoryId: 'cat-breads',
            categoryName: 'Breads & Rotis',
            allowedCount: 5,
            isQuantityBased: true,
            defaultItems: [
              CategoryMenuItemModel(
                id: 'item-roti',
                name: 'Butter Tawa Roti',
                description: 'Wheat phulkas with butter',
                dietaryTag: 'VEG',
                extraPrice: 0,
              ),
            ],
            availableOptions: [
              CategoryMenuItemModel(
                id: 'item-roti',
                name: 'Butter Tawa Roti',
                description: 'Wheat phulkas with butter',
                dietaryTag: 'VEG',
                extraPrice: 0,
              ),
              CategoryMenuItemModel(
                id: 'item-paratha',
                name: 'Laccha Paratha',
                description: 'Layered paratha',
                dietaryTag: 'VEG',
                extraPrice: 20,
              ),
            ],
          ),
        ],
      ),
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider<AppStateProvider>.value(
        value: provider,
        child: MaterialApp(
          home: MealCustomizerScreen(apiService: testApi),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Kitchen info & Plan
    expect(find.text('Deluxe Homestyle Thali'), findsOneWidget);
    expect(find.text('Kitchen: Central Rasoi'), findsOneWidget);
    expect(find.text('OPEN'), findsOneWidget);

    // Verify Category 1 (Single choice)
    expect(find.text('1. Sabzi Preparation'), findsOneWidget);
    expect(find.text('Paneer Butter Masala'), findsOneWidget);
    expect(find.text('Mix Veg Kolhapuri'), findsOneWidget);
    expect(find.text('+ ₹15'), findsOneWidget);

    // Verify Category 2 (Quantity based)
    expect(find.text('2. Breads & Rotis'), findsOneWidget);
    expect(find.text('Butter Tawa Roti'), findsOneWidget);
    expect(find.text('Laccha Paratha'), findsOneWidget);
    expect(find.text('+ ₹20 each'), findsOneWidget);

    // Select Mix Veg Kolhapuri (which has + ₹15 extra price)
    await tester.tap(find.text('Mix Veg Kolhapuri'));
    await tester.pumpAndSettle();

    // Verify Extra Charges updated to ₹15
    expect(find.text('₹15'), findsOneWidget);

    // Tap confirm meal
    await tester.tap(find.text('Confirm Meal'));
    await tester.pumpAndSettle();

    // Verify order was customized
    expect(testApi.lastCustomizedOrderPayload, isNotNull);
    expect(testApi.lastCustomizedOrderPayload!['menuId'], 'menu-101');
    expect(testApi.lastCustomizedOrderPayload!['slot'], 'LUNCH');
  });
}

