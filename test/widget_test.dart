import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shot_log/app.dart';
import 'package:shot_log/shared/providers/photo_provider.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ja');
  });

  testWidgets('App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShotLogApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('ShotLog'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });

  testWidgets('Navigation bar switches tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShotLogApp()),
    );
    await tester.pumpAndSettle();

    // Navigate to timeline
    await tester.tap(find.text('タイムライン'));
    await tester.pumpAndSettle();
    expect(find.text('タイムライン'), findsWidgets);

    // Navigate to analytics
    await tester.tap(find.text('分析'));
    await tester.pumpAndSettle();
    expect(find.text('Analytics'), findsOneWidget);

    // Navigate to settings
    await tester.tap(find.text('設定'));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('Timeline shows search and filter buttons',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShotLogApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('タイムライン'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.search), findsOneWidget);
    expect(find.byIcon(Icons.filter_list), findsOneWidget);
  });

  testWidgets('Analytics shows period filter chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShotLogApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('分析'));
    await tester.pumpAndSettle();

    expect(find.text('全期間'), findsOneWidget);
    expect(find.text('今月'), findsOneWidget);
    expect(find.text('直近3ヶ月'), findsOneWidget);
  });

  testWidgets('Photo deletion removes from list',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(photoListProvider.notifier);
    final initialCount = container.read(photoListProvider).length;

    notifier.deletePhoto('001');

    expect(container.read(photoListProvider).length, initialCount - 1);
    expect(
      container.read(photoListProvider).any((p) => p.id == '001'),
      isFalse,
    );
  });

  testWidgets('Filter provider filters by lens',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(timelineFilterProvider.notifier).state =
        const TimelineFilter(lensModel: 'FE 85mm F1.4 GM');

    final filtered = container.read(filteredPhotosProvider);
    expect(filtered.every((p) => p.lensModel == 'FE 85mm F1.4 GM'), isTrue);
    expect(filtered.isNotEmpty, isTrue);
  });

  testWidgets('Filter provider filters favorites only',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(timelineFilterProvider.notifier).state =
        const TimelineFilter(favoritesOnly: true);

    final filtered = container.read(filteredPhotosProvider);
    expect(filtered.every((p) => p.isFavorite), isTrue);
  });
}
