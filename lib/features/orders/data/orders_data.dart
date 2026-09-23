import '../../../core/constants/app_assets.dart';

class OrderPreview {
  const OrderPreview({
    required this.title,
    required this.subtitle,
    required this.total,
    required this.image,
    this.orderId = '4892',
  });

  final String title;
  final String subtitle;
  final String total;
  final String image;
  final String orderId;
}

abstract final class OrdersData {
  static const activeOrder = OrderPreview(
    orderId: '4892',
    title: '1x Flat White, 1x Brioche Toast',
    subtitle: 'Oat milk • Brown sugar glaze',
    total: '\$14.99',
    image: AppAssets.orderPreview,
  );
}
