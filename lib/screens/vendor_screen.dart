import 'package:flutter/material.dart';

import 'add_item_tab.dart';   // 👈 import the Add tab
import 'edit_item_tab.dart';  // 👈 import the Edit tab
import 'orders_tab.dart';     // 👈 import the Orders tab

class VendorScreen extends StatelessWidget {
  const VendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Add Items + Edit Items + Orders
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendor Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Items'),
              Tab(text: 'Edit Items'),
              Tab(text: 'Orders'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AddItemTab(),   // 👈 real widget now
            EditItemTab(),  // 👈 real widget now
            OrdersTab(),    // 👈 new Orders tab
          ],
        ),
      ),
    );
  }
}