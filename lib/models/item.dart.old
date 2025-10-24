import 'package:realm/realm.dart';

part 'item.realm.dart';

/// Represents a product in the catalog.
@RealmModel()
class _Item {
  // ----------------------------
  // Instance variables (fields)
  // ----------------------------
  @PrimaryKey()
  late String id; // Unique identifier for the item (string for flexibility)
  late String name; // Display name
  late String description; // Short description of the item
  late double price; // Price in dollars
  late String imageUrl; // Path or URL to the product image
  late int stock; // Number of units available (0 = out of stock)
}

// ----------------------------
// Extension methods for Item
// ----------------------------
extension ItemExtensions on Item {
  // CopyWith helper for editing items
  // Creates a new Item with updated fields while preserving others
  Item copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock,
  }) {
    return Item(
      id ?? this.id,
      name ?? this.name,
      description ?? this.description,
      price ?? this.price,
      imageUrl ?? this.imageUrl,
      stock ?? this.stock,
    );
  }
}
