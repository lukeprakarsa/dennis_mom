class Item {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  // 👇 Optional but recommended: makes equality checks work by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Item && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
