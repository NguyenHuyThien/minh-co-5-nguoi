import 'dart:async';

import 'package:dichoho/models/product.dart';
import 'package:dichoho/screens/market_area_page.dart';
import 'package:dichoho/screens/product_detail_page.dart';
import 'package:dichoho/screens/product_list_page.dart';
import 'package:dichoho/screens/stall_list_page.dart';
import 'package:dichoho/services/mock_market_directory_service.dart';
import 'package:dichoho/services/mock_market_service.dart';
import 'package:dichoho/services/mock_product_service.dart';
import 'package:dichoho/utils/currency_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final market = MockMarketService.sampleMarkets.first;
final otherMarket = MockMarketService.sampleMarkets[1];
final stall = MockMarketDirectoryService.sampleStalls.first;
final area = MockMarketDirectoryService.sampleAreas.first;
final product = MockProductService.sampleProducts.first;

class PendingProductService extends MockProductService {
  final completer = Completer<List<Product>>();
  int calls = 0;

  @override
  Future<List<Product>> getProducts({
    required String marketId,
    String? stallId,
  }) {
    calls++;
    return completer.future;
  }
}

class MixedProductService extends MockProductService {
  @override
  Future<List<Product>> getProducts({
    required String marketId,
    String? stallId,
  }) async => [
    product,
    Product(
      id: 'wrong-market',
      marketId: otherMarket.id,
      stallId: stall.id,
      stallName: 'Gian hàng khác chợ',
      name: 'Sản phẩm khác chợ',
      priceVnd: 10000,
      unit: 'kg',
      description: 'Mẫu',
      inStock: true,
    ),
    MockProductService.sampleProducts[3],
  ];
}

Widget screen(MockProductService service, {bool wholeMarket = false}) {
  return MaterialApp(
    home: ProductListPage(
      market: market,
      stall: wholeMarket ? null : stall,
      service: service,
    ),
  );
}

Future<void> search(WidgetTester tester, String query) async {
  final field = find.byKey(const ValueKey('product_search'));
  await tester.ensureVisible(field);
  await tester.enterText(field, query);
  await tester.pumpAndSettle();
}

void main() {
  test('Sản phẩm có gian hàng hợp lệ và lọc đúng chợ/gian hàng', () async {
    final service = MockProductService(delay: Duration.zero);
    expect(
      MockProductService.sampleProducts.map((p) => p.id).toSet().length,
      MockProductService.sampleProducts.length,
    );
    for (final selectedMarket in MockMarketService.sampleMarkets) {
      final all = await service.getProducts(marketId: selectedMarket.id);
      expect(all, hasLength(18));
      expect(all.every((p) => p.marketId == selectedMarket.id), isTrue);
      for (final selectedStall in MockMarketDirectoryService.sampleStalls.where(
        (item) => item.marketId == selectedMarket.id,
      )) {
        final products = await service.getProducts(
          marketId: selectedMarket.id,
          stallId: selectedStall.id,
        );
        expect(products, hasLength(3));
        expect(
          products.every(
            (p) =>
                p.stallId == selectedStall.id &&
                p.marketId == selectedMarket.id,
          ),
          isTrue,
        );
      }
    }
    expect(await service.getProducts(marketId: 'unknown'), isEmpty);
    expect(
      await service.getProducts(marketId: otherMarket.id, stallId: stall.id),
      isEmpty,
    );
    expect(
      await service.getProducts(marketId: market.id, stallId: 'unknown'),
      isEmpty,
    );
  });

  test('Định dạng tiền Việt Nam không mất số đồng', () {
    expect(formatVnd(0), '0 ₫');
    expect(formatVnd(18000), '18.000 ₫');
    expect(formatVnd(1000000), '1.000.000 ₫');
    expect(product.priceVnd, 18000);
    expect(product.unit, 'kg');
  });

  testWidgets(
    'Loading trước khi tải sản phẩm, tìm kiếm không gọi lại service',
    (tester) async {
      final service = PendingProductService();
      await tester.pumpWidget(screen(service));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      service.completer.complete(
        MockProductService.sampleProducts.take(3).toList(),
      );
      await tester.pumpAndSettle();
      expect(find.text('Cải xanh'), findsOneWidget);
      await search(tester, '  CÀ CHUA  ');
      expect(find.text('Cà chua'), findsOneWidget);
      expect(find.text('Cải xanh'), findsNothing);
      expect(service.calls, 1);
    },
  );

  testWidgets('Danh sách chỉ hiển thị đúng gian hàng và giá/đơn vị mẫu', (
    tester,
  ) async {
    await tester.pumpWidget(screen(MixedProductService()));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsOneWidget);
    expect(
      find.text(
        'Giá mẫu: 18.000 ₫ / kg\n'
        'Gian hàng: ${stall.name}\nCòn hàng (mẫu)',
      ),
      findsOneWidget,
    );
    expect(find.text('Sản phẩm khác chợ'), findsNothing);
    expect(
      find.byKey(
        ValueKey('product_${MockProductService.sampleProducts[3].id}'),
      ),
      findsNothing,
    );
  });

  testWidgets('Tìm trong toàn chợ không lọt sản phẩm của chợ khác', (
    tester,
  ) async {
    await tester.pumpWidget(screen(MixedProductService(), wholeMarket: true));
    await tester.pumpAndSettle();
    await search(tester, 'sản phẩm khác chợ');
    expect(find.text('Không tìm thấy sản phẩm mẫu phù hợp.'), findsOneWidget);
    expect(find.text('Sản phẩm khác chợ'), findsNothing);
    await search(tester, 'CẢI XANH');
    expect(find.text('Cải xanh'), findsWidgets);
  });

  testWidgets('Tìm không có kết quả và xóa từ khóa khôi phục danh sách', (
    tester,
  ) async {
    await tester.pumpWidget(screen(MockProductService(delay: Duration.zero)));
    await tester.pumpAndSettle();
    await search(tester, 'không tồn tại');
    expect(find.text('Không tìm thấy sản phẩm mẫu phù hợp.'), findsOneWidget);
    await tester.tap(find.byTooltip('Xóa tìm kiếm'));
    await tester.pumpAndSettle();
    expect(find.text('Cải xanh'), findsOneWidget);
    expect(find.byTooltip('Xóa tìm kiếm'), findsNothing);
  });

  testWidgets('Danh sách rỗng có thông báo', (tester) async {
    await tester.pumpWidget(
      screen(
        MockProductService(
          scenario: MockMarketScenario.empty,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa có sản phẩm mẫu trong phạm vi đã chọn.'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Lỗi tải có thử lại và giữ từ khóa tìm kiếm', (tester) async {
    await tester.pumpWidget(
      screen(
        MockProductService(
          scenario: MockMarketScenario.errorThenSuccess,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await search(tester, 'Cà chua');
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Cà chua'), findsWidgets);
    expect(find.text('Cải xanh'), findsNothing);
    expect(find.text('Thử lại'), findsNothing);
  });

  testWidgets(
    'Từ gian hàng mở danh sách và truyền đúng sản phẩm sang chi tiết',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: StallListPage(
            market: market,
            area: area,
            service: MockMarketDirectoryService(delay: Duration.zero),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(ValueKey('stall_${stall.id}')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final listPage = tester.widget<ProductListPage>(
        find.byType(ProductListPage),
      );
      expect(listPage.market.id, market.id);
      expect(listPage.stall!.id, stall.id);
      await tester.ensureVisible(find.byKey(ValueKey('product_${product.id}')));
      await tester.tap(find.byKey(ValueKey('product_${product.id}')));
      await tester.pumpAndSettle();
      final detail = tester.widget<ProductDetailPage>(
        find.byType(ProductDetailPage),
      );
      expect(identical(detail.product, product), isTrue);
      expect(detail.market.id, market.id);
      expect(find.text('Giá mẫu: 18.000 ₫ / kg'), findsOneWidget);
      expect(find.text('Đơn vị tính: kg'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ProductListPage), findsOneWidget);
    },
  );

  testWidgets('Từ khu vực mở tìm kiếm toàn chợ', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MarketAreaPage(
          market: market,
          service: MockMarketDirectoryService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open_market_product_search')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final list = tester.widget<ProductListPage>(find.byType(ProductListPage));
    expect(list.market.id, market.id);
    expect(list.stall, isNull);
    await search(tester, 'Cà chua');
    expect(find.text('Cà chua'), findsWidgets);
    expect(find.text('Tìm tên sản phẩm trong chợ này'), findsOneWidget);
  });

  testWidgets('Từ danh sách gian hàng có thể chuyển tìm kiếm toàn chợ', (
    tester,
  ) async {
    await tester.pumpWidget(screen(MockProductService(delay: Duration.zero)));
    await tester.pumpAndSettle();
    final open = find.byKey(const ValueKey('search_whole_market'));
    await tester.ensureVisible(open);
    await tester.tap(open);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final list = tester.widget<ProductListPage>(find.byType(ProductListPage));
    expect(list.market.id, market.id);
    expect(list.stall, isNull);
  });

  testWidgets('Chi tiết hiển thị hết hàng, đơn vị và placeholder ảnh', (
    tester,
  ) async {
    final unavailable = MockProductService.sampleProducts[2];
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(market: market, product: unavailable),
      ),
    );
    expect(find.text('Giá mẫu: 10.000 ₫ / bó'), findsOneWidget);
    expect(find.text('Đơn vị tính: bó'), findsOneWidget);
    expect(find.text('Hết hàng (mẫu)'), findsOneWidget);
    expect(find.text('Chưa có ảnh sản phẩm'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Thêm vào giỏ'), findsNothing);
  });

  testWidgets('Chặn gian hàng và chi tiết sản phẩm thuộc chợ khác', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductListPage(
          market: otherMarket,
          stall: stall,
          service: MockProductService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Gian hàng không thuộc chợ đã chọn. Vui lòng quay lại.'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNothing);
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(market: otherMarket, product: product),
      ),
    );
    expect(
      find.text('Sản phẩm không thuộc chợ đã chọn. Vui lòng quay lại.'),
      findsOneWidget,
    );
    expect(find.text(product.name), findsNothing);
  });

  testWidgets('Màn hình nhỏ có bàn phím vẫn tìm kiếm và cuộn được', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(screen(MockProductService(delay: Duration.zero)));
    await tester.pumpAndSettle();
    await search(tester, 'Cải');
    await tester.scrollUntilVisible(
      find.text('Cải xanh'),
      160,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cải xanh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kịch bản demo rỗng, lỗi và thử lại hoạt động', (tester) async {
    await tester.pumpWidget(MaterialApp(home: ProductListPage(market: market)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final selector = find.byType(DropdownButtonFormField<MockMarketScenario>);
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danh sách rỗng').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa có sản phẩm mẫu trong phạm vi đã chọn.'),
      findsOneWidget,
    );
    await tester.ensureVisible(selector);
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lỗi lần đầu, thử lại thành công').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Cải xanh'), findsWidgets);
  });
}
