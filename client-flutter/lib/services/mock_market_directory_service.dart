import '../models/market_area.dart';
import '../models/stall.dart';
import 'mock_market_service.dart';

// Dữ liệu minh họa trong bộ nhớ, không gọi API.
// Dùng lại danh sách ID chợ để giữ nhất quán với màn hình chọn chợ.
class MockMarketDirectoryService {
  MockMarketDirectoryService({
    this.scenario = MockMarketScenario.data,
    this.delay = const Duration(milliseconds: 600),
  });

  final MockMarketScenario scenario;
  final Duration delay;
  final Map<String, int> _attempts = {};

  static final List<MarketArea> sampleAreas = List.unmodifiable([
    for (final market in MockMarketService.sampleMarkets) ...[
      MarketArea(
        id: '${market.id}-rau-cu',
        marketId: market.id,
        name: 'Khu rau củ',
        description: 'Khu vực mẫu dành cho các gian hàng rau củ.',
      ),
      MarketArea(
        id: '${market.id}-thit-ca',
        marketId: market.id,
        name: 'Khu thịt cá',
        description: 'Khu vực mẫu dành cho các gian hàng thịt cá.',
      ),
      MarketArea(
        id: '${market.id}-do-kho',
        marketId: market.id,
        name: 'Khu đồ khô',
        description: 'Khu vực mẫu dành cho các gian hàng đồ khô.',
      ),
    ],
  ]);

  static final List<Stall> sampleStalls = List.unmodifiable([
    for (final area in sampleAreas)
      for (var index = 1; index <= 2; index++)
        Stall(
          id: '${area.id}-stall-$index',
          marketId: area.marketId,
          areaId: area.id,
          name: 'Gian hàng ${area.name.toLowerCase()} $index',
          location: 'Vị trí mẫu: sạp số 0$index',
        ),
  ]);

  Future<void> _simulateLoad(String key) async {
    final attempt = (_attempts[key] ?? 0) + 1;
    _attempts[key] = attempt;
    await Future<void>.delayed(delay);
    if (scenario == MockMarketScenario.errorThenSuccess && attempt == 1) {
      throw Exception('Lỗi tải dữ liệu mẫu');
    }
  }

  Future<List<MarketArea>> getAreas(String marketId) async {
    await _simulateLoad('areas:$marketId');
    if (scenario == MockMarketScenario.empty) return const [];
    return sampleAreas.where((area) => area.marketId == marketId).toList();
  }

  Future<List<Stall>> getStalls(String marketId, String areaId) async {
    await _simulateLoad('stalls:$marketId:$areaId');
    if (scenario == MockMarketScenario.empty) return const [];
    final areaBelongsToMarket = sampleAreas.any(
      (area) => area.id == areaId && area.marketId == marketId,
    );
    if (!areaBelongsToMarket) return const [];
    return sampleStalls
        .where((stall) => stall.marketId == marketId && stall.areaId == areaId)
        .toList();
  }
}
