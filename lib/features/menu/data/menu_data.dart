import '../../../core/constants/app_assets.dart';

class MenuProduct {
  const MenuProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String name;
  final String description;
  final String price;
  final String image;
}

abstract final class MenuData {
  static const products = [
    MenuProduct(
      name: 'Artisan Flat White',
      description: 'Velvety steamed milk over double ristretto',
      price: '\$4.95',
      image: AppAssets.artisanFlatWhite,
    ),
    MenuProduct(
      name: 'Vanilla Bean Cortado',
      description: 'Equal parts espresso & milk with cured pods',
      price: '\$4.50',
      image: AppAssets.vanillaBeanCortado,
    ),
    MenuProduct(
      name: 'Cascara Iced Tonic',
      description: 'Brewed coffee cherry tea, citrus botanical tonic',
      price: '\$5.50',
      image: AppAssets.cascaraIcedTonic,
    ),
    MenuProduct(
      name: 'Wild Berry Brioche Toast',
      description: 'Whipped mascarpone, forest berries, wild honey',
      price: '\$7.50',
      image: AppAssets.wildBerryBriocheToast,
    ),
    MenuProduct(
      name: 'Truffled Egg & Bagel',
      description: 'Soft scramble, black truffle butter, gruyère',
      price: '\$8.95',
      image: AppAssets.truffledEggBagel,
    ),
  ];
}
