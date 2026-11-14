import 'dart:async';

import 'package:dichoho/main.dart';
import 'package:dichoho/models/market.dart';
import 'package:dichoho/screens/market_selection_page.dart';
import 'package:dichoho/services/mock_market_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class PendingMarketService extends MockMarketService {
  final completer = Completer<List<Market>>();

  @override
  Future<List<Market>> getMarkets() => completer.future;
}

Widget page(MockMarketService service) {
  return MaterialApp(home: MarketSelectionPage(service: service));
}

void main() {
  test('Service trả danh sách mẫu độc lập và lỗi chỉ ở lần đầu', () async {
    final service = MockMarketService(delay: Duration.zero);
    final markets = await service.getMarkets();
    expect(markets.length, 3);
    expect(markets.map((market) => market.id).toSet().length, 3);
    markets.clear();
    expect(await service.getMarkets(), hasLength(3));

    final failing = MockMarketService(
      scenario: MockMarketScenario.errorThenSuccess,
      delay: Duration.zero,
    );
    await expectLater(failing.getMarkets(), throwsException);
    expect(await failing.getMarkets(), hasLength(3));
  });

  testWidgets('Hiển thị loading trước khi service trả dữ liệu', (tester) async {
    final service = PendingMarketService();
    await tester.pumpWidget(page(service));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Đang tải danh sách chợ mẫu...'), findsOneWidget);
    service.completer.complete(MockMarketService.sampleMarkets);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Chợ Bình Minh'), findsOneWidget);
  });

  testWidgets('Danh sách hiển thị đúng tên, địa chỉ và nhãn dữ liệu mẫu', (
    tester,
  ) async {
    await tester.pumpWidget(page(MockMarketService(delay: Duration.zero)));
    await tester.pumpAndSettle();
    expect(find.byType(ListView), findsOneWidget);
    for (final market in MockMarketService.sampleMarkets) {
      expect(find.text(market.name), findsOneWidget);
      expect(find.text(market.address), findsOneWidget);
    }
    expect(
      find.textContaining('Tên và địa chỉ chợ là minh họa'),
      findsOneWidget,
    );
    expect(find.textContaining('km'), findsNothing);
  });

  testWidgets('Chọn chợ trả về đúng đối tượng qua Navigator', (tester) async {
    Market? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await Navigator.push<Market>(
                  context,
                  MaterialPageRoute<Market>(
                    builder: (_) => MarketSelectionPage(
                      service: MockMarketService(delay: Duration.zero),
                    ),
                  ),
                );
              },
              child: const Text('Mở chọn chợ'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Mở chọn chợ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chợ An Hòa'));
    await tester.pumpAndSettle();
    expect(identical(result, MockMarketService.sampleMarkets[1]), isTrue);
    expect(find.text('Mở chọn chợ'), findsOneWidget);
  });

  testWidgets('Danh sách rỗng có thông báo và không có mục để chọn', (
    tester,
  ) async {
    await tester.pumpWidget(
      page(
        MockMarketService(
          scenario: MockMarketScenario.empty,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Chưa có chợ trong dữ liệu mẫu.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('Lỗi có nút thử lại và chuyển sang dữ liệu khi thử lại', (
    tester,
  ) async {
    await tester.pumpWidget(
      page(
        MockMarketService(
          scenario: MockMarketScenario.errorThenSuccess,
          delay: Duration.zero,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Không tải được danh sách chợ mẫu. Vui lòng thử lại.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chợ Bình Minh'), findsOneWidget);
    expect(find.text('Thử lại'), findsNothing);
  });

  testWidgets('Lối demo trả kết quả, Back không xóa chợ đã chọn', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final demo = find.byKey(const ValueKey('open_market_demo'));
    await tester.ensureVisible(demo);
    await tester.tap(demo);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Chọn chợ · Demo'), findsOneWidget);
    await tester.tap(find.text('Chợ An Hòa'));
    await tester.pumpAndSettle();
    final selected = find.byKey(const ValueKey('selected_demo_market'));
    expect(find.text('Chợ mẫu đã chọn: Chợ An Hòa'), findsOneWidget);
    expect(find.text('Đã chọn chợ mẫu: Chợ An Hòa'), findsOneWidget);
    expect(find.byKey(const ValueKey('login_submit')), findsOneWidget);
    await tester.ensureVisible(demo);
    await tester.tap(demo);
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(selected).data, 'Chợ mẫu đã chọn: Chợ An Hòa');
    // Future hoàn thành sau khi rời trang không được gây setState sau dispose.
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('Kịch bản demo đổi được giữa dữ liệu, rỗng và lỗi', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 640);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const MaterialApp(home: MarketSelectionPage()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('market_scenario')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danh sách rỗng').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có chợ trong dữ liệu mẫu.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('market_scenario')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lỗi lần đầu, thử lại thành công').last);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thử lại'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Chợ Bình Minh'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
