import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/cart.dart';
import '../models/item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<Cart>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.items.isEmpty
          ? const Center(child: Text('Your cart is empty'))
          : ListView(
              children: cart.items.entries.map((entry) {
                final Item item = entry.key;
                final int quantity = entry.value;
                return ListTile(
                  key: ValueKey(item.id),
                  leading: Image.network(item.imageUrl),
                  title: Text(item.name),
                  subtitle: Text(
                    'Quantity: $quantity\n\$${(item.price * quantity).toStringAsFixed(2)}',
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checkout not implemented yet!')),
            );
          },
          child: Text(
            'Checkout - \$${cart.totalPrice.toStringAsFixed(2)}',
          ),
        ),
      ),
    );
  }
}