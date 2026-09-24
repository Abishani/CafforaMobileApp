class CategoryResponse {
  const CategoryResponse({
    required this.id,
    required this.name,
    this.description,
  });

  final int id;
  final String name;
  final String? description;

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class ProductResponse {
  const ProductResponse({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.categoryId,
    this.categoryName,
    this.calories,
    this.imageUrl,
    this.status = 'AVAILABLE',
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int? categoryId;
  final String? categoryName;
  final int? calories;
  final String? imageUrl;
  final String status;

  bool get isAvailable => status.toUpperCase() == 'AVAILABLE';

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      categoryId: (json['categoryId'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      calories: (json['calories'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      status: json['status'] as String? ?? 'AVAILABLE',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'categoryName': categoryName,
        if (calories != null) 'calories': calories,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'status': status,
      };
}

class ProductRequest {
  const ProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    this.calories,
    this.imageUrl,
    this.status = 'AVAILABLE',
  });

  final String name;
  final String description;
  final double price;
  final int categoryId;
  final int? calories;
  final String? imageUrl;
  final String status;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        if (calories != null) 'calories': calories,
        if (imageUrl != null) 'imageUrl': imageUrl,
        'status': status,
      };
}
