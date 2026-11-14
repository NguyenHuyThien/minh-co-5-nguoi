import '../models/market.dart';

enum MockMarketScenario { data, empty, errorThenSuccess }

// Chỉ cung cấp dữ liệu mẫu trong bộ nhớ; không gọi API hay lấy vị trí.
class MockMarketService {
  MockMarketService({
    this.scenario = MockMarketScenario.data,
    this.delay = const Duration(milliseconds: 600),
  });

  final MockMarketScenario scenario;
  final Duration delay;
  int _attempts = 0;

  static const sampleMarkets = <Market>[
    Market(
      id: 'mock-market-1',
      name: 'Chợ Bình Minh',
      address: 'Địa chỉ mẫu: 12 đường Hoa Mai, khu dân cư Bình Minh',
    ),
    Market(
      id: 'mock-market-2',
      name: 'Chợ An Hòa',
      address: 'Địa chỉ mẫu: 25 đường An Hòa, khu dân cư An Hòa',
    ),
    Market(
      id: 'mock-market-3',
      name: 'Chợ Đồng Xanh',
      address: 'Địa chỉ mẫu: 8 đường Đồng Xanh, khu dân cư Đồng Xanh',
    ),
  ];

  Future<List<Market>> getMarkets() async {
    final attempt = ++_attempts;
    await Future<void>.delayed(delay);
    if (scenario == MockMarketScenario.errorThenSuccess && attempt == 1) {
      throw Exception('Lỗi mô phỏng khi tải chợ');
    }
    if (scenario == MockMarketScenario.empty) return const [];
    return List<Market>.of(sampleMarkets);
  }
}
