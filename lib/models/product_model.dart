class ProductModel {
  final String id;
  final String name;
  final List<String> images;
  final double price;
  final double oldPrice;
  final double rating;
  final String category;
  final String description;
  final bool featured;
  final int discount;
  final bool inStock;
  final bool isBestSeller;

  ProductModel({
    required this.id,
    required this.name,
    required this.images,
    required this.price,
    required this.oldPrice,
    required this.rating,
    required this.category,
    required this.description,
    required this.featured,
    required this.discount,
    required this.inStock,
    this.isBestSeller = false,
  });

  String get image => images.isNotEmpty ? images.first : "";

  factory ProductModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ProductModel(
      id: id,
      name: data["name"] ?? "",
      images: data["images"] != null
          ? List<String>.from(data["images"])
          : data["image"] != null
              ? [data["image"]]
              : [],
      price: (data["price"] as num?)?.toDouble() ?? 0,
      oldPrice: (data["oldPrice"] as num?)?.toDouble() ??
          (data["price"] as num?)?.toDouble() ??
          0,
      rating: (data["rating"] as num?)?.toDouble() ?? 0,
      category: data["category"] ?? "",
      description: data["description"] ?? "",
      featured: data["featured"] ?? false,
      discount: data["discount"] ?? 0,
      inStock: data["inStock"] ?? true,
      isBestSeller: data["isBestSeller"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "images": images,
      "price": price,
      "oldPrice": oldPrice,
      "rating": rating,
      "category": category,
      "description": description,
      "featured": featured,
      "discount": discount,
      "inStock": inStock,
      "isBestSeller": isBestSeller,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    List<String>? images,
    double? price,
    double? oldPrice,
    double? rating,
    String? category,
    String? description,
    bool? featured,
    int? discount,
    bool? inStock,
    bool? isBestSeller,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      rating: rating ?? this.rating,
      category: category ?? this.category,
      description: description ?? this.description,
      featured: featured ?? this.featured,
      discount: discount ?? this.discount,
      inStock: inStock ?? this.inStock,
      isBestSeller: isBestSeller ?? this.isBestSeller,
    );
  }
}