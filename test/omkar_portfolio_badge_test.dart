import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/core/design_system/components/omkar_portfolio_badge.dart';

void main() {
  group('OmkarPortfolioBadge Tests', () {
    testWidgets('renders badge with avatar, produced by omkar pill and pop bubble', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                OmkarPortfolioBadge(),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Produced By" pill content
      expect(find.text('PRODUCED BY'), findsOneWidget);
      expect(find.text('Omkar Anarse'), findsWidgets);

      // Verify speech bubble pop message
      expect(find.text('AI FULL STACK ENGINEER'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('AI & Full Stack Engineer'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('omkar-anarse.vercel.app'), findsOneWidget);

      // Verify close button can dismiss speech bubble
      final closeButton = find.byIcon(Icons.close_rounded);
      expect(closeButton, findsOneWidget);
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Speech bubble dismissed
      expect(find.text('AI FULL STACK ENGINEER'), findsNothing);

      // Tapping avatar reopens speech bubble
      final avatarFinder = find.byType(GestureDetector).last;
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      expect(find.text('AI FULL STACK ENGINEER'), findsOneWidget);
    });
  });
}
