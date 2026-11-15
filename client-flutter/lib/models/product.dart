class Product {
  const Product({
    required this.id,
    required this.marketId,
    required this.stallId,
    required this.stallName,
    required this.name,
    required this.priceVnd,
    required this.unit,
    required this.description,
    required this.inStock,
  }) : assert(priceVnd >= 0);

  final String id;
  final String marketId;
  final String stallId;
  final String stallName;
  final String name;
  // Giá mẫu tính bằng số đồng nguyên, không dùng double cho tiền.
  final int priceVnd;
  final String unit;
  final String description;
  final bool inStock;
}
