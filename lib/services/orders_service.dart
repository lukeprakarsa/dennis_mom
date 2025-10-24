import 'dart:convert';
import '../models/order.dart';
import 'api_service.dart';

class OrdersService {
  /// Get all orders (vendors see all, customers see their own)
  static Future<List<Order>> getOrders(String token) async {
    try {
      final response = await ApiService.get('/api/orders', token: token);

      // The response body should be a JSON array
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => Order.fromJson(json as Map<String, dynamic>)).toList();
      } else {
        throw ApiException('Failed to fetch orders', statusCode: response.statusCode);
      }
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Create a new order
  static Future<Order> createOrder({
    required String token,
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/orders',
        token: token,
        body: {
          'itemId': itemId,
          'quantity': quantity,
        },
      );

      final data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Update order status (vendors only)
  static Future<Order> updateOrderStatus({
    required String token,
    required String orderId,
    required String status,
  }) async {
    try {
      final response = await ApiService.patch(
        '/api/orders/$orderId',
        token: token,
        body: {'status': status},
      );

      final data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}
