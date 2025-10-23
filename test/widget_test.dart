// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:dennis_mom/models/cart.dart';
import 'package:dennis_mom/repositories/vendor_repository.dart';
import 'package:dennis_mom/screens/catalog_screen.dart';

void main() {
  testWidgets('Catalog screen basic test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: MultiProvider(
          providers: [
            ChangeNotifierProvider<Cart>(create: (_) => Cart()),
            ChangeNotifierProvider<InMemoryVendorRepository>(
              create: (_) => InMemoryVendorRepository(),
            ),
          ],
          child: const CatalogScreen(),
        ),
      ),
    );

    // Verify that the catalog screen is displayed
    expect(find.text('Catalog'), findsOneWidget);
    
    // Verify that the cart icon is present
    expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    
    // Verify that the vendor button is present
    expect(find.byIcon(Icons.store), findsOneWidget);
  });
}
