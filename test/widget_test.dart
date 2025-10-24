// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dennis_mom/models/api_cart.dart';
import 'package:dennis_mom/repositories/api_vendor_repository.dart';
import 'package:dennis_mom/services/auth_service.dart';
import 'package:dennis_mom/screens/api_catalog_screen.dart';

void main() {
  testWidgets('Catalog screen basic test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => AuthService(),
            ),
            ChangeNotifierProvider<ApiCart>(create: (_) => ApiCart()),
            ChangeNotifierProxyProvider<AuthService, ApiVendorRepository>(
              create: (_) => ApiVendorRepository(),
              update: (context, authService, repository) {
                repository!.setToken(authService.token);
                return repository;
              },
            ),
          ],
          child: const ApiCatalogScreen(),
        ),
      ),
    );

    // Verify that the catalog screen is displayed
    expect(find.text('Catalog'), findsOneWidget);

    // Verify that the cart icon is present
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
  });
}
