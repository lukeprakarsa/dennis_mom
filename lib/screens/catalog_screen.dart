import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../models/cart.dart';
import '../repositories/vendor_repository.dart';   // 👈 repository import
import 'cart_screen.dart';
import 'item_detail_screen.dart';
import 'vendor_screen.dart';
import '../widgets/item_thumbnail.dart';

/// Displays the catalog of items available for purchase.
/// Pulls data from the VendorRepository so it always reflects
/// the latest vendor‑added or edited items.
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ----------------------------
      // AppBar with cart icon + badge
      // ----------------------------
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
                  // Show red badge if cart has items
                  if (cart.totalItemsCount > 0)
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
                          '${cart.totalItemsCount}',
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

      // ----------------------------
      // Body: list of items
      // ----------------------------
      body: Consumer2<Cart, InMemoryVendorRepository>(
        builder: (context, cart, repo, child) {
          // Upcast to the abstraction
          final VendorRepository vendorRepo = repo;

          final items = vendorRepo.getAllItems();

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final Item item = items[index];
              final int quantity = cart.items[item] ?? 0;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: ItemThumbnail(
                    imageUrl: item.imageUrl,
                    width: 50,
                    height: 50,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${item.description}\n\$${item.price.toStringAsFixed(2)}',
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailScreen(item: item),
                      ),
                    );
                  },
                  // ----------------------------
                  // Trailing: add/remove buttons
                  // ----------------------------
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

      // ----------------------------
      // Floating Action Button: Vendor screen
      // ----------------------------
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.store),
        tooltip: 'Vendor Screen Demo',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorScreen(),
            ),
          );
        },
      ),
    );
  }
}