import 'package:flutter/foundation.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/models/product_models.dart';
import '../../../core/network/api_client.dart';

class MenuProduct {
  const MenuProduct({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.category = 'Coffee',
    this.isCustom = false,
    this.rawPrice,
    this.categoryId,
    this.calories,
  });

  final int? id;
  final String name;
  final String description;
  final String price;

  /// For built-in items this is an asset path; for custom items this is an emoji string or network URL.
  final String image;
  final String category;
  final bool isCustom;
  final double? rawPrice;
  final int? categoryId;
  final int? calories;

  double get numericPrice {
    if (rawPrice != null) return rawPrice!;
    final clean = price.replaceAll('\$', '').trim();
    return double.tryParse(clean) ?? 0.0;
  }

  factory MenuProduct.fromResponse(ProductResponse p) {
    return MenuProduct(
      id: p.id,
      name: p.name,
      description: p.description,
      price: '\$${p.price.toStringAsFixed(2)}',
      rawPrice: p.price,
      image: p.imageUrl != null && p.imageUrl!.isNotEmpty
          ? p.imageUrl!
          : _imageForCategory(p.categoryName ?? ''),
      category: p.categoryName ?? 'Coffee',
      categoryId: p.categoryId,
      calories: p.calories,
      isCustom: false,
    );
  }

  static String _imageForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('beverage') || lower.contains('coffee')) {
      return AppAssets.artisanFlatWhite;
    } else if (lower.contains('snack') || lower.contains('pastr')) {
      return AppAssets.wildBerryBriocheToast;
    } else if (lower.contains('meal') || lower.contains('brunch')) {
      return AppAssets.truffledEggBagel;
    } else if (lower.contains('tea')) {
      return AppAssets.cascaraIcedTonic;
    } else if (lower.contains('dessert')) {
      return AppAssets.vanillaBeanCortado;
    }
    return AppAssets.artisanFlatWhite;
  }
}

abstract final class MenuData {
  static final _remoteProducts = <MenuProduct>[];
  static final _extraProducts = <MenuProduct>[];
  static final _categories = <CategoryResponse>[];

  static final productsNotifier = ValueNotifier<int>(0);

  /// All products: remote products from Spring Boot (or built-in fallback) + admin-added items.
  static List<MenuProduct> get products {
    if (_remoteProducts.isNotEmpty) {
      return [..._remoteProducts, ..._extraProducts];
    }
    return [..._builtIn, ..._extraProducts];
  }

  static List<CategoryResponse> get categories => List.unmodifiable(_categories);

  /// Fetches live products from Spring Boot backend `GET /api/products`.
  static Future<List<MenuProduct>> loadProducts({int? categoryId, String? search}) async {
    try {
      final query = <String, dynamic>{};
      if (categoryId != null) query['categoryId'] = categoryId;
      if (search != null && search.isNotEmpty) query['search'] = search;

      final data = await ApiClient.instance.get('/api/products', queryParameters: query);
      if (data is List) {
        final list = data
            .map((item) => MenuProduct.fromResponse(ProductResponse.fromJson(item as Map<String, dynamic>)))
            .toList();

        if (categoryId == null && (search == null || search.isEmpty)) {
          _remoteProducts.clear();
          _remoteProducts.addAll(list);
          productsNotifier.value++;
        }
        return list;
      }
    } catch (_) {}
    return products;
  }

  /// Fetches live categories from Spring Boot backend `GET /api/categories`.
  static Future<List<CategoryResponse>> loadCategories() async {
    try {
      final data = await ApiClient.instance.get('/api/categories');
      if (data is List) {
        _categories.clear();
        _categories.addAll(
          data.map((c) => CategoryResponse.fromJson(c as Map<String, dynamic>)),
        );
      }
    } catch (_) {}
    return _categories;
  }

  /// Admin creates a product via Spring Boot `POST /api/products`.
  static Future<MenuProduct> createProduct({
    required String name,
    required String description,
    required double price,
    required int categoryId,
    String? categoryName,
    int? calories,
    String? imageUrl,
  }) async {
    final req = ProductRequest(
      name: name,
      description: description,
      price: price,
      categoryId: categoryId,
      calories: calories,
      imageUrl: imageUrl,
    );

    try {
      final data = await ApiClient.instance.post(
        '/api/products',
        body: req.toJson(),
        requiresAuth: true,
      );

      if (data is Map<String, dynamic>) {
        final response = ProductResponse.fromJson(data);
        final newProduct = MenuProduct.fromResponse(response);
        _remoteProducts.add(newProduct);
        productsNotifier.value++;
        return newProduct;
      }
    } catch (_) {}

    // Fallback local addition if network fails
    final fallbackProduct = MenuProduct(
      name: name,
      description: description,
      price: '\$${price.toStringAsFixed(2)}',
      rawPrice: price,
      image: (imageUrl != null && imageUrl.isNotEmpty) ? imageUrl : '☕',
      category: categoryName ?? 'Coffee',
      categoryId: categoryId,
      isCustom: true,
    );
    _extraProducts.add(fallbackProduct);
    productsNotifier.value++;
    return fallbackProduct;
  }

  static void addProduct(MenuProduct product) {
    _extraProducts.add(product);
    productsNotifier.value++;
  }

  static const _builtIn = [
    MenuProduct(
      id: 1,
      name: 'Artisan Flat White',
      description: 'Velvety steamed milk over double ristretto',
      price: '\$4.95',
      rawPrice: 4.95,
      image: AppAssets.artisanFlatWhite,
      category: 'Beverages',
    ),
    MenuProduct(
      id: 2,
      name: 'Vanilla Bean Cortado',
      description: 'Equal parts espresso & milk with cured pods',
      price: '\$4.50',
      rawPrice: 4.50,
      image: AppAssets.vanillaBeanCortado,
      category: 'Beverages',
    ),
    MenuProduct(
      id: 3,
      name: 'Cascara Iced Tonic',
      description: 'Brewed coffee cherry tea, citrus botanical tonic',
      price: '\$5.50',
      rawPrice: 5.50,
      image: AppAssets.cascaraIcedTonic,
      category: 'Beverages',
    ),
    MenuProduct(
      id: 4,
      name: 'Wild Berry Brioche Toast',
      description: 'Whipped mascarpone, forest berries, wild honey',
      price: '\$7.50',
      rawPrice: 7.50,
      image: AppAssets.wildBerryBriocheToast,
      category: 'Pastries',
    ),
    MenuProduct(
      id: 5,
      name: 'Truffled Egg & Bagel',
      description: 'Soft scramble, black truffle butter, gruyère',
      price: '\$8.95',
      rawPrice: 8.95,
      image: AppAssets.truffledEggBagel,
      category: 'Meals',
    ),
  ];
}
