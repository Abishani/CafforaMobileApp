import 'package:flutter/foundation.dart';
import '../../../core/constants/app_assets.dart';

class MenuProduct {
  const MenuProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.category = 'Coffee',
    this.isCustom = false,
  });

  final String name;
  final String description;
  final String price;
  /// For built-in items this is an asset path; for custom items this is an emoji string.
  final String image;
  final String category;
  /// True when this item was added by an admin at runtime.
  final bool isCustom;
}

abstract final class MenuData {
  static final _extraProducts = <MenuProduct>[];

  /// All products: built-in + admin-added ones.
  static List<MenuProduct> get products => [
        ..._builtIn,
        ..._extraProducts,
      ];

  /// Notifier that fires whenever a new item is added.
  static final productsNotifier = ValueNotifier<int>(0);

  static void addProduct(MenuProduct product) {
    _extraProducts.add(product);
    productsNotifier.value++;
  }

  static const _builtIn = [
    MenuProduct(
      name: 'Artisan Flat White',
      description: 'Velvety steamed milk over double ristretto',
      price: '\$4.95',
      image: AppAssets.artisanFlatWhite,
      category: 'Coffee',
    ),
    MenuProduct(
      name: 'Vanilla Bean Cortado',
      description: 'Equal parts espresso & milk with cured pods',
      price: '\$4.50',
      image: AppAssets.vanillaBeanCortado,
      category: 'Coffee',
    ),
    MenuProduct(
      name: 'Cascara Iced Tonic',
      description: 'Brewed coffee cherry tea, citrus botanical tonic',
      price: '\$5.50',
      image: AppAssets.cascaraIcedTonic,
      category: 'Tea',
    ),
    MenuProduct(
      name: 'Wild Berry Brioche Toast',
      description: 'Whipped mascarpone, forest berries, wild honey',
      price: '\$7.50',
      image: AppAssets.wildBerryBriocheToast,
      category: 'Pastries',
    ),
    MenuProduct(
      name: 'Truffled Egg & Bagel',
      description: 'Soft scramble, black truffle butter, gruyère',
      price: '\$8.95',
      image: AppAssets.truffledEggBagel,
      category: 'Brunch',
    ),
  ];
}
