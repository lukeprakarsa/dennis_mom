import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<Cart>(   // 👈 add <Cart> here
      create: (_) => Cart(),
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
