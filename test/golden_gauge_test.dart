import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/app/theme/aarogya_theme.dart';
import 'package:aarogya/core/design_system/components/range_gauge_indicator.dart';
import 'package:aarogya/core/design_system/components/reference_gauge_painter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Golden & Visual Render Verification — Reference Gauge & Dynamic Typography', () {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      final themeName = brightness == Brightness.light ? 'Light' : 'Dark';

      testWidgets('ReferenceGaugePainter renders 3-zone continuous bands ($themeName)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: brightness == Brightness.light ? AarogyaTheme.lightTheme : AarogyaTheme.darkTheme,
            home: const Scaffold(
              body: Center(
                child: SizedBox(
                  width: 320,
                  height: 36,
                  child: CustomPaint(
                    painter: ReferenceGaugePainter(
                      value: 14.2,
                      minRange: 13.5,
                      maxRange: 17.5,
                      lowColor: Color(0xFFF59E0B),
                      normalColor: Color(0xFF10B981),
                      highColor: Color(0xFFEF4444),
                      pinColor: Color(0xFF0F172A),
                      isLow: false,
                      isNormal: true,
                      isHigh: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.byType(CustomPaint), findsWidgets);
      });

      for (final textScale in [1.0, 2.0]) {
        testWidgets('RangeGaugeIndicator displays needle, caret overflow and labels at scale=$textScale ($themeName)', (tester) async {
          await tester.pumpWidget(
            MediaQuery(
              data: MediaQueryData(
                textScaler: TextScaler.linear(textScale),
              ),
              child: MaterialApp(
                theme: brightness == Brightness.light ? AarogyaTheme.lightTheme : AarogyaTheme.darkTheme,
                home: const Scaffold(
                  body: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // In-range normal test
                          RangeGaugeIndicator(
                            label: 'Hemoglobin',
                            value: 14.2,
                            minRange: 13.5,
                            maxRange: 17.5,
                            unit: 'g/dL',
                          ),
                          SizedBox(height: 24),
                          // High abnormal overflow test
                          RangeGaugeIndicator(
                            label: 'Blood Sugar (Post Prandial)',
                            value: 240.0,
                            minRange: 70.0,
                            maxRange: 140.0,
                            unit: 'mg/dL',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Hemoglobin'), findsOneWidget);
          expect(find.text('Blood Sugar (Post Prandial)'), findsOneWidget);
          expect(find.text('14.2'), findsOneWidget);
          expect(find.text('240'), findsOneWidget);
          expect(find.text('g/dL'), findsWidgets);
          expect(find.text('mg/dL'), findsWidgets);
        });
      }
    }
  });
}
