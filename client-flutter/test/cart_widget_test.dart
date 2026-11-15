import 'package:dichoho/main.dart';
import 'package:dichoho/models/market.dart';
import 'package:dichoho/screens/cart_page.dart';
import 'package:dichoho/screens/product_detail_page.dart';
import 'package:dichoho/screens/product_list_page.dart';
import 'package:dichoho/services/mock_market_service.dart';
import 'package:dichoho/services/mock_product_service.dart';
import 'package:dichoho/state/cart_controller.dart';
import 'package:dichoho/state/cart_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final market = MockMarketService.sampleMarkets.first;
final otherMarket = MockMarketService.sampleMarkets[1];
final product = MockProductService.sampleProducts.first;

Widget app(CartController cart, Widget home) => CartScope(
  controller: cart,
  child: MaterialApp(home: home),
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> waitForMock(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

Future<void> selectMarket(WidgetTester tester, Market selected) async {
  await tapVisible(tester, find.byKey(const ValueKey('open_market_demo')));
  await waitForMock(tester);
  await tester.tap(find.text(selected.name));
  await tester.pumpAndSettle();
}

void main() {
  late CartController cart;
  setUp(() => cart = CartController());
  tearDown(() => cart.dispose());

  testWidgets('Chi tiết thêm số lượng và ghi chú vào giỏ dùng chung', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(cart, ProductDetailPage(market: market, product: product)),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('product_quantity_increase')),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('product_cart_note')));
    await tester.enterText(
      find.byKey(const ValueKey('product_cart_note')),
      '  Rau non  ',
    );
    await tapVisible(tester, find.byKey(const ValueKey('add_to_cart')));
    expect(cart.items.single.quantity, 2);
    expect(cart.items.single.note, 'Rau non');
    expect(find.text('Đã thêm Cải xanh vào giỏ mẫu.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng · Demo'), findsOneWidget);
    expect(find.text('Ghi chú: Rau non'), findsOneWidget);
  });

  testWidgets('Sản phẩm hết hàng bị vô hiệu hóa nút thêm', (tester) async {
    await tester.pumpWidget(
      app(
        cart,
        ProductDetailPage(
          market: market,
          product: MockProductService.sampleProducts[2],
        ),
      ),
    );
    final button = find.byKey(const ValueKey('add_to_cart'));
    await tester.ensureVisible(button);
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    expect(cart.items, isEmpty);
    expect(find.textContaining('Sản phẩm mẫu đã hết hàng'), findsOneWidget);
  });

  testWidgets('Giỏ rỗng có tạm tính 0 và điều hướng Back vẫn giữ trạng thái', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(cart, ProductDetailPage(market: market, product: product)),
    );
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    expect(find.text('Giỏ hàng đang trống.'), findsOneWidget);
    expect(find.text('Tạm tính tiền hàng: 0 ₫'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('add_to_cart')));
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    expect(find.text('Cải xanh'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(cart.items.single.product.id, product.id);
  });

  testWidgets('Tăng giảm cập nhật tiền; giảm từ 1 hủy thì giữ nguyên', (
    tester,
  ) async {
    cart.add(market: market, product: product);
    final id = cart.items.single.id;
    await tester.pumpWidget(app(cart, const CartPage()));
    await tapVisible(tester, find.byKey(ValueKey('cart_increase_$id')));
    expect(cart.items.single.quantity, 2);
    await tester.ensureVisible(find.byKey(const ValueKey('cart_total')));
    expect(find.text('Tạm tính tiền hàng: 36.000 ₫'), findsOneWidget);
    await tapVisible(tester, find.byKey(ValueKey('cart_decrease_$id')));
    expect(cart.items.single.quantity, 1);
    await tapVisible(tester, find.byKey(ValueKey('cart_decrease_$id')));
    expect(find.text('Xóa dòng hàng?'), findsOneWidget);
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(cart.items.single.quantity, 1);
  });

  for (final decrease in [false, true]) {
    testWidgets(
      decrease
          ? 'Giảm từ 1 xác nhận xóa và hoàn tác'
          : 'Xóa bằng nút xóa và hoàn tác snapshot',
      (tester) async {
        cart.add(
          market: market,
          product: product,
          quantity: decrease ? 1 : 3,
          note: 'Không dập',
        );
        final before = cart.items.single;
        await tester.pumpWidget(app(cart, const CartPage()));
        await tapVisible(
          tester,
          find.byKey(
            ValueKey(
              decrease
                  ? 'cart_decrease_${before.id}'
                  : 'cart_delete_${before.id}',
            ),
          ),
        );
        await tester.tap(find.byKey(const ValueKey('confirm_cart_delete')));
        await tester.pumpAndSettle();
        expect(cart.items, isEmpty);
        expect(find.text('Giỏ hàng đang trống.'), findsOneWidget);
        await tester.tap(find.text('Hoàn tác'));
        await tester.pumpAndSettle();
        expect(cart.items.single.id, before.id);
        expect(cart.items.single.quantity, before.quantity);
        expect(cart.items.single.note, before.note);
        expect(cart.items.single.product.stallId, before.product.stallId);
      },
    );
  }

  testWidgets('Back ở hộp thoại xóa không làm mất hàng', (tester) async {
    cart.add(market: market, product: product);
    final id = cart.items.single.id;
    await tester.pumpWidget(app(cart, const CartPage()));
    await tapVisible(tester, find.byKey(ValueKey('cart_delete_$id')));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(cart.items.single.id, id);
    expect(find.text('Hoàn tác'), findsNothing);
  });

  testWidgets('Sửa ghi chú gộp số lượng, không sửa Product dùng chung', (
    tester,
  ) async {
    cart.add(market: market, product: product, quantity: 2, note: 'Xanh');
    cart.add(market: market, product: product, quantity: 3, note: 'Non');
    final edited = cart.items.last;
    await tester.pumpWidget(app(cart, const CartPage()));
    await tester.scrollUntilVisible(
      find.byKey(ValueKey('cart_note_${edited.id}')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tapVisible(tester, find.byKey(ValueKey('cart_note_${edited.id}')));
    await tester.enterText(
      find.byKey(const ValueKey('edit_cart_note')),
      ' Xanh ',
    );
    await tester.tap(find.byKey(const ValueKey('save_cart_note')));
    await tester.pumpAndSettle();
    expect(cart.items.single.id, edited.id);
    expect(cart.items.single.quantity, 5);
    expect(cart.items.single.note, 'Xanh');
    expect(cart.totalVnd, 90000);
  });

  testWidgets('Ghi chú có thể xóa trắng; Hủy sửa không đổi dữ liệu', (
    tester,
  ) async {
    cart.add(market: market, product: product, note: 'Giữ');
    final id = cart.items.single.id;
    await tester.pumpWidget(app(cart, const CartPage()));
    await tapVisible(tester, find.byKey(ValueKey('cart_note_$id')));
    await tester.enterText(find.byKey(const ValueKey('edit_cart_note')), 'Mới');
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(cart.items.single.note, 'Giữ');
    await tapVisible(tester, find.byKey(ValueKey('cart_note_$id')));
    await tester.enterText(find.byKey(const ValueKey('edit_cart_note')), '   ');
    await tester.tap(find.byKey(const ValueKey('save_cart_note')));
    await tester.pumpAndSettle();
    expect(cart.items.single.note, '');
  });

  testWidgets('Ghi chú trên màn hình nhỏ khi có bàn phím không overflow', (
    tester,
  ) async {
    cart.add(market: market, product: product);
    final id = cart.items.single.id;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(app(cart, const CartPage()));
    await tapVisible(tester, find.byKey(ValueKey('cart_note_$id')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('edit_cart_note')),
      'Ghi chú dài\nDòng thứ hai\nDòng thứ ba',
    );
    await tester.ensureVisible(find.byKey(const ValueKey('save_cart_note')));
    await tester.tap(find.byKey(const ValueKey('save_cart_note')));
    await tester.pumpAndSettle();
    expect(cart.items.single.note, contains('Dòng thứ ba'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Danh sách giỏ nhóm theo gian hàng', (tester) async {
    final other = MockProductService.sampleProducts[3];
    cart.add(market: market, product: product);
    cart.add(market: market, product: other);
    await tester.pumpWidget(app(cart, const CartPage()));
    expect(find.text('Gian hàng: ${product.stallName}'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Gian hàng: ${other.stallName}'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Gian hàng: ${other.stallName}'), findsOneWidget);
  });

  testWidgets('Đổi chợ: duyệt/Back và Hủy giữ giỏ; xác nhận mới xóa', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await selectMarket(tester, market);
    final controller = CartScope.maybeOf(
      tester.element(find.byKey(const ValueKey('selected_demo_market'))),
    )!;
    controller.add(market: market, product: product, quantity: 2, note: 'Giữ');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(const ValueKey('open_market_demo')));
    await waitForMock(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(controller.items.single.quantity, 2);

    await selectMarket(tester, otherMarket);
    expect(find.text('Đổi chợ đang mua?'), findsOneWidget);
    expect(controller.items.single.note, 'Giữ');
    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(controller.market!.id, market.id);
    expect(controller.items.single.quantity, 2);
    expect(find.text('Chợ mẫu đã chọn: ${market.name}'), findsOneWidget);

    await selectMarket(tester, otherMarket);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(controller.market!.id, market.id);
    expect(controller.items.single.quantity, 2);

    await selectMarket(tester, market);
    expect(find.text('Đổi chợ đang mua?'), findsNothing);
    expect(controller.items.single.quantity, 2);

    await selectMarket(tester, otherMarket);
    await tester.tap(find.byKey(const ValueKey('confirm_market_change')));
    await tester.pumpAndSettle();
    expect(controller.market!.id, otherMarket.id);
    expect(controller.items, isEmpty);
    expect(find.text('Chợ mẫu đã chọn: ${otherMarket.name}'), findsOneWidget);
  });

  testWidgets('Hoàn tác vẫn khôi phục khi đã Back về sản phẩm', (tester) async {
    cart.add(market: market, product: product, quantity: 2, note: 'Giữ');
    final id = cart.items.single.id;
    await tester.pumpWidget(
      app(cart, ProductDetailPage(market: market, product: product)),
    );
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.byKey(ValueKey('cart_delete_$id')));
    await tester.tap(find.byKey(const ValueKey('confirm_cart_delete')));
    await tester.pumpAndSettle();
    expect(cart.items, isEmpty);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hoàn tác'));
    await tester.pumpAndSettle();
    expect(cart.items.single.id, id);
    expect(cart.items.single.quantity, 2);
    expect(cart.items.single.note, 'Giữ');
  });
  testWidgets('Giỏ giữ dữ liệu qua danh sách → chi tiết → giỏ → Back', (
    tester,
  ) async {
    cart.selectMarket(market);
    await tester.pumpWidget(
      app(
        cart,
        ProductListPage(
          market: market,
          service: MockProductService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final row = find.byKey(ValueKey('product_${product.id}'));
    await tapVisible(tester, row);
    await tapVisible(tester, find.byKey(const ValueKey('add_to_cart')));
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    expect(cart.items, hasLength(1));
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ProductListPage), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('open_cart')));
    await tester.pumpAndSettle();
    expect(find.text('Cải xanh'), findsOneWidget);
    expect(cart.items.single.quantity, 1);
  });
}
