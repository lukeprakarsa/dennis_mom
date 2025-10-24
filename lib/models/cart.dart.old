import 'package:flutter/foundation.dart';
import 'item.dart';

class Cart extends ChangeNotifier {
  final Map<Item, int> _items = {}; // Item → quantity

  /// Adds an item to the cart.
  ///
  /// - If the cart already contains this item, its quantity is increased by 1.
  /// - If the cart does not contain this item yet, it is added with a quantity of 1.
  /// - Prevents adding more than the item's available stock.
  /// - Calls `notifyListeners()` to update the UI or any listeners about the change.
  /// - wowowowowowowwwwww we're using maps here!!! we're so cool
  void addItem(Item item) {
    final currentQty = _items[item] ?? 0;

    // 👇 Prevent adding more than available stock
    if (currentQty >= item.stock) return;

    if (_items.containsKey(item)) {
      _items[item] = currentQty + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  void removeSingleItem(Item item) {
    if (!_items.containsKey(item)) return;
    if (_items[item]! > 1) {
      _items[item] = _items[item]! - 1;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeItemCompletely(Item item) {
    _items.remove(item);
    notifyListeners();
  }

  Map<Item, int> get items => Map.unmodifiable(_items);

  double get totalPrice => _items.entries
      .fold(0, (sum, entry) => sum + entry.key.price * entry.value);

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Returns the total number of items in the cart.
  ///
  /// `fold` goes through each quantity in `_items.values` and combines them
  /// into a single total.
  /// - The first argument `0` is the starting value of the sum.
  /// - The function `(sum, qty) => sum + qty` adds each quantity to the running total.
  int get totalItemsCount {
    return _items.values.fold(0, (sum, qty) => sum + qty);
  }

  /// Optional helper: checks if more of this item can be added
  bool canAdd(Item item) {
    final currentQty = _items[item] ?? 0;
    return currentQty < item.stock;
  }
}