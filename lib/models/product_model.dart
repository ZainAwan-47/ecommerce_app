class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final double oldPrice;
  final double rating;
  final String category;
  final String description;
  final bool featured;
  final int discount;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.category,
    required this.description,
    required this.featured,
    required this.discount,
    required this.inStock,
  });

  factory ProductModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (data['oldPrice'] as num?)?.toDouble() ??
          (data['price'] as num?)?.toDouble() ??
          0,
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      featured: data['featured'] ?? false,
      discount: data['discount'] ?? 0,
      inStock: data['inStock'] ?? true,
    );
  }
}