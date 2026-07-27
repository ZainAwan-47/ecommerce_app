class CategoryModel {
  final String id;
  final String name;

  /// URL, Firebase Storage URL, or icon key
  final String image;

  /// url | gallery | icon
  final String imageType;

  final bool featured;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.imageType,
    required this.featured,
  });

  factory CategoryModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return CategoryModel(
      id: id,
      name: data["name"] ?? "",
      image: data["image"] ?? "",

      // Backward compatibility
      imageType: data["imageType"] ?? "url",

      featured: data["featured"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "image": image,
      "imageType": imageType,
      "featured": featured,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    String? imageType,
    bool? featured,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      imageType: imageType ?? this.imageType,
      featured: featured ?? this.featured,
    );
  }
}