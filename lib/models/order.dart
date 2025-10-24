import 'api_item.dart';

class Order {
  final String id;
  final Customer customer;
  final ApiItem item;
  final int quantity;
  final String status; // 'pending', 'completed', 'cancelled'
  final DateTime createdAt;
  final DateTime updatedAt;

  Order({
    required this.id,
    required this.customer,
    required this.item,
    required this.quantity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] as String,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>),
      item: ApiItem.fromJson(json['item'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': item.id,
      'quantity': quantity,
    };
  }

  // Helper to get quantity remaining in stock
  int get quantityRemaining => item.stock;
}

class Customer {
  final String id;
  final String email;
  final String role;

  Customer({
    required this.id,
    required this.email,
    required this.role,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['_id'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }
}
