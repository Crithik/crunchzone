class CartItem {
  final int productId;
  final String name;
  final String price;
  final String image;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  double get numericPrice {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
  }

  double get totalPrice {
    return numericPrice * quantity;
  }

  CartItem copyWith({
    int? productId,
    String? name,
    String? price,
    String? image,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      quantity: quantity ?? this.quantity,
    );
  }
}