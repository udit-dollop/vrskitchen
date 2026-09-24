import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vrs_kitchen/core/network/api_client.dart';
import 'package:vrs_kitchen/core/routes/app_routes.dart';
import 'package:vrs_kitchen/features/onboarding/splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Session & Token Management', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ApiClient loads tokens from SharedPreferences on init()', () async {
      SharedPreferences.setMockInitialValues({
        'vrs_access_token': 'saved_access_token',
        'vrs_refresh_token': 'saved_refresh_token',
      });

      final client = ApiClient();
      await client.init();

      expect(client.accessToken, 'saved_access_token');
      expect(client.refreshToken, 'saved_refresh_token');
      expect(client.isAuthenticated, isTrue);

      await client.clearTokens();
      expect(client.isAuthenticated, isFalse);
    });

    test('ApiClient preserves refreshToken if setTokens is called without refreshToken', () async {
      final client = ApiClient();
      await client.setTokens(accessToken: 'token_1', refreshToken: 'refresh_1');
      expect(client.refreshToken, 'refresh_1');

      // Update access token only
      await client.setTokens(accessToken: 'token_2');
      expect(client.accessToken, 'token_2');
      expect(client.refreshToken, 'refresh_1');

      await client.clearTokens();
    });

    testWidgets('SplashScreen navigates to customerHome when user has active token session', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({
        'vrs_access_token': 'active_user_jwt_token',
        'vrs_refresh_token': 'active_refresh_token',
      });

      final client = ApiClient();
      await client.init();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.customerHome: (_) => const Scaffold(body: Text('Customer Home Screen')),
            AppRoutes.onboarding: (_) => const Scaffold(body: Text('Onboarding Screen')),
          },
        ),
      );

      // Advance time past 2800ms splash timer
      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Must navigate directly to Customer Home, NOT Onboarding!
      expect(find.text('Customer Home Screen'), findsOneWidget);
      expect(find.text('Onboarding Screen'), findsNothing);

      await client.clearTokens();
    });

    testWidgets('SplashScreen navigates to onboarding when user has no saved session', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      final client = ApiClient();
      await client.clearTokens();
      await client.init();

      await tester.pumpWidget(
        MaterialApp(
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.customerHome: (_) => const Scaffold(body: Text('Customer Home Screen')),
            AppRoutes.onboarding: (_) => const Scaffold(body: Text('Onboarding Screen')),
          },
        ),
      );

      await tester.pump(const Duration(milliseconds: 3000));
      await tester.pumpAndSettle();

      // Must navigate to Onboarding Screen when not logged in
      expect(find.text('Onboarding Screen'), findsOneWidget);
      expect(find.text('Customer Home Screen'), findsNothing);
    });
  });
}
