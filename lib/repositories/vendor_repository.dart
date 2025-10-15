import 'package:flutter/foundation.dart';  // 👈 for ChangeNotifier
import '../models/item.dart';

/// Defines the contract for vendor operations
abstract class VendorRepository {
  void addItem(Item item);
  void editItem(String id, Item updatedItem);
  void deleteItem(String id);              // 👈 new delete method
  List<Item> getAllItems();
}

/// A simple in‑memory implementation of VendorRepository.
/// Extends ChangeNotifier so UI can rebuild automatically.
class InMemoryVendorRepository extends ChangeNotifier
    implements VendorRepository {
  final List<Item> _items = [
    Item(
      id: '1',
      name: 'Red T-Shirt',
      description: 'A stylish red t-shirt',
      price: 29.99,
      imageUrl: 'https://i5.walmartimages.com/asr/bea847bb-2b19-4e49-8f11-903a1b9267aa.f430e098b3072789b08fe3b61f09b654.jpeg',
    ),
    Item(
      id: '2',
      name: 'Blue Jeans',
      description: 'Comfortable blue jeans',
      price: 59.99,
      imageUrl: 'https://bwolves.com/cdn/shop/files/baggy27_1.jpg?v=1756625352',
    ),
    Item(
      id: '3',
      name: 'Sneakers',
      description: 'Running sneakers',
      price: 89.99,
      imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQaFG9gP-JGZrKwwhoPL65u5yO84kC4hb6mbw&s',
    ),
  ];

  @override
  void addItem(Item item) {
    _items.add(item);
    notifyListeners(); // 👈 tell listeners to rebuild
  }

  @override
  void editItem(String id, Item updatedItem) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updatedItem;
      notifyListeners(); // 👈 tell listeners to rebuild
    }
  }

  @override
  void deleteItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners(); // 👈 triggers rebuilds
  }

  @override
  List<Item> getAllItems() => List.unmodifiable(_items);
}