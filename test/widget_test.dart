import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shot_log/app.dart';

void main() {
  testWidgets('App renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ShotLogApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('ShotLog'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
