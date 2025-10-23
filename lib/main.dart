import 'package:dennis_mom/models/item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import 'models/cart.dart';
import 'repositories/vendor_repository.dart'; // 👈 import your repository
import 'screens/catalog_screen.dart';
import 'screens/cart_screen.dart';

void main() {
  print('🚀 App starting...');
  
  RealmResults<Item>? allItems;
  
  if (kIsWeb) {
    print('🌐 Running on web - Realm not supported, using in-memory data only');
    allItems = null; // Will use repository data instead
  } else {
    print('🖥️ Running on desktop - initializing Realm');
    final realm = Realm(Configuration.local([Item.schema]));
    print('✅ Realm initialized');
    allItems = realm.all<Item>();
    print('📦 Items loaded: ${allItems.length}');
  }

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
      child: MyApp(items: allItems),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.items});

  final RealmResults<Item>? items;

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building MyApp...');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mock Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CatalogScreen(),
      routes: {'/cart': (context) => const CartScreen()},
    );
  }
}
