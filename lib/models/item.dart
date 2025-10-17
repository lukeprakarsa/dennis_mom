/// Represents a product in the catalog.
class Item {
  // ----------------------------
  // Instance variables (fields)
  // ----------------------------
  final String id;          // Unique identifier for the item (string for flexibility)
  final String name;        // Display name
  final String description; // Short description of the item
  final double price;       // Price in dollars
  final String imageUrl;    // Path or URL to the product image
  final int stock;          // Number of units available (0 = out of stock)

  // ----------------------------
  // Constructor
  // ----------------------------
  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock, // 👈 new required field
  });

  // ----------------------------
  // CopyWith helper
  // ----------------------------
  // Lets us create a modified copy of an Item while keeping
  // the other fields the same. Useful for editing.
  Item copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    int? stock, 
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock, //  preserve existing stock if not updated
    );
  }

  // ----------------------------
  // Equality overrides
  // ----------------------------
  // By default, Dart compares objects by memory reference,
  // meaning two Item instances with the same data would
  // still be considered different.
  //
  // Overriding == and hashCode lets us define equality
  // based on the item's unique id. This way:
  //   - Two Item objects with the same id are treated as equal
  //   - Collections like Set or Map work correctly
  //   - State management tools (e.g. Provider) can detect
  //     when items are the "same" product
  //
  // Rule of thumb: if you override ==, you must also override
  // hashCode using the same fields (here, id).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}