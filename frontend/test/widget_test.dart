import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:itsm_mobile/app.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: App(),
      ),
    );

    // Verify the placeholder home screen renders.
    expect(find.text('ITSM Mobile'), findsOneWidget);
    expect(find.text('Phase 1 Complete'), findsOneWidget);
  });
}
