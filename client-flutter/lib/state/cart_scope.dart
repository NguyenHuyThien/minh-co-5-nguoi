import 'package:flutter/widgets.dart';

import 'cart_controller.dart';

// Flutter SDK thuần; controller do root ứng dụng tạo và dispose.
class CartScope extends InheritedNotifier<CartController> {
  const CartScope({
    super.key,
    required CartController controller,
    required super.child,
  }) : super(notifier: controller);

  static CartController? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartScope>()?.notifier;
  }
}
