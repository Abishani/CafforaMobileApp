class HomeProduct {
  const HomeProduct({
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    this.rating,
    this.badge,
  });

  final String name;
  final String description;
  final String price;
  final String image;
  final String? rating;
  final String? badge;
}

abstract final class HomeData {
  static const drinks = [
    HomeProduct(
      name: 'Caramel Oat Latte',
      description: 'Espresso, oat milk,...',
      price: '\$5.75',
      image: 'assets/images/caramel_oat_latte.jpeg',
      rating: '4.9',
    ),
    HomeProduct(
      name: 'Cardamom Cold Brew',
      description: '18hr slow brew, spices',
      price: '\$5.25',
      image: 'assets/images/cardamom_cold_brew.jpeg',
      rating: '4.8',
    ),
  ];

  static const bakery = [
    HomeProduct(
      name: 'Almond Croissant',
      description: 'Almond frangipane, flakes',
      price: '\$4.50',
      image: 'assets/images/almond_croissant.jpeg',
      badge: 'Warm',
    ),
    HomeProduct(
      name: 'Matcha Pistachio',
      description: 'Brioche, Uji matcha glaze',
      price: '\$6.25',
      image: 'assets/images/matcha_pistachio.jpeg',
      badge: 'Fresh',
    ),
  ];
}
