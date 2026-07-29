class CheckoutItem {
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  CheckoutItem({
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;
}