import 'package:flutter/foundation.dart';
import 'item.dart';

class Cart extends ChangeNotifier {
  final Map<Item, int> _items = {}; // Item → quantity

  void addItem(Item item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
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
  int get totalItemsCount {
    return _items.values.fold(0, (sum, qty) => sum + qty);
  }
}
