/// Item model that works with API (doesn't use Realm)
class ApiItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;

  ApiItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
  });

  factory ApiItem.fromJson(Map<String, dynamic> json) {
    return ApiItem(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'stock': stock,
    };
  }

  ApiItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
  }) {
    return ApiItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ApiItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ApiItem(id: $id, name: $name, price: $price, stock: $stock)';
}
