import 'package:flutter/material.dart';

import '../models/market.dart';
import '../models/product.dart';
import '../utils/currency_formatter.dart';
import '../widgets/demo_list_widgets.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    super.key,
    required this.market,
    required this.product,
  });

  final Market market;
  final Product product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm · Demo')),
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
                        const Text(
                          'Demo chỉ xem thông tin; chưa thêm vào giỏ hoặc đặt đơn.',
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
