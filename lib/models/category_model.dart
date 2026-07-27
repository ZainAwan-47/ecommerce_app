class CategoryModel {
  final String id;
  final String name;
  final String image;
  final bool featured;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.image,
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
      featured: data["featured"] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "image": image,
      "featured": featured,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? image,
    bool? featured,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      featured: featured ?? this.featured,
    );
  }
}