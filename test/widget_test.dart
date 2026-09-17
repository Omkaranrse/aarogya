import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/main.dart';
import 'package:aarogya/shared/state/aarogya_providers.dart';

void main() {
  testWidgets('AarogyaApp unauthenticated displays AuthScreen branding and tabs', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const ProviderScope(
        child: AarogyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aarogya'), findsWidgets);
    expect(find.text('Next-Gen Hospital & Healthcare Network'), findsOneWidget);
    expect(find.text('Email & Staff'), findsOneWidget);
    expect(find.text('Phone OTP'), findsOneWidget);
  });

  testWidgets('AarogyaApp authenticated displays AdaptiveShell with branding and clinical navigation', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isAuthenticatedProvider.overrideWithValue(true),
        ],
        child: const AarogyaApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Aarogya branding text appears on shell
    expect(find.text('AAROGYA'), findsOneWidget);
    expect(find.text('CLINICAL INTELLIGENCE OS'), findsOneWidget);
  });
}
