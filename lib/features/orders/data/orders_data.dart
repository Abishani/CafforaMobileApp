import '../../../core/constants/app_assets.dart';

class OrderPreview {
  const OrderPreview({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.image,
  });

  final String title;
  final String subtitle;
  final String total;
  final String image;
}

abstract final class OrdersData {
  static const activeOrder = OrderPreview(
    title: '1x Flat White, 1x Brioche Toast',
    subtitle: 'Oat milk • Brown sugar glaze',
    total: '\$14.99',
    image: AppAssets.orderPreview,
  );
}
