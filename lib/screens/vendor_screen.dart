import 'package:flutter/material.dart';

class VendorScreen extends StatelessWidget {
  const VendorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // for now: Add Items + Edit Items
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Vendor Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Items'),
              Tab(text: 'Edit Items'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Add Items Screen (coming soon)')),
            Center(child: Text('Edit Items Screen (coming soon)')),
          ],
        ),
      ),
    );
  }
}
