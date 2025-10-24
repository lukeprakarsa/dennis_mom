import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/api_cart.dart';
import 'repositories/api_vendor_repository.dart';
import 'services/auth_service.dart';
import 'screens/api_catalog_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('🚀 App starting...');

  runApp(
    MultiProvider(
      providers: [
        // ----------------------------
        // Authentication service
        // ----------------------------
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService()..initialize(),
        ),

        // ----------------------------
        // Cart provider
        // ----------------------------
        ChangeNotifierProvider<ApiCart>(create: (_) => ApiCart()),

        // ----------------------------
        // Vendor repository provider (API-backed)
        // ----------------------------
        ChangeNotifierProxyProvider<AuthService, ApiVendorRepository>(
          create: (_) => ApiVendorRepository(),
          update: (context, authService, repository) {
            repository!.setToken(authService.token);
            return repository;
          },
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
    print('🏗️ Building MyApp...');
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dennis Mom Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Show loading screen while checking authentication
          if (authService.isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show catalog screen (guests can browse, login button shown)
          return const ApiCatalogScreen();
        },
      ),
      routes: {
        '/cart': (context) => const CartScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
