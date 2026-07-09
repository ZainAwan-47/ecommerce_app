class ProductModel {
  final String id;
  final String name;
  final String image;
  final double price;
  final double rating;
  final String category;
  final String description;
  final bool featured;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.rating,
    required this.category,
    required this.description,
    required this.featured,
  });

  factory ProductModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: (data['price'] as num).toDouble(),
      rating: (data['rating'] as num).toDouble(),
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      featured: data['featured'] ?? false,
    );
  }
}