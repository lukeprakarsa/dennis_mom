import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/api_item.dart';
import '../services/api_service.dart';
import '../services/orders_service.dart';

/// API-backed vendor repository that communicates with the backend
class ApiVendorRepository extends ChangeNotifier {
  List<ApiItem> _items = [];
  bool _isLoading = false;
  String? _token;

  List<ApiItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  /// Set the authentication token for API requests
  void setToken(String? token) {
    _token = token;
  }

  /// Fetch all items from the API
  Future<void> fetchItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/api/items');

      // Parse response body as JSON list
      final List<dynamic> itemsList = jsonDecode(response.body);
      _items = itemsList.map((json) => ApiItem.fromJson(json as Map<String, dynamic>)).toList();

      print('✅ Fetched ${_items.length} items from API');
    } catch (e) {
      print('❌ Error fetching items: $e');
      _items = [];
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new item (vendor only)
  Future<void> addItem(ApiItem item) async {
    if (_token == null) {
      throw Exception('Must be logged in to add items');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.post(
        '/api/items',
        body: item.toJson(),
        token: _token,
      );

      final data = ApiService.handleResponse(response);
      final newItem = ApiItem.fromJson(data['item']);

      _items.add(newItem);
      print('✅ Added item: ${newItem.name}');
    } catch (e) {
      print('❌ Error adding item: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Edit an existing item (vendor only)
  Future<void> editItem(String id, ApiItem updatedItem) async {
    if (_token == null) {
      throw Exception('Must be logged in to edit items');
    }

    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.put(
        '/api/items/$id',
        body: updatedItem.toJson(),
        token: _token,
      );

      final data = ApiService.handleResponse(response);
      final item = ApiItem.fromJson(data['item']);

      final index = _items.indexWhere((i) => i.id == id);
      if (index != -1) {
        _items[index] = item;
      }

      print('✅ Updated item: ${item.name}');
    } catch (e) {
      print('❌ Error updating item: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete an item (vendor only)
  Future<void> deleteItem(String id) async {
    if (_token == null) {
      throw Exception('Must be logged in to delete items');
    }

    _isLoading = true;
    notifyListeners();

    try {
      await ApiService.delete('/api/items/$id', token: _token);

      _items.removeWhere((item) => item.id == id);
      print('✅ Deleted item: $id');
    } catch (e) {
      print('❌ Error deleting item: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get all items (convenience method)
  List<ApiItem> getAllItems() => items;

  /// Checkout - process cart and create orders
  Future<void> checkout(Map<ApiItem, int> cartItems) async {
    if (_token == null) {
      throw Exception('Must be logged in to checkout');
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Create an order for each item in the cart
      for (final entry in cartItems.entries) {
        final item = entry.key;
        final quantity = entry.value;

        await OrdersService.createOrder(
          token: _token!,
          itemId: item.id,
          quantity: quantity,
        );
      }

      print('✅ Checkout successful - ${cartItems.length} orders created');

      // Refresh items to get updated stock
      await fetchItems();
    } catch (e) {
      print('❌ Error during checkout: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
