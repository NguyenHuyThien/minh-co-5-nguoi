import 'dart:async';

import 'package:dichoho/main.dart';
import 'package:dichoho/models/market_area.dart';
import 'package:dichoho/models/stall.dart';
import 'package:dichoho/screens/market_area_page.dart';
import 'package:dichoho/screens/stall_list_page.dart';
import 'package:dichoho/services/mock_market_directory_service.dart';
import 'package:dichoho/services/mock_market_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final market = MockMarketService.sampleMarkets.first;
final area = MockMarketDirectoryService.sampleAreas.first;
final anotherMarket = MockMarketService.sampleMarkets[1];
final anotherArea = MockMarketDirectoryService.sampleAreas.firstWhere(
  (item) => item.marketId == anotherMarket.id,
);

class PendingDirectoryService extends MockMarketDirectoryService {
  final areas = Completer<List<MarketArea>>();
  final stalls = Completer<List<Stall>>();

  @override
  Future<List<MarketArea>> getAreas(String marketId) => areas.future;

  @override
  Future<List<Stall>> getStalls(String marketId, String areaId) =>
      stalls.future;
}

// Mô phỏng nguồn dữ liệu trả lẫn bản ghi để kiểm tra màn hình phòng vệ.
class MixedDirectoryService extends MockMarketDirectoryService {
  @override
  Future<List<MarketArea>> getAreas(String marketId) async => [
    area,
    anotherArea,
  ];

  @override
  Future<List<Stall>> getStalls(String marketId, String areaId) async => [
    MockMarketDirectoryService.sampleStalls.first,
    Stall(
      id: 'wrong-market',
      marketId: anotherMarket.id,
      areaId: area.id,
      name: 'Sai chợ',
      location: 'Mẫu',
    ),
    Stall(
      id: 'wrong-area',
      marketId: market.id,
      areaId: '${market.id}-thit-ca',
      name: 'Sai khu vực',
      location: 'Mẫu',
    ),
  ];
}

Future<void> finishDemoLoad(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  test(
    'Service lọc khu vực và gian hàng theo từng chợ, từng khu vực',
    () async {
      final service = MockMarketDirectoryService(delay: Duration.zero);
      for (final selectedMarket in MockMarketService.sampleMarkets) {
        final areas = await service.getAreas(selectedMarket.id);
        expect(areas, hasLength(3));
        expect(
          areas.every((item) => item.marketId == selectedMarket.id),
          isTrue,
        );
        for (final selectedArea in areas) {
          final stalls = await service.getStalls(
            selectedMarket.id,
            selectedArea.id,
          );
          expect(stalls, hasLength(2));
          expect(
            stalls.every(
              (item) =>
                  item.marketId == selectedMarket.id &&
                  item.areaId == selectedArea.id,
            ),
            isTrue,
          );
        }
      }
      expect(await service.getAreas('unknown'), isEmpty);
      expect(await service.getStalls(market.id, anotherArea.id), isEmpty);
      expect(await service.getStalls('unknown', area.id), isEmpty);
      expect(await service.getStalls(market.id, 'unknown'), isEmpty);
    },
  );

  test(
    'Service mô phỏng rỗng, lỗi và thử lại riêng cho mỗi truy vấn',
    () async {
      final empty = MockMarketDirectoryService(
        scenario: MockMarketScenario.empty,
        delay: Duration.zero,
      );
      expect(await empty.getAreas(market.id), isEmpty);
      expect(await empty.getStalls(market.id, area.id), isEmpty);
      final failing = MockMarketDirectoryService(
        scenario: MockMarketScenario.errorThenSuccess,
        delay: Duration.zero,
      );
      await expectLater(failing.getAreas(market.id), throwsException);
      expect(await failing.getAreas(market.id), isNotEmpty);
      await expectLater(failing.getStalls(market.id, area.id), throwsException);
      expect(await failing.getStalls(market.id, area.id), isNotEmpty);
    },
  );

  for (final isArea in [true, false]) {
    final name = isArea ? 'Khu vực' : 'Gian hàng';
    Widget screen(MockMarketDirectoryService service) => MaterialApp(
      home: isArea
          ? MarketAreaPage(market: market, service: service)
          : StallListPage(market: market, area: area, service: service),
    );

    testWidgets('$name: loading rồi hiển thị dữ liệu', (tester) async {
      final service = PendingDirectoryService();
      await tester.pumpWidget(screen(service));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      if (isArea) {
        service.areas.complete([area]);
      } else {
        service.stalls.complete([
          MockMarketDirectoryService.sampleStalls.first,
        ]);
      }
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.textContaining('dữ liệu mẫu'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('$name: rỗng có thông báo, không có bản ghi', (tester) async {
      await tester.pumpWidget(
        screen(
          MockMarketDirectoryService(
            scenario: MockMarketScenario.empty,
            delay: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          isArea
              ? 'Chưa có khu vực mẫu trong chợ này.'
              : 'Chưa có gian hàng mẫu trong khu vực này.',
        ),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('$name: lỗi và thử lại thành công', (tester) async {
      await tester.pumpWidget(
        screen(
          MockMarketDirectoryService(
            scenario: MockMarketScenario.errorThenSuccess,
            delay: Duration.zero,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Không tải được'), findsOneWidget);
      await tester.tap(find.text('Thử lại'));
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Thử lại'), findsNothing);
    });

    testWidgets('$name: lọc thêm dữ liệu sai chợ hoặc sai khu vực', (
      tester,
    ) async {
      await tester.pumpWidget(screen(MixedDirectoryService()));
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsOneWidget);
      expect(find.byKey(ValueKey('area_${anotherArea.id}')), findsNothing);
      expect(find.text('Sai chợ'), findsNothing);
      expect(find.text('Sai khu vực'), findsNothing);
    });

    testWidgets('$name: demo chuyển rỗng, lỗi, thử lại trên màn hình nhỏ', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 640);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          home: isArea
              ? MarketAreaPage(market: market)
              : StallListPage(market: market, area: area),
        ),
      );
      await finishDemoLoad(tester);
      await tester.tap(
        find.byType(DropdownButtonFormField<MockMarketScenario>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Danh sách rỗng').last);
      await finishDemoLoad(tester);
      expect(find.textContaining('Chưa có'), findsOneWidget);
      await tester.tap(
        find.byType(DropdownButtonFormField<MockMarketScenario>),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lỗi lần đầu, thử lại thành công').last);
      await finishDemoLoad(tester);
      await tester.tap(find.text('Thử lại'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await finishDemoLoad(tester);
      expect(find.byType(ListTile), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Khu vực truyền đúng chợ và khu vực khi mở gian hàng', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MarketAreaPage(
          market: market,
          service: MockMarketDirectoryService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('area_${area.id}')));
    await tester.pumpAndSettle();
    final page = tester.widget<StallListPage>(find.byType(StallListPage));
    expect(identical(page.market, market), isTrue);
    expect(identical(page.area, area), isTrue);
    expect(find.byType(ListTile), findsNWidgets(2));
    expect(find.textContaining('Khu vực: ${area.name}'), findsNWidgets(2));
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('area_list')), findsOneWidget);
  });

  testWidgets('Không hiển thị gian hàng khi truyền khu vực khác chợ', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StallListPage(
          market: market,
          area: anotherArea,
          service: MockMarketDirectoryService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Khu vực không thuộc chợ đã chọn. Vui lòng quay lại.'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('Demo dùng đúng chợ đã chọn và cập nhật khi chọn chợ khác', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    final select = find.byKey(const ValueKey('open_market_demo'));
    final directory = find.byKey(const ValueKey('open_market_directory_demo'));
    expect(directory, findsNothing);
    for (final selectedMarket in [market, anotherMarket]) {
      await tester.ensureVisible(select);
      await tester.tap(select);
      await finishDemoLoad(tester);
      await tester.tap(find.text(selectedMarket.name));
      await tester.pumpAndSettle();
      await tester.ensureVisible(directory);
      await tester.tap(directory);
      await finishDemoLoad(tester);
      final page = tester.widget<MarketAreaPage>(find.byType(MarketAreaPage));
      expect(page.market.id, selectedMarket.id);
      final areas = MockMarketDirectoryService.sampleAreas.where(
        (item) => item.marketId == selectedMarket.id,
      );
      for (final item in areas) {
        expect(find.byKey(ValueKey('area_${item.id}')), findsOneWidget);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
    expect(find.byKey(const ValueKey('login_submit')), findsOneWidget);
  });
}
