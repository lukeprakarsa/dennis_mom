import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';
import 'repositories/vendor_repository.dart';   // 👈 import your repository
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        // ----------------------------
        // Cart provider
        // ----------------------------
        ChangeNotifierProvider<Cart>(create: (_) => Cart()),

        // ----------------------------
        // Vendor repository provider
        // ----------------------------
        // Provide the concrete ChangeNotifier implementation.
        // Note: we register InMemoryVendorRepository directly,
        // not VendorRepository, because VendorRepository is just an interface.
        ChangeNotifierProvider<InMemoryVendorRepository>(
          create: (_) => InMemoryVendorRepository(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mock Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CatalogScreen(),
      routes: {
        '/cart': (context) => const CartScreen(),
      },
    );
  }
}