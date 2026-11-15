import 'package:dichoho/models/product.dart';
import 'package:dichoho/services/mock_market_service.dart';
import 'package:dichoho/services/mock_product_service.dart';
import 'package:dichoho/state/cart_controller.dart';
import 'package:flutter_test/flutter_test.dart';

final market = MockMarketService.sampleMarkets.first;
final otherMarket = MockMarketService.sampleMarkets[1];
final product = MockProductService.sampleProducts.first;
final otherStallProduct = MockProductService.sampleProducts[3];
final unavailable = MockProductService.sampleProducts[2];
final otherMarketProduct = MockProductService.sampleProducts.firstWhere(
  (item) => item.marketId == otherMarket.id,
);

void main() {
  late CartController cart;
  setUp(() => cart = CartController());
  tearDown(() => cart.dispose());

  test('Thêm hợp lệ, ID dòng riêng và snapshot Product không bị sửa', () {
    cart.add(market: market, product: product, note: '  Không dập  ');
    final item = cart.items.single;
    expect(item.quantity, 1);
    expect(item.note, 'Không dập');
    expect(item.id, isNot(product.id));
    expect(identical(item.product, product), isTrue);
    expect(cart.market!.id, market.id);
  });

  test('Chặn hết hàng, sai chợ truyền vào và số lượng không dương', () {
    expect(
      () => cart.add(market: market, product: unavailable),
      throwsA(isA<CartException>()),
    );
    expect(
      () => cart.add(market: otherMarket, product: product),
      throwsA(isA<CartException>()),
    );
    for (final quantity in [0, -1]) {
      expect(
        () => cart.add(market: market, product: product, quantity: quantity),
        throwsA(isA<CartException>()),
      );
    }
    expect(cart.items, isEmpty);
    expect(cart.market, isNull);
  });

  test('Nhiều gian hàng cùng chợ và tổng tiền đúng', () {
    cart.add(market: market, product: product, quantity: 2);
    cart.add(market: market, product: otherStallProduct, quantity: 3);
    expect(
      cart.items.map((item) => item.product.stallId).toSet(),
      hasLength(2),
    );
    expect(cart.totalVnd, 90000);
    expect(
      cart.items.every((item) => item.product.marketId == market.id),
      isTrue,
    );
  });

  test('Không gộp theo tên và không trộn hai chợ', () {
    expect(product.name, otherStallProduct.name);
    cart.add(market: market, product: product);
    cart.add(market: market, product: otherStallProduct);
    expect(cart.items, hasLength(2));
    expect(
      () => cart.add(market: otherMarket, product: otherMarketProduct),
      throwsA(isA<CartException>()),
    );
    expect(cart.items, hasLength(2));
    expect(cart.market!.id, market.id);
  });

  test('Giỏ rỗng cho đổi chợ; chọn lại chợ đang mua giữ nguyên giỏ', () {
    cart.selectMarket(market);
    cart.selectMarket(otherMarket);
    expect(cart.market!.id, otherMarket.id);
    cart.selectMarket(market);
    cart.add(market: market, product: product);
    final id = cart.items.single.id;
    cart.selectMarket(market, clearExisting: true);
    expect(cart.items.single.id, id);
    expect(cart.needsMarketChangeConfirmation(market), isFalse);
  });

  test('Đổi chợ khi có hàng phải xác nhận, không tự xóa', () {
    cart.add(market: market, product: product, quantity: 2, note: 'Giữ nguyên');
    expect(cart.needsMarketChangeConfirmation(otherMarket), isTrue);
    expect(() => cart.selectMarket(otherMarket), throwsA(isA<CartException>()));
    expect(cart.market!.id, market.id);
    expect(cart.items.single.quantity, 2);
    expect(cart.items.single.note, 'Giữ nguyên');
    cart.selectMarket(otherMarket, clearExisting: true);
    expect(cart.market!.id, otherMarket.id);
    expect(cart.items, isEmpty);
    expect(cart.totalVnd, 0);
  });

  test('Cùng ID và ghi chú trim thì gộp, khác ghi chú thì giữ riêng', () {
    cart.add(
      market: market,
      product: product,
      quantity: 2,
      note: '  Chọn xanh ',
    );
    final id = cart.items.single.id;
    cart.add(market: market, product: product, quantity: 3, note: 'Chọn xanh');
    expect(cart.items.single.id, id);
    expect(cart.items.single.quantity, 5);
    cart.add(market: market, product: product, note: 'Chọn non');
    expect(cart.items, hasLength(2));
    expect(cart.items.map((item) => item.id).toSet(), hasLength(2));
    expect(cart.totalVnd, 108000);
  });

  test('Sửa ghi chú trùng gộp đủ số lượng và giữ ID dòng đang sửa', () {
    cart.add(market: market, product: product, quantity: 2, note: 'Xanh');
    final firstId = cart.items.single.id;
    cart.add(market: market, product: product, quantity: 3, note: 'Non');
    final editedId = cart.items.last.id;
    cart.updateNote(editedId, ' Xanh ');
    expect(cart.items.single.id, editedId);
    expect(cart.items.single.quantity, 5);
    expect(cart.items.single.note, 'Xanh');
    expect(cart.itemById(firstId), isNull);
    expect(cart.totalVnd, 90000);
  });

  test('Sửa, xóa ghi chú chỉ ảnh hưởng dòng tương ứng', () {
    cart.add(market: market, product: product, note: 'Xanh');
    cart.add(market: market, product: otherStallProduct, note: 'Non');
    final editedId = cart.items.first.id;
    cart.updateNote(editedId, '  ');
    expect(cart.items.first.note, '');
    expect(cart.items.last.note, 'Non');
  });

  test('Tăng giảm đơn vị nguyên, chặn 0 và không áp giới hạn 99', () {
    cart.add(market: market, product: product);
    final id = cart.items.single.id;
    cart.setQuantity(id, 150);
    expect(cart.items.single.quantity, 150);
    cart.setQuantity(id, 149);
    expect(cart.totalVnd, 149 * product.priceVnd);
    expect(() => cart.setQuantity(id, 0), throwsA(isA<CartException>()));
    expect(cart.items.single.quantity, 149);
  });

  test('Xóa và hoàn tác đúng ID, số lượng, ghi chú, gian hàng và vị trí', () {
    cart.add(market: market, product: product, quantity: 2, note: 'Đầu');
    cart.add(
      market: market,
      product: otherStallProduct,
      quantity: 3,
      note: 'Giữa',
    );
    cart.add(market: market, product: product, quantity: 4, note: 'Cuối');
    final before = cart.items;
    final removal = cart.remove(before[1].id)!;
    expect(cart.items, hasLength(2));
    expect(cart.restore(removal), isTrue);
    expect(cart.items.map((item) => item.id), before.map((item) => item.id));
    expect(cart.items[1].quantity, 3);
    expect(cart.items[1].note, 'Giữa');
    expect(cart.items[1].product.stallId, otherStallProduct.stallId);
    expect(cart.restore(removal), isFalse);
  });

  test(
    'Hoàn tác khi đã thêm lại dòng trùng giữ ID cũ và không mất số lượng',
    () {
      cart.add(market: market, product: product, quantity: 2, note: 'Xanh');
      final originalId = cart.items.single.id;
      final removal = cart.remove(originalId)!;
      cart.add(market: market, product: product, quantity: 3, note: 'Xanh');
      expect(cart.restore(removal), isTrue);
      expect(cart.items.single.id, originalId);
      expect(cart.items.single.quantity, 5);
    },
  );

  test('Hoàn tác không phục hồi giỏ cũ sau đổi chợ, kể cả đổi về lại', () {
    cart.add(market: market, product: product);
    final removal = cart.remove(cart.items.single.id)!;
    cart.selectMarket(otherMarket);
    expect(cart.restore(removal), isFalse);
    cart.selectMarket(market);
    expect(cart.restore(removal), isFalse);
    expect(cart.items, isEmpty);
  });

  test(
    'Giới hạn kỹ thuật kiểm tra trước phép nhân, không thay đổi giỏ khi lỗi',
    () {
      cart.add(market: market, product: product);
      final id = cart.items.single.id;
      expect(
        () => cart.setQuantity(id, CartController.maxExactInteger),
        throwsA(isA<CartException>()),
      );
      expect(cart.items.single.quantity, 1);
      expect(cart.totalVnd, 18000);
      const zeroPrice = Product(
        id: 'zero',
        marketId: 'mock-market-1',
        stallId: 'sample',
        stallName: 'Mẫu',
        name: 'Miễn phí mẫu',
        priceVnd: 0,
        unit: 'gói',
        description: 'Mẫu',
        inStock: true,
      );
      cart.add(
        market: market,
        product: zeroPrice,
        quantity: CartController.maxExactInteger,
      );
      expect(
        () => cart.add(market: market, product: zeroPrice),
        throwsA(isA<CartException>()),
      );
      expect(cart.items.last.quantity, CartController.maxExactInteger);
    },
  );

  test('Phiếu hoàn tác chỉ thuộc giỏ đã tạo ra nó', () {
    cart.add(market: market, product: product);
    final removal = cart.remove(cart.items.single.id)!;
    final otherCart = CartController();
    otherCart.add(market: market, product: product);
    expect(otherCart.restore(removal), isFalse);
    expect(otherCart.items.single.quantity, 1);
    otherCart.dispose();
    expect(cart.restore(removal), isTrue);
  });
  test('Danh sách giỏ là chỉ đọc đối với bên ngoài', () {
    cart.add(market: market, product: product);
    expect(() => cart.items.clear(), throwsUnsupportedError);
    expect(cart.items, hasLength(1));
  });
}
