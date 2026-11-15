import 'package:flutter/material.dart';

import '../models/market.dart';
import '../models/product.dart';
import '../models/stall.dart';
import '../services/mock_market_service.dart';
import '../services/mock_product_service.dart';
import '../utils/currency_formatter.dart';
import '../widgets/demo_list_widgets.dart';
import '../widgets/cart_button.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({
    super.key,
    required this.market,
    this.stall,
    this.service,
  });

  final Market market;
  // Không truyền gian hàng: tìm trong toàn chợ đã chọn.
  final Stall? stall;
  final MockProductService? service;

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _searchController = TextEditingController();
  late MockProductService _service;
  late Future<List<Product>> _products;
  MockMarketScenario _scenario = MockMarketScenario.data;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MockProductService();
    _products = _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Product>> _loadProducts() async {
    if (widget.stall != null && widget.stall!.marketId != widget.market.id) {
      return const [];
    }
    final products = await _service.getProducts(
      marketId: widget.market.id,
      stallId: widget.stall?.id,
    );
    return products
        .where(
          (product) =>
              product.marketId == widget.market.id &&
              (widget.stall == null || product.stallId == widget.stall!.id),
        )
        .toList();
  }

  void _retry() {
    setState(() {
      _products = _loadProducts();
    });
  }

  void _changeScenario(MockMarketScenario? scenario) {
    if (scenario == null) return;
    setState(() {
      _scenario = scenario;
      _service = MockProductService(scenario: scenario);
      _products = _loadProducts();
    });
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.market.name,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (widget.stall != null) ...[
            const SizedBox(height: 8),
            Text(widget.stall!.name),
          ],
          const SizedBox(height: 8),
          const Text(
            'Dữ liệu mẫu · Giá minh họa, không phải giá thực tế từ chợ.',
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('product_search'),
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            decoration: InputDecoration(
              labelText: widget.stall == null
                  ? 'Tìm tên sản phẩm trong chợ này'
                  : 'Tìm tên sản phẩm trong gian hàng này',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Xóa tìm kiếm',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
          if (widget.stall != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              key: const ValueKey('search_whole_market'),
              onPressed: () {
                FocusScope.of(context).unfocus();
                Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) =>
                        ProductListPage(market: widget.market),
                  ),
                );
              },
              icon: const Icon(Icons.manage_search),
              label: const Text('Tìm sản phẩm trong toàn chợ'),
            ),
          ],
          if (widget.service == null) ...[
            const SizedBox(height: 16),
            DemoScenarioSelector(
              scenario: _scenario,
              onChanged: _changeScenario,
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: const [CartButton()],
        title: Text(
          widget.stall == null ? 'Tìm sản phẩm · Demo' : 'Sản phẩm · Demo',
        ),
      ),
      body: widget.stall != null && widget.stall!.marketId != widget.market.id
          ? const DemoListMessage(
              text: 'Gian hàng không thuộc chợ đã chọn. Vui lòng quay lại.',
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: FutureBuilder<List<Product>>(
                    future: _products,
                    builder: (context, snapshot) {
                      final loading =
                          snapshot.connectionState != ConnectionState.done;
                      final query = _query.trim().toLowerCase();
                      final products = (snapshot.data ?? const <Product>[])
                          .where(
                            (product) =>
                                product.name.toLowerCase().contains(query),
                          )
                          .toList();
                      // Phần tìm kiếm và danh sách cùng cuộn để không tràn
                      // khi bàn phím mở trên màn hình nhỏ.
                      return ListView.builder(
                        key: const ValueKey('product_list'),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount:
                            loading || snapshot.hasError || products.isEmpty
                            ? 2
                            : products.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) return _header();
                          if (loading) {
                            return const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (snapshot.hasError) {
                            return DemoListMessage(
                              text:
                                  'Không tải được sản phẩm mẫu. Vui lòng thử lại.',
                              onRetry: _retry,
                            );
                          }
                          if (products.isEmpty) {
                            return DemoListMessage(
                              text: query.isEmpty
                                  ? 'Chưa có sản phẩm mẫu trong phạm vi đã chọn.'
                                  : 'Không tìm thấy sản phẩm mẫu phù hợp.',
                            );
                          }
                          final product = products[index - 1];
                          return Card(
                            margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                            child: ListTile(
                              key: ValueKey('product_${product.id}'),
                              contentPadding: const EdgeInsets.all(16),
                              leading: Icon(
                                Icons.inventory_2_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                'Giá mẫu: ${formatVnd(product.priceVnd)} / ${product.unit}\n'
                                'Gian hàng: ${product.stallName}\n'
                                '${product.inStock ? "Còn hàng (mẫu)" : "Hết hàng (mẫu)"}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                Navigator.push<void>(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) => ProductDetailPage(
                                      market: widget.market,
                                      product: product,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
