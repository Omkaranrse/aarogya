import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/core/auth/biometric_auth_service.dart';
import 'package:aarogya/features/auth/auth_screen.dart';

void main() {
  group('Authentication Upgrades & Clinical Security Tests', () {
    test('BiometricAuthService locks and unlocks clinical station', () {
      final bioService = BiometricAuthService();
      expect(bioService.isStationLocked, isFalse);

      bioService.lockStation();
      expect(bioService.isStationLocked, isTrue);

      bioService.unlockStation();
      expect(bioService.isStationLocked, isFalse);
    });

    testWidgets('AuthScreen displays Forgot Password and Quick Biometric login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Forgot Password?" button is present on email tab
      expect(find.text('Forgot Password?'), findsOneWidget);

      // Verify Biometric 1-Tap quick login button is present
      expect(find.byIcon(Icons.fingerprint_rounded), findsOneWidget);

      // Tap Forgot Password and verify dialog opens
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset Clinical Password'), findsNothing); // Dialog title check
      expect(find.text('Send Reset Link'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });

    testWidgets('AuthScreen switching to Register displays Password Strength Meter', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch mode to Register
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      expect(find.text('Create your Account'), findsOneWidget);

      // Type weak password
      final passwordField = find.byType(TextField).last;
      await tester.enterText(passwordField, '123');
      await tester.pumpAndSettle();

      expect(find.textContaining('Weak'), findsOneWidget);

      // Type strong clinical password
      await tester.enterText(passwordField, 'Aarogya@2026!');
      await tester.pumpAndSettle();

      expect(find.textContaining('Excellent'), findsOneWidget);
    });

    testWidgets('AuthScreen Doctor and Admin registration displays institutional verification code requirement', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: AuthScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Register mode
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Select Doctor role chip
      await tester.tap(find.byIcon(Icons.medical_services_rounded));
      await tester.pumpAndSettle();

      // Verify institutional code field and security governance notice
      expect(find.text('Institutional Verification Code'), findsOneWidget);
      expect(find.textContaining('Clinical Governance'), findsOneWidget);
      expect(find.textContaining('HOSP-DOC-2026'), findsWidgets);

      // Select Admin role chip
      await tester.tap(find.byIcon(Icons.admin_panel_settings_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Institutional Verification Code'), findsOneWidget);
      expect(find.textContaining('AIMS-ADMIN-2026'), findsWidgets);

      // Select Patient chip: self-registration is open, institutional code is hidden
      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Institutional Verification Code'), findsNothing);
    });
  });
}
