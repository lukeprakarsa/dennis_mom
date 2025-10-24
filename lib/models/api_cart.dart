import 'package:flutter/foundation.dart';
import 'api_item.dart';

/// Shopping cart that works with ApiItem
class ApiCart extends ChangeNotifier {
  final Map<ApiItem, int> _items = {};

  Map<ApiItem, int> get items => Map.unmodifiable(_items);

  int get totalItemsCount {
    return _items.values.fold(0, (sum, quantity) => sum + quantity);
  }

  double get totalPrice {
    return _items.entries.fold(
      0.0,
      (sum, entry) => sum + (entry.key.price * entry.value),
    );
  }

  void addItem(ApiItem item) {
    if (_items.containsKey(item)) {
      _items[item] = _items[item]! + 1;
    } else {
      _items[item] = 1;
    }
    notifyListeners();
  }

  void removeSingleItem(ApiItem item) {
    if (!_items.containsKey(item)) return;

    if (_items[item]! > 1) {
      _items[item] = _items[item]! - 1;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeItemCompletely(ApiItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
