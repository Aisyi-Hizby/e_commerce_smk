class ProductModel {
  final dynamic id;
  final String name;
  final String category;
  final num price;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.rating,
    this.reviewCount = 0,
    required this.imageUrl,
    this.description = '',
  });

  // Alias getter agar kompatibel dengan 'title' dan 'thumbnail'
  String get title => name;
  String get thumbnail => imageUrl;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['title'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] ?? json['reviews']?.length ?? 0,
      imageUrl: json['imageUrl'] ?? json['thumbnail'] ?? json['image'] ?? '',
      description: json['description'] ?? '',
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) =>
      ProductModel.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'category': category,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'imageUrl': imageUrl,
      'thumbnail': thumbnail,
      'description': description,
    };
  }
}
