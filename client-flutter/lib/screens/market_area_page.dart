import 'package:flutter/material.dart';

import '../models/market.dart';
import '../models/market_area.dart';
import '../services/mock_market_directory_service.dart';
import '../services/mock_market_service.dart';
import '../widgets/demo_list_widgets.dart';
import 'stall_list_page.dart';

class MarketAreaPage extends StatefulWidget {
  const MarketAreaPage({super.key, required this.market, this.service});

  final Market market;
  final MockMarketDirectoryService? service;

  @override
  State<MarketAreaPage> createState() => _MarketAreaPageState();
}

class _MarketAreaPageState extends State<MarketAreaPage> {
  late MockMarketDirectoryService _service;
  late Future<List<MarketArea>> _areas;
  MockMarketScenario _scenario = MockMarketScenario.data;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MockMarketDirectoryService();
    _areas = _loadAreas();
  }

  Future<List<MarketArea>> _loadAreas() async {
    final areas = await _service.getAreas(widget.market.id);
    // Kiểm tra thêm ở màn hình để không hiển thị sai chợ.
    return areas.where((area) => area.marketId == widget.market.id).toList();
  }

  void _retry() {
    setState(() {
      _areas = _loadAreas();
    });
  }

  void _changeScenario(MockMarketScenario? scenario) {
    if (scenario == null) return;
    setState(() {
      _scenario = scenario;
      _service = MockMarketDirectoryService(scenario: scenario);
      _areas = _loadAreas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Khu vực · Demo')),
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
                        widget.market.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Khu vực và gian hàng là dữ liệu mẫu, chưa kết nối Backend.',
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
                  child: FutureBuilder<List<MarketArea>>(
                    future: _areas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return DemoListMessage(
                          text: 'Không tải được khu vực mẫu. Vui lòng thử lại.',
                          onRetry: _retry,
                        );
                      }
                      final areas = snapshot.data ?? const <MarketArea>[];
                      if (areas.isEmpty) {
                        return const DemoListMessage(
                          text: 'Chưa có khu vực mẫu trong chợ này.',
                        );
                      }
                      return ListView.builder(
                        key: const ValueKey('area_list'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: areas.length,
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          return Card(
                            child: ListTile(
                              key: ValueKey('area_${area.id}'),
                              contentPadding: const EdgeInsets.all(16),
                              leading: const Icon(Icons.category_outlined),
                              title: Text(area.name),
                              subtitle: Text(area.description),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push<void>(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (context) => StallListPage(
                                    market: widget.market,
                                    area: area,
                                    service: widget.service,
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
