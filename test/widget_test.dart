import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/main.dart';

void main() {
  testWidgets('AarogyaApp smoke test builds shell with branding and navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AarogyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Aarogya branding text appears
    expect(find.text('AAROGYA'), findsOneWidget);
    expect(find.text('Next-Gen Medical OS'), findsOneWidget);
  });
}
