import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/market.dart';
import '../models/product.dart';

class CartException implements Exception {
  const CartException(this.message);
  final String message;
}

// Phiếu hoàn tác chỉ dùng một lần và chỉ trong cùng phiên chọn chợ.
class CartRemoval {
  CartRemoval._(this.item, this.index, this._generation, this._owner);
  final CartItem item;
  final int index;
  final int _generation;
  final CartController _owner;
  bool _restored = false;
}

class CartController extends ChangeNotifier {
  // Giới hạn kỹ thuật số nguyên chính xác, kể cả nếu chạy bằng Dart trên web.
  // Không phải giới hạn mua hàng hoặc tồn kho.
  static const maxExactInteger = 9007199254740991;
  final List<CartItem> _items = [];
  Market? _market;
  int _nextId = 0;
  int _generation = 0;

  Market? get market => _market;
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalVnd => _items.fold(0, (total, item) => total + item.subtotalVnd);

  CartItem? itemById(String id) {
    for (final item in _items) {
      if (item.id == id) return item;
    }
    return null;
  }

  bool needsMarketChangeConfirmation(Market market) {
    return _items.isNotEmpty && _market?.id != market.id;
  }

  void selectMarket(Market market, {bool clearExisting = false}) {
    if (_market?.id == market.id) return;
    if (needsMarketChangeConfirmation(market) && !clearExisting) {
      throw const CartException('Cần xác nhận đổi chợ và xóa giỏ cũ.');
    }
    _items.clear();
    _generation++;
    _market = market;
    notifyListeners();
  }

  void _validate(List<CartItem> items) {
    final limit = BigInt.from(maxExactInteger);
    var total = BigInt.zero;
    for (final item in items) {
      if (item.quantity <= 0) {
        throw const CartException('Số lượng phải là số nguyên dương.');
      }
      if (item.product.priceVnd < 0) {
        throw const CartException('Giá mẫu không hợp lệ.');
      }
      if (BigInt.from(item.quantity) > limit) {
        throw const CartException(
          'Số lượng vượt giới hạn số nguyên chính xác.',
        );
      }
      total += BigInt.from(item.product.priceVnd) * BigInt.from(item.quantity);
      if (total > limit) {
        throw const CartException(
          'Tạm tính vượt giới hạn số nguyên chính xác.',
        );
      }
    }
  }

  int _sumQuantity(int first, int second) {
    final sum = BigInt.from(first) + BigInt.from(second);
    if (sum > BigInt.from(maxExactInteger)) {
      throw const CartException('Số lượng vượt giới hạn số nguyên chính xác.');
    }
    return sum.toInt();
  }

  void _replaceItems(List<CartItem> items) {
    _validate(items);
    _items
      ..clear()
      ..addAll(items);
    notifyListeners();
  }

  void add({
    required Market market,
    required Product product,
    int quantity = 1,
    String note = '',
  }) {
    if (product.marketId != market.id ||
        (_market != null && _market!.id != market.id)) {
      throw const CartException(
        'Sản phẩm không thuộc chợ đang mua. Hãy chọn lại chợ.',
      );
    }
    if (!product.inStock) {
      throw const CartException(
        'Sản phẩm mẫu đã hết hàng, không thể thêm vào giỏ.',
      );
    }
    if (quantity <= 0) {
      throw const CartException('Số lượng phải là số nguyên dương.');
    }
    // ID sản phẩm phải giữ cùng quan hệ chợ/gian hàng và đơn vị.
    if (_items.any(
      (item) =>
          item.product.id == product.id &&
          (item.product.stallId != product.stallId ||
              item.product.marketId != product.marketId ||
              item.product.unit != product.unit),
    )) {
      throw const CartException('Thông tin sản phẩm không nhất quán.');
    }
    final normalizedNote = note.trim();
    final updated = List<CartItem>.of(_items);
    final index = updated.indexWhere(
      (item) => item.product.id == product.id && item.note == normalizedNote,
    );
    if (index < 0) {
      updated.add(
        CartItem(
          id: 'cart-${_nextId + 1}',
          product: product,
          quantity: quantity,
          note: normalizedNote,
        ),
      );
    } else {
      final item = updated[index];
      updated[index] = item.copyWith(
        quantity: _sumQuantity(item.quantity, quantity),
      );
    }
    _validate(updated);
    if (index < 0) _nextId++;
    _market ??= market;
    _replaceItems(updated);
  }

  void setQuantity(String id, int quantity) {
    final updated = List<CartItem>.of(_items);
    final index = updated.indexWhere((item) => item.id == id);
    if (index < 0) return;
    updated[index] = updated[index].copyWith(quantity: quantity);
    _replaceItems(updated);
  }

  void updateNote(String id, String note) {
    final source = itemById(id);
    if (source == null) return;
    final normalizedNote = note.trim();
    var quantity = source.quantity;
    final updated = <CartItem>[];
    for (final item in _items) {
      if (item.id != id &&
          item.product.id == source.product.id &&
          item.note == normalizedNote) {
        quantity = _sumQuantity(quantity, item.quantity);
      } else {
        updated.add(item);
      }
    }
    final index = updated.indexWhere((item) => item.id == id);
    // Giữ ID của dòng đang chỉnh sửa; chỉ cộng số lượng dòng trùng ghi chú.
    updated[index] = source.copyWith(quantity: quantity, note: normalizedNote);
    _replaceItems(updated);
  }

  CartRemoval? remove(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) return null;
    final removal = CartRemoval._(_items[index], index, _generation, this);
    _items.removeAt(index);
    notifyListeners();
    return removal;
  }

  bool restore(CartRemoval removal) {
    if (!identical(removal._owner, this) ||
        removal._restored ||
        removal._generation != _generation ||
        _market?.id != removal.item.product.marketId) {
      return false;
    }
    final updated = List<CartItem>.of(_items);
    var quantity = removal.item.quantity;
    // Nếu đã thêm lại sản phẩm cùng ghi chú, gộp và phục hồi ID dòng cũ.
    updated.removeWhere((item) {
      if (item.product.id == removal.item.product.id &&
          item.note == removal.item.note) {
        quantity = _sumQuantity(quantity, item.quantity);
        return true;
      }
      return false;
    });
    final index = removal.index.clamp(0, updated.length);
    updated.insert(index, removal.item.copyWith(quantity: quantity));
    _validate(updated);
    removal._restored = true;
    _replaceItems(updated);
    return true;
  }
}
