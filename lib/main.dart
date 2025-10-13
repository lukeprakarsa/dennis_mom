import 'package:flutter/material.dart';
import 'screens/catalog_screen.dart';

void main() {
  print('Running my edited main.dart!');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mock Catalog',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CatalogScreen(),
    );
  }
}