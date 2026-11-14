import 'package:flutter/material.dart';

import '../models/market.dart';
import '../services/mock_market_service.dart';

class MarketSelectionPage extends StatefulWidget {
  const MarketSelectionPage({super.key, this.service});

  // Cho phép truyền service để kiểm thử mà không phụ thuộc thời gian thực.
  final MockMarketService? service;

  @override
  State<MarketSelectionPage> createState() => _MarketSelectionPageState();
}

class _MarketSelectionPageState extends State<MarketSelectionPage> {
  late MockMarketService _service;
  late Future<List<Market>> _markets;
  MockMarketScenario _scenario = MockMarketScenario.data;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? MockMarketService();
    _markets = _service.getMarkets();
  }

  void _retry() {
    setState(() {
      _markets = _service.getMarkets();
    });
  }

  void _changeScenario(MockMarketScenario? scenario) {
    if (scenario == null) return;
    setState(() {
      _scenario = scenario;
      _service = MockMarketService(scenario: scenario);
      _markets = _service.getMarkets();
    });
  }

  Widget _message(String text, {bool retry = false}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (retry) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const ValueKey('market_retry'),
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chợ · Demo')),
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
                      const Text(
                        'Dữ liệu mẫu để trải nghiệm giao diện. Tên và địa chỉ '
                        'chợ là minh họa, chưa lấy từ Backend hoặc vị trí của bạn.',
                      ),
                      if (widget.service == null) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<MockMarketScenario>(
                          key: const ValueKey('market_scenario'),
                          initialValue: _scenario,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Kịch bản dữ liệu mẫu',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: MockMarketScenario.data,
                              child: Text('Có dữ liệu'),
                            ),
                            DropdownMenuItem(
                              value: MockMarketScenario.empty,
                              child: Text('Danh sách rỗng'),
                            ),
                            DropdownMenuItem(
                              value: MockMarketScenario.errorThenSuccess,
                              child: Text('Lỗi lần đầu, thử lại thành công'),
                            ),
                          ],
                          onChanged: _changeScenario,
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Market>>(
                    future: _markets,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Đang tải danh sách chợ mẫu...'),
                            ],
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _message(
                          'Không tải được danh sách chợ mẫu. Vui lòng thử lại.',
                          retry: true,
                        );
                      }
                      final markets = snapshot.data ?? const <Market>[];
                      if (markets.isEmpty) {
                        return _message('Chưa có chợ trong dữ liệu mẫu.');
                      }
                      return ListView.builder(
                        key: const ValueKey('market_list'),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: markets.length,
                        itemBuilder: (context, index) {
                          final market = markets[index];
                          return Card(
                            child: ListTile(
                              key: ValueKey('market_${market.id}'),
                              contentPadding: const EdgeInsets.all(16),
                              leading: Icon(
                                Icons.storefront_outlined,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              title: Text(market.name),
                              subtitle: Text(market.address),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () =>
                                  Navigator.pop<Market>(context, market),
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
