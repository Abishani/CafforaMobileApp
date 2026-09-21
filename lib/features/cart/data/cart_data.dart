import '../../../core/constants/app_assets.dart';

class CartItem {
  const CartItem({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
  });

  final String name;
  final String description;
  final double price;
  final String image;
}

abstract final class CartData {
  static const items = [
    CartItem(
      name: 'Artisan Flat White',
      description: 'Oat milk, Extra single shot',
      price: 6.35,
      image: AppAssets.cartArtisanFlatWhite,
    ),
    CartItem(
      name: 'Wild Berry Brioche Toast',
      description: 'Warm, Mascarpone on side',
      price: 7.50,
      image: AppAssets.cartWildBerryToast,
    ),
  ];
}
