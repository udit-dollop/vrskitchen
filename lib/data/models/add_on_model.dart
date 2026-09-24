class AddOnItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imagePath;
  int quantity;

  AddOnItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imagePath,
    this.quantity = 0,
  });

  AddOnItem copyWith({int? quantity}) {
    return AddOnItem(
      id: id,
      name: name,
      description: description,
      price: price,
      imagePath: imagePath,
      quantity: quantity ?? this.quantity,
    );
  }
}
