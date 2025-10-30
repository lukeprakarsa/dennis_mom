import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_item.dart';
import '../models/api_cart.dart';
import '../services/auth_service.dart';

class ItemDetailScreen extends StatelessWidget {
  final ApiItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final cart = context.watch<ApiCart>();
    final int quantity = cart.items[item] ?? 0;
    final bool outOfStock = item.stock == 0;
    final bool atMaxStock = quantity >= item.stock;
    final bool isVendor = authService.isAuthenticated && authService.currentUser?.isVendor == true;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LEFT: Product image
            SizedBox(
              width: 150,
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),

            // RIGHT: Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(item.description),
                  const SizedBox(height: 12),

                  // Stock info
                  Text(
                    'Stock: ${item.stock}',
                    style: TextStyle(
                      fontSize: 16,
                      color: outOfStock ? Colors.red : Colors.black,
                      fontWeight: outOfStock ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cart controls (hidden for vendors)
                  if (!isVendor)
                    outOfStock
                        ? const Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : quantity == 0
                            ? ElevatedButton.icon(
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add to Cart'),
                                onPressed: () {
                                  cart.addItem(item);
                                },
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () {
                                      cart.removeSingleItem(item);
                                    },
                                  ),
                                  Text(
                                    '$quantity',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: atMaxStock
                                        ? null
                                        : () {
                                            cart.addItem(item);
                                          },
                                  ),
                                ],
                              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}