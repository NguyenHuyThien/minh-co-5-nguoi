import 'package:flutter/material.dart';

import '../services/mock_market_service.dart';

class DemoScenarioSelector extends StatelessWidget {
  const DemoScenarioSelector({
    super.key,
    required this.scenario,
    required this.onChanged,
  });

  final MockMarketScenario scenario;
  final ValueChanged<MockMarketScenario?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<MockMarketScenario>(
      initialValue: scenario,
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
          child: Text(
            'Lỗi lần đầu, thử lại thành công',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
      onChanged: onChanged,
    );
  }
}

class DemoListMessage extends StatelessWidget {
  const DemoListMessage({super.key, required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
