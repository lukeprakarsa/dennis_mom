import 'package:flutter/material.dart';

import 'add_item_tab.dart';
import 'edit_item_tab.dart';
import 'orders_tab.dart';

class VendorScreen extends StatelessWidget {
  const VendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
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
            AddItemTab(),
            EditItemTab(),
            OrdersTab(),
          ],
        ),
      ),
    );
  }
}