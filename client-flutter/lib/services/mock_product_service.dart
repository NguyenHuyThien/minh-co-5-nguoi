import '../models/product.dart';
import 'mock_market_directory_service.dart';
import 'mock_market_service.dart';

// Chỉ cung cấp sản phẩm và giá minh họa trong bộ nhớ, không gọi API.
class MockProductService {
  MockProductService({
    this.scenario = MockMarketScenario.data,
    this.delay = const Duration(milliseconds: 600),
  });

  final MockMarketScenario scenario;
  final Duration delay;
  final Map<String, int> _attempts = {};

  static final List<Product> sampleProducts = List.unmodifiable([
    for (final stall in MockMarketDirectoryService.sampleStalls)
      for (var index = 0; index < 3; index++)
        Product(
          id: '${stall.id}-product-$index',
          marketId: stall.marketId,
          stallId: stall.id,
          stallName: stall.name,
          name: _names(stall.areaId)[index],
          priceVnd: _prices(stall.areaId)[index],
          unit: _units(stall.areaId)[index],
          description:
              'Mô tả minh họa cho ${_names(stall.areaId)[index].toLowerCase()}. '
              'Thông tin và giá chỉ dùng để thử giao diện, '
              'chưa được xác nhận bởi chợ hoặc tiểu thương.',
          inStock: index != 2,
        ),
  ]);

  static List<String> _names(String areaId) {
    if (areaId.endsWith('-rau-cu')) {
      return const ['Cải xanh', 'Cà chua', 'Rau muống'];
    }
    if (areaId.endsWith('-thit-ca')) {
      return const ['Thịt heo', 'Cá rô', 'Trứng gà'];
    }
    return const ['Gạo', 'Đậu xanh', 'Mì khô'];
  }

  static List<int> _prices(String areaId) {
    if (areaId.endsWith('-rau-cu')) return const [18000, 25000, 10000];
    if (areaId.endsWith('-thit-ca')) return const [95000, 60000, 32000];
    return const [22000, 45000, 20000];
  }

  static List<String> _units(String areaId) {
    if (areaId.endsWith('-rau-cu')) return const ['kg', 'kg', 'bó'];
    if (areaId.endsWith('-thit-ca')) return const ['kg', 'kg', 'vỉ'];
    return const ['kg', 'kg', 'gói'];
  }

  Future<List<Product>> getProducts({
    required String marketId,
    String? stallId,
  }) async {
    final key = '$marketId:$stallId';
    final attempt = (_attempts[key] ?? 0) + 1;
    _attempts[key] = attempt;
    await Future<void>.delayed(delay);
    if (scenario == MockMarketScenario.errorThenSuccess && attempt == 1) {
      throw Exception('Lỗi tải sản phẩm mẫu');
    }
    if (scenario == MockMarketScenario.empty) return const [];
    final validStallIds = MockMarketDirectoryService.sampleStalls
        .where((stall) => stall.marketId == marketId)
        .map((stall) => stall.id)
        .toSet();
    return sampleProducts
        .where(
          (product) =>
              product.marketId == marketId &&
              validStallIds.contains(product.stallId) &&
              (stallId == null || product.stallId == stallId),
        )
        .toList();
  }
}
