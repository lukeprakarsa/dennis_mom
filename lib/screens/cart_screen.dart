import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_cart.dart';
import '../models/api_item.dart';
import '../repositories/api_vendor_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isCheckingOut = false;

  Future<void> _handleCheckout() async {
    final cart = context.read<ApiCart>();
    final repository = context.read<ApiVendorRepository>();

    if (cart.items.isEmpty) return;

    setState(() {
      _isCheckingOut = true;
    });

    try {
      // Process checkout
      await repository.checkout(cart.items);

      // Clear the cart
      cart.clear();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully! Stock has been updated.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to catalog
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout failed: ${e.toString().replaceAll('ApiException: ', '')}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingOut = false;
        });
      }
    }
  }

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
          onPressed: (cart.totalItemsCount == 0 || _isCheckingOut) ? null : _handleCheckout,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isCheckingOut
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  'Checkout (${cart.totalItemsCount} items) - \$${cart.totalPrice.toStringAsFixed(2)}',
                ),
        ),
      ),
    );
  }
}
