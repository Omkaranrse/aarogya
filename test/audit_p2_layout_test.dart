import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aarogya/core/design_system/tokens/colors.dart';
import 'package:aarogya/core/design_system/components/contextual_header.dart';
import 'package:aarogya/features/clinical/prescriptions_hub_screen.dart';
import 'package:aarogya/features/clinical/laboratory_hub_screen.dart';
import 'package:aarogya/features/clinical/medical_records_screen.dart';
import 'package:aarogya/features/billing/billing_screen.dart';
import 'package:aarogya/features/patient/appointments/patient_appointments_screen.dart';
import 'package:aarogya/features/patient/discovery/doctor_discovery_screen.dart';

void main() {
  group('Phase P2 — Layout, Visual Craft & Constraints Tests', () {
    testWidgets('PrescriptionsHubScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PrescriptionsHubScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('LaboratoryHubScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LaboratoryHubScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('PatientAppointmentsScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PatientAppointmentsScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('DoctorDiscoveryScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: DoctorDiscoveryScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('MedicalRecordsScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MedicalRecordsScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('BillingScreen renders with MaxWidth constraint', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BillingScreen(),
          ),
        ),
      );

      final constrainedBoxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final has1320Constraint = constrainedBoxes.any(
        (cb) => cb.constraints.maxWidth == 1320.0,
      );
      expect(has1320Constraint, isTrue);
    });

    testWidgets('ContextualHeader renders title, subtitle and telemetry status label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: ContextualHeader(
              title: 'Prescriptions Hub',
              subtitle: 'Active medications & refills',
              statusLabel: '3 Active Rx',
              statusColor: AarogyaColors.accentPurple,
            ),
          ),
        ),
      );

      expect(find.text('Prescriptions Hub'), findsOneWidget);
      expect(find.text('Active medications & refills'), findsOneWidget);
      expect(find.text('3 Active Rx'), findsOneWidget);
    });
  });
}
