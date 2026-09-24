import 'cart_controller.dart';

export 'cart_controller.dart' show CartItem, CartController;

abstract final class CartData {
  static List<CartItem> get items => CartController.instance.items;
}
