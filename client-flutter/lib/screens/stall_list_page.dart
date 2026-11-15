import 'package:flutter/material.dart';

import '../models/market.dart';
import '../models/market_area.dart';
import '../models/stall.dart';
import '../services/mock_market_directory_service.dart';
import '../services/mock_market_service.dart';
import '../widgets/demo_list_widgets.dart';
import 'product_list_page.dart';

class StallListPage extends StatefulWidget {
  const StallListPage({
    super.key,
    required this.market,
    required this.area,
    this.service,
  });

  final Market market;
  final MarketArea area;
  final MockMarketDirectoryService? service;

  @override
  State<StallListPage> createState() => _StallListPageState();
}

class _StallListPageState extends State<StallListPage> {
  late MockMarketDirectoryService _service;
  late Future<List<Stall>> _stalls;
  MockMarketScenario _scenario = MockMarketScenario.data;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MockMarketDirectoryService();
    _stalls = _loadStalls();
  }

  Future<List<Stall>> _loadStalls() async {
    if (widget.area.marketId != widget.market.id) return const [];
    final stalls = await _service.getStalls(widget.market.id, widget.area.id);
    return stalls
        .where(
          (stall) =>
              stall.marketId == widget.market.id &&
              stall.areaId == widget.area.id,
        )
        .toList();
  }

  void _retry() {
    setState(() {
      _stalls = _loadStalls();
    });
  }

  void _changeScenario(MockMarketScenario? scenario) {
    if (scenario == null) return;
    setState(() {
      _scenario = scenario;
      _service = MockMarketDirectoryService(scenario: scenario);
      _stalls = _loadStalls();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.area.marketId != widget.market.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gian hàng · Demo')),
        body: const DemoListMessage(
          text: 'Khu vực không thuộc chợ đã chọn. Vui lòng quay lại.',
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Gian hàng · Demo')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.area.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.market.name),
                      const SizedBox(height: 8),
                      const Text(
                        'Thông tin gian hàng và vị trí sạp là dữ liệu mẫu. '
                        'Có thể xem sản phẩm mẫu; chưa có giỏ hàng hoặc đặt đơn.',
                      ),
                      if (widget.service == null) ...[
                        const SizedBox(height: 16),
                        DemoScenarioSelector(
                          scenario: _scenario,
                          onChanged: _changeScenario,
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Stall>>(
                    future: _stalls,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return DemoListMessage(
                          text:
                              'Không tải được gian hàng mẫu. Vui lòng thử lại.',
                          onRetry: _retry,
                        );
                      }
                      final stalls = snapshot.data ?? const <Stall>[];
                      if (stalls.isEmpty) {
                        return const DemoListMessage(
                          text: 'Chưa có gian hàng mẫu trong khu vực này.',
                        );
                      }
                      return ListView.builder(
                        key: const ValueKey('stall_list'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: stalls.length,
                        itemBuilder: (context, index) {
                          final stall = stalls[index];
                          return Card(
                            child: ListTile(
                              key: ValueKey('stall_${stall.id}'),
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(Icons.storefront_outlined),
                              title: Text(stall.name),
                              subtitle: Text(
                                'Khu vực: ${widget.area.name}\n${stall.location}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => ProductListPage(
                                    market: widget.market,
                                    stall: stall,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
