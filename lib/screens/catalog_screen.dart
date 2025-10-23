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
    print('📱 Building CatalogScreen...');
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
          print('🛒 Consumer2 builder called - Cart items: ${cart.totalItemsCount}');
          // Upcast to the abstraction
          final VendorRepository vendorRepo = repo;

          final items = vendorRepo.getAllItems();
          print('📦 Repository items: ${items.length}');

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No items in catalog',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Use the vendor button to add items',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final Item item = items[index];
              final int quantity = cart.items[item] ?? 0;
              final bool outOfStock = item.stock == 0;
              final bool atMaxStock = quantity >= item.stock;

              return Stack(
                children: [
                  Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: ItemThumbnail(
                        imageUrl: item.imageUrl,
                        width: 50,
                        height: 50,
                      ),
                      title: Text(item.name),
                      // ----------------------------
                      // Subtitle: description + price + stock
                      // ----------------------------
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            maxLines: 1, // 👈 limit to 1 line
                            overflow: TextOverflow.ellipsis, // 👈 show "..." if too long
                          ),
                          Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Stock: ${item.stock}',
                            style: TextStyle(
                              color: item.stock == 0 ? Colors.red : Colors.black,
                              fontWeight: item.stock <= 3 ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      isThreeLine: false, // 👈 tighter layout
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
                      trailing: outOfStock
                          ? const Text(
                              'Out of Stock',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : quantity == 0
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
                                      onPressed: atMaxStock
                                          ? null // 👈 disable if at max stock
                                          : () {
                                              cart.addItem(item);
                                            },
                                    ),
                                  ],
                                ),
                    ),
                  ),
                  // ----------------------------
                  // Overlay for out-of-stock items (non-blocking)
                  // ----------------------------
                  if (outOfStock)
                    Positioned.fill(
                      child: IgnorePointer( // 👈 allow taps to pass through
                        child: Container(
                          color: Colors.white.withValues(alpha: 0.7),
                          alignment: Alignment.center,
                          child: const Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),

      // ----------------------------
      // Floating Action Button: Vendor screen
      // ----------------------------
      floatingActionButton: FloatingActionButton(
        tooltip: 'Vendor Screen Demo',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const VendorScreen(),
            ),
          );
        },
        child: const Icon(Icons.store),
      ),
    );
  }
}