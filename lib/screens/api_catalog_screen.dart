import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/api_item.dart';
import '../models/api_cart.dart';
import '../repositories/api_vendor_repository.dart';
import '../services/auth_service.dart';
import 'cart_screen.dart';
import 'item_detail_screen.dart';
import 'vendor_screen.dart';
import 'login_screen.dart';
import '../widgets/item_thumbnail.dart';

/// Displays the catalog of items available for purchase.
/// Pulls data from the ApiVendorRepository and supports guest browsing.
class ApiCatalogScreen extends StatefulWidget {
  const ApiCatalogScreen({super.key});

  @override
  State<ApiCatalogScreen> createState() => _ApiCatalogScreenState();
}

class _ApiCatalogScreenState extends State<ApiCatalogScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch items when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApiVendorRepository>().fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with cart icon, badge, and login/user button
      appBar: AppBar(
        title: const Text('Catalog'),
        actions: [
          // Login/User button
          Consumer<AuthService>(
            builder: (context, authService, child) {
              if (authService.isAuthenticated) {
                return PopupMenuButton<String>(
                  icon: Icon(
                    authService.currentUser?.isVendor == true
                        ? Icons.store
                        : Icons.account_circle,
                  ),
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await authService.logout();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Logged out successfully')),
                        );
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authService.currentUser?.email ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            authService.currentUser?.role ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.login),
                  tooltip: 'Login',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                );
              }
            },
          ),

          // Cart button (hidden for vendors)
          Consumer2<AuthService, ApiCart>(
            builder: (context, authService, cart, child) {
              // Hide cart for vendors
              if (authService.isAuthenticated && authService.currentUser?.isVendor == true) {
                return const SizedBox.shrink();
              }

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

      // Body: list of items
      body: Consumer3<AuthService, ApiCart, ApiVendorRepository>(
        builder: (context, authService, cart, repo, child) {
          if (repo.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = repo.getAllItems();

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
                    'Vendors can add items using the vendor button',
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
              final ApiItem item = items[index];
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
                      // Subtitle: description, price, and stock
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                      isThreeLine: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ItemDetailScreen(item: item),
                          ),
                        );
                      },
                      // Trailing: add/remove buttons (hidden for vendors)
                      trailing: (authService.isAuthenticated && authService.currentUser?.isVendor == true)
                          ? null // Hide cart buttons for vendors
                          : outOfStock
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
                                            duration: const Duration(seconds: 1),
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
                                              ? null
                                              : () {
                                                  cart.addItem(item);
                                                },
                                        ),
                                      ],
                                    ),
                    ),
                  ),
                  // Overlay for out-of-stock items (non-blocking)
                  if (outOfStock)
                    Positioned.fill(
                      child: IgnorePointer(
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

      // Floating Action Button: Vendor screen (vendors only)
      floatingActionButton: Consumer<AuthService>(
        builder: (context, authService, child) {
          // Only show vendor button if user is logged in as vendor
          if (authService.isAuthenticated && authService.currentUser?.isVendor == true) {
            return FloatingActionButton(
              tooltip: 'Vendor Dashboard',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VendorScreen(),
                  ),
                );
              },
              child: const Icon(Icons.store),
            );
          }
          return const SizedBox.shrink(); // Hide button for non-vendors
        },
      ),
    );
  }
}
