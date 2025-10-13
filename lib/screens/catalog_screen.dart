import 'package:flutter/material.dart';
import '../data/sample_items.dart';
import '../models/item.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catalog')),
      body: ListView.builder(
        itemCount: sampleItems.length,
        itemBuilder: (context, index) {
          final Item item = sampleItems[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(item.imageUrl),
              title: Text(item.name),
              subtitle: Text('${item.description}\n\$${item.price.toStringAsFixed(2)}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}