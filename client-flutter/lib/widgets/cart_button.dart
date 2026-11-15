import 'package:flutter/material.dart';

import '../screens/cart_page.dart';
import '../state/cart_scope.dart';

class CartButton extends StatelessWidget {
  const CartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.maybeOf(context);
    return IconButton(
      key: const ValueKey('open_cart'),
      tooltip: 'Giỏ hàng mẫu',
      onPressed: cart == null
          ? null
          : () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(builder: (_) => const CartPage()),
            ),
      icon: Badge(
        label: Text('${cart?.items.length ?? 0}'),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
