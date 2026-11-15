import 'product.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    String note = '',
  }) : note = note.trim();

  final String id;
  final Product product;
  final int quantity;
  final String note;

  int get subtotalVnd => product.priceVnd * quantity;

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      id: id,
      product: product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}
