import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aarogya/app/theme/aarogya_theme.dart';
import 'package:aarogya/core/design_system/components/range_gauge_indicator.dart';
import 'package:aarogya/core/design_system/components/metric_card.dart';
import 'package:aarogya/features/patient/dashboard/patient_dashboard.dart';

void main() {
  group('Phase P3 — Flutter Implementation Quality & Dynamic Text Scaling Tests', () {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        final modeName = brightness == Brightness.light ? 'Light' : 'Dark';

        testWidgets(
          'RangeGaugeIndicator renders cleanly under textScale=$scale ($modeName)',
          (tester) async {
            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  platformBrightness: brightness,
                ),
                child: MaterialApp(
                  theme: AarogyaTheme.lightTheme,
                  darkTheme: AarogyaTheme.darkTheme,
                  themeMode: brightness == Brightness.light
                      ? ThemeMode.light
                      : ThemeMode.dark,
                  home: const Scaffold(
                    body: RangeGaugeIndicator(
                      label: 'Serum LDL Cholesterol',
                      value: 138.0,
                      minRange: 0.0,
                      maxRange: 100.0,
                      unit: 'mg/dL',
                      statusLabel: 'High',
                    ),
                  ),
                ),
              ),
            );

            expect(find.byType(RangeGaugeIndicator), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'MetricCard renders without overflow under textScale=$scale ($modeName)',
          (tester) async {
            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  platformBrightness: brightness,
                ),
                child: MaterialApp(
                  theme: AarogyaTheme.lightTheme,
                  darkTheme: AarogyaTheme.darkTheme,
                  themeMode: brightness == Brightness.light
                      ? ThemeMode.light
                      : ThemeMode.dark,
                  home: const Scaffold(
                    body: SizedBox(
                      width: 320,
                      child: MetricCard(
                        label: 'Blood Pressure',
                        value: '120/80',
                        unit: 'mmHg',
                        delta: 'Optimal range',
                        status: MetricClinicalStatus.stable,
                      ),
                    ),
                  ),
                ),
              ),
            );

            expect(find.byType(MetricCard), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );

        testWidgets(
          'PatientDashboard renders without overflow under textScale=$scale ($modeName)',
          (tester) async {
            tester.view.physicalSize = const Size(1200, 1600);
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);

            await tester.pumpWidget(
              MediaQuery(
                data: MediaQueryData(
                  size: const Size(1200, 1600),
                  textScaler: TextScaler.linear(scale),
                  platformBrightness: brightness,
                ),
                child: ProviderScope(
                  child: MaterialApp(
                    theme: AarogyaTheme.lightTheme,
                    darkTheme: AarogyaTheme.darkTheme,
                    themeMode: brightness == Brightness.light
                        ? ThemeMode.light
                        : ThemeMode.dark,
                    home: const Scaffold(
                      body: PatientDashboard(),
                    ),
                  ),
                ),
              ),
            );

            expect(find.byType(PatientDashboard), findsOneWidget);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  });
}
