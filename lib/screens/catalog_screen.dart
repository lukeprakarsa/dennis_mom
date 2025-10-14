import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/sample_items.dart';
import '../models/item.dart';
import '../models/cart.dart';
import 'cart_screen.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          Consumer<Cart>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.items.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.items.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<Cart>(
        builder: (context, cart, child) {
          return ListView.builder(
            itemCount: sampleItems.length,
            itemBuilder: (context, index) {
              final Item item = sampleItems[index];
              final int quantity = cart.items[item] ?? 0;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: Image.network(item.imageUrl),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.description}\n\$${item.price.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  trailing: quantity == 0
                      ? IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () {
                            cart.addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${item.name} added to cart!'),
                              ),
                            );
                          },
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                cart.removeSingleItem(item);
                              },
                            ),
                            Text('$quantity'),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                cart.addItem(item);
                              },
                            ),
                          ],
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}