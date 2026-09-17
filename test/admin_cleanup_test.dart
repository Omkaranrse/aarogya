import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aarogya/features/admin/admin_dashboard.dart';
import 'package:aarogya/features/admin/management/department_management_screen.dart';
import 'package:aarogya/features/admin/management/doctor_management_screen.dart';
import 'package:aarogya/features/admin/management/patient_management_screen.dart';
import 'package:aarogya/app/theme/aarogya_theme.dart';

void main() {
  Widget createTestWidget(Widget child, {Size size = const Size(375, 812)}) {
    return ProviderScope(
      child: MaterialApp(
        theme: AarogyaTheme.lightTheme,
        home: Scaffold(
          body: MediaQuery(
            data: MediaQueryData(size: size),
            child: child,
          ),
        ),
      ),
    );
  }

  group('Admin Screens Clean-up & Responsiveness Tests', () {
    testWidgets('AdminDashboard renders executive tabs and switches content seamlessly on mobile', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const AdminDashboard(), size: const Size(375, 812)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Ensure no overflow errors occurred during build
      expect(tester.takeException(), isNull);

      // Verify Executive KPI cards are present
      expect(find.text('Hospital Command Center'), findsOneWidget);
      expect(find.text('Total Patients'), findsOneWidget);
      expect(find.text('Bed Occupancy'), findsOneWidget);

      // Verify Executive Section Navigator tabs
      expect(find.text('OPD & Triage Desk'), findsOneWidget);
      expect(find.text('Bed & Ward Census'), findsOneWidget);
      expect(find.text('Operations & Staff'), findsOneWidget);

      // Default section is OPD & Triage Desk
      expect(find.text('OPD Arrival & Vitals Triage Desk'), findsOneWidget);
      expect(find.text('Register Walk-In'), findsOneWidget);

      // Switch to Bed & Ward Census
      await tester.tap(find.text('Bed & Ward Census'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      expect(find.text('Inpatient Bed Occupancy Grid'), findsOneWidget);
      expect(find.text('All Wards (16)'), findsOneWidget);

      // Switch to Operations & Staff
      await tester.tap(find.text('Operations & Staff'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      expect(find.text('Clinical Department Throughput'), findsOneWidget);
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Live Institutional Events'), findsOneWidget);
    });

    testWidgets('DepartmentManagementScreen renders without layout overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const DepartmentManagementScreen(), size: const Size(375, 812)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
      expect(find.text('Clinical Departments & Specialties'), findsOneWidget);
      expect(find.text('Cardiology & Vascular Sciences'), findsOneWidget);
    });

    testWidgets('DoctorManagementScreen renders with switch rows intact and without overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const DoctorManagementScreen(), size: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Specialist & Faculty Directory'), findsOneWidget);
      expect(find.byType(Switch), findsWidgets);
    });

    testWidgets('PatientManagementScreen renders patient records cleanly without overflow', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const PatientManagementScreen(), size: const Size(375, 812)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Patient Master Registry'), findsOneWidget);
      expect(find.text('Search patients by name, MRN / ID, or contact number...'), findsOneWidget);
    });
  });
}
