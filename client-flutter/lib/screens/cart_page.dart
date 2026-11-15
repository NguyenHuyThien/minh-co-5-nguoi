import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../state/cart_controller.dart';
import '../state/cart_scope.dart';
import '../utils/currency_formatter.dart';
import '../widgets/cart_note_dialog.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _changeQuantity(CartController cart, CartItem item, int quantity) {
    try {
      cart.setQuantity(item.id, quantity);
    } on CartException catch (error) {
      _message(error.message);
    }
  }

  Future<void> _delete(CartController cart, CartItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa dòng hàng?'),
        content: Text('Xóa "${item.product.name}" khỏi giỏ hàng mẫu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            key: const ValueKey('confirm_cart_delete'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    final removal = cart.remove(item.id);
    if (removal == null) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${item.product.name}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () {
              try {
                if (!cart.restore(removal) && mounted) {
                  _message(
                    'Không thể hoàn tác dòng hàng trong phiên chợ hiện tại.',
                  );
                }
              } on CartException catch (error) {
                if (mounted) _message(error.message);
              }
            },
          ),
        ),
      );
  }

  Future<void> _editNote(CartController cart, CartItem item) async {
    final note = await showDialog<String>(
      context: context,
      builder: (_) => CartNoteDialog(initialNote: item.note),
    );
    if (!mounted || note == null) return;
    try {
      cart.updateNote(item.id, note);
    } on CartException catch (error) {
      _message(error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.maybeOf(context);
    final groups = <String, List<CartItem>>{};
    for (final item in cart?.items ?? <CartItem>[]) {
      groups.putIfAbsent(item.product.stallId, () => []).add(item);
    }
    final ordered = groups.values.expand((items) => items).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng · Demo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(16),
              itemCount: ordered.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        cart?.market?.name ?? 'Chưa chọn chợ',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Giỏ hàng và giá đều là dữ liệu mẫu. Giỏ chỉ giữ trong bộ nhớ, '
                        'sẽ mất khi khởi động lại ứng dụng.',
                      ),
                      if (ordered.isEmpty) ...[
                        const SizedBox(height: 24),
                        const Text('Giỏ hàng đang trống.'),
                      ],
                    ],
                  );
                }
                if (index == ordered.length + 1) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Tạm tính tiền hàng: ${formatVnd(cart?.totalVnd ?? 0)}',
                          key: const ValueKey('cart_total'),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chưa gồm phí dịch vụ. Không phải số tiền thanh toán chính thức; '
                          'Backend cần kiểm tra lại giá và trạng thái trước khi đặt đơn.',
                        ),
                      ],
                    ),
                  );
                }
                final item = ordered[index - 1];
                final startGroup =
                    index == 1 ||
                    ordered[index - 2].product.stallId != item.product.stallId;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (startGroup)
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 8),
                        child: Text(
                          'Gian hàng: ${item.product.stallName}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    Card(
                      key: ValueKey('cart_item_${item.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              item.product.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Giá mẫu: ${formatVnd(item.product.priceVnd)} / ${item.product.unit}',
                            ),
                            Text(
                              'Số lượng: ${item.quantity} ${item.product.unit}',
                            ),
                            Text(
                              'Ghi chú: ${item.note.isEmpty ? "Chưa có" : item.note}',
                            ),
                            Text(
                              'Thành tiền mẫu: ${formatVnd(item.subtotalVnd)}',
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                IconButton(
                                  key: ValueKey('cart_decrease_${item.id}'),
                                  tooltip: 'Giảm số lượng',
                                  onPressed: () {
                                    if (item.quantity == 1) {
                                      _delete(cart!, item);
                                    } else {
                                      _changeQuantity(
                                        cart!,
                                        item,
                                        item.quantity - 1,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                IconButton(
                                  key: ValueKey('cart_increase_${item.id}'),
                                  tooltip: 'Tăng số lượng',
                                  onPressed: () => _changeQuantity(
                                    cart!,
                                    item,
                                    item.quantity + 1,
                                  ),
                                  icon: const Icon(Icons.add),
                                ),
                                TextButton.icon(
                                  key: ValueKey('cart_note_${item.id}'),
                                  onPressed: () => _editNote(cart!, item),
                                  icon: const Icon(Icons.edit_note),
                                  label: const Text('Sửa ghi chú'),
                                ),
                                IconButton(
                                  key: ValueKey('cart_delete_${item.id}'),
                                  tooltip: 'Xóa dòng hàng',
                                  onPressed: () => _delete(cart!, item),
                                  icon: const Icon(Icons.delete_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
