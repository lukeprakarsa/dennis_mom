import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_cart.dart';
import '../models/api_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<ApiCart>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView(
              children: cart.items.entries.map((entry) {
                final ApiItem item = entry.key;
                final int quantity = entry.value;
                final bool atMaxStock = quantity >= item.stock;

                return ListTile(
                  key: ValueKey(item.id),
                  leading: Image.network(item.imageUrl, width: 50, height: 50),
                  title: Text(item.name),
                  subtitle: Text(
                    'Quantity: $quantity\n'
                    'Stock: ${item.stock}\n'
                    '\$${(item.price * quantity).toStringAsFixed(2)}',
                  ),
                  trailing: Row(
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
                          if (atMaxStock) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No more stock available'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          cart.addItem(item);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          cart.removeItemCompletely(item);
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: cart.totalItemsCount == 0
              ? null
              : () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout not implemented yet!')),
                  );
                },
          child: Text(
            'Checkout (${cart.totalItemsCount} items) - \$${cart.totalPrice.toStringAsFixed(2)}',
          ),
        ),
      ),
    );
  }
}
