import 'package:flutter/material.dart';

import '../models/market.dart';
import '../models/product.dart';
import '../utils/currency_formatter.dart';
import '../widgets/demo_list_widgets.dart';
import '../state/cart_controller.dart';
import '../state/cart_scope.dart';
import '../widgets/cart_button.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({
    super.key,
    required this.market,
    required this.product,
  });

  final Market market;
  final Product product;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _noteController = TextEditingController();
  int _quantity = 1;

  Market get market => widget.market;
  Product get product => widget.product;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addToCart() {
    final cart = CartScope.maybeOf(context);
    if (cart == null) return;
    try {
      cart.add(
        market: market,
        product: product,
        quantity: _quantity,
        note: _noteController.text,
      );
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Đã thêm ${product.name} vào giỏ mẫu.')),
        );
    } on CartException catch (error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = CartScope.maybeOf(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm · Demo'),
        actions: const [CartButton()],
      ),
      body: product.marketId != market.id
          ? const DemoListMessage(
              text: 'Sản phẩm không thuộc chợ đã chọn. Vui lòng quay lại.',
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Dữ liệu mẫu · Giá minh họa, không phải giá thực tế từ chợ.',
                        ),
                        const SizedBox(height: 24),
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 96,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Chưa có ảnh sản phẩm',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          product.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Giá mẫu: ${formatVnd(product.priceVnd)} / ${product.unit}',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text('Đơn vị tính: ${product.unit}'),
                        const SizedBox(height: 8),
                        Text(
                          product.inStock ? 'Còn hàng (mẫu)' : 'Hết hàng (mẫu)',
                        ),
                        const Divider(height: 32),
                        Text('Chợ: ${market.name}'),
                        const SizedBox(height: 8),
                        Text('Gian hàng: ${product.stallName}'),
                        const SizedBox(height: 24),
                        Text('Mô tả', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(product.description),
                        const SizedBox(height: 24),
                        Text(
                          'Số lượng nguyên (demo)',
                          style: theme.textTheme.titleMedium,
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 12,
                          children: [
                            IconButton(
                              key: const ValueKey('product_quantity_decrease'),
                              tooltip: 'Giảm số lượng',
                              onPressed: _quantity > 1
                                  ? () => setState(() => _quantity--)
                                  : null,
                              icon: const Icon(Icons.remove),
                            ),
                            Text(
                              '$_quantity ${product.unit}',
                              key: const ValueKey('product_quantity'),
                            ),
                            IconButton(
                              key: const ValueKey('product_quantity_increase'),
                              tooltip: 'Tăng số lượng',
                              onPressed:
                                  _quantity < CartController.maxExactInteger
                                  ? () => setState(() => _quantity++)
                                  : null,
                              icon: const Icon(Icons.add),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const ValueKey('product_cart_note'),
                          controller: _noteController,
                          minLines: 1,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Ghi chú cho dòng hàng',
                            hintText: 'Ví dụ: chọn rau không dập',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const ValueKey('add_to_cart'),
                          onPressed: product.inStock && cart != null
                              ? _addToCart
                              : null,
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Thêm vào giỏ'),
                        ),
                        if (!product.inStock) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Sản phẩm mẫu đã hết hàng, không thể thêm vào giỏ.',
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Giỏ chỉ giữ trong bộ nhớ và mất khi khởi động lại ứng dụng. '
                          'Giá và tạm tính là dữ liệu mẫu; chưa đặt đơn hoặc thanh toán.',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
