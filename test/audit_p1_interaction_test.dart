import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aarogya/core/clinical/reference_range_service.dart';
import 'package:aarogya/core/design_system/components/reference_gauge_painter.dart';
import 'package:aarogya/shared/domain/models/lab_report.dart';
import 'package:aarogya/shared/domain/models/doctor.dart';

void main() {
  group('Phase P1.1 & P1.2 — Clinical Reference Range Service & Gauge Tests', () {
    test('evaluate returns normal for value within reference range', () {
      final res = ReferenceRangeService.evaluate(
        testName: 'Hemoglobin',
        value: 14.5,
        patientGender: 'Male',
      );

      expect(res.status, LabResultStatus.normal);
      expect(res.label, 'Normal');
      expect(res.glyph, '●');
      expect(res.isOverflow, isFalse);
      expect(res.spokenSemantics, contains('normal'));
      expect(res.spokenSemantics, contains('14.5 g/dL'));
    });

    test('evaluate returns low for value below reference minimum', () {
      final res = ReferenceRangeService.evaluate(
        testName: 'Hemoglobin',
        value: 10.2,
        patientGender: 'Male',
      );

      expect(res.status, LabResultStatus.low);
      expect(res.label, 'Low');
      expect(res.glyph, '↓');
      expect(res.spokenSemantics, contains('low'));
    });

    test('evaluate returns high for value above reference maximum', () {
      final res = ReferenceRangeService.evaluate(
        testName: 'Total Cholesterol',
        value: 230.0,
      );

      expect(res.status, LabResultStatus.high);
      expect(res.label, 'High');
      expect(res.glyph, '↑');
      expect(res.isOverflow, isFalse);
    });

    test('evaluate detects critical high status and overflow condition', () {
      final res = ReferenceRangeService.evaluate(
        testName: 'Triglycerides',
        value: 350.0, // max is 150, 350 >= 150 * 1.5 => critical high & overflow
      );

      expect(res.status, LabResultStatus.critical);
      expect(res.label, 'Critical High');
      expect(res.isOverflow, isTrue);
    });

    testWidgets('ReferenceGaugePainter paints without exceptions', (tester) async {
      const painter = ReferenceGaugePainter(
        value: 140.0,
        minRange: 70.0,
        maxRange: 110.0,
        lowColor: Colors.amber,
        normalColor: Colors.green,
        highColor: Colors.red,
        pinColor: Colors.red,
        isLow: false,
        isNormal: false,
        isHigh: true,
        isOverflow: true,
        animationProgress: 1.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(300, 10),
              painter: painter,
            ),
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is ReferenceGaugePainter,
        ),
        findsOneWidget,
      );
    });
  });

  group('Phase P1.5 — Doctor Discovery & Filtering Tests', () {
    final testDoctors = [
      const Doctor(
        id: 'doc-1',
        name: 'Dr. Sarah Jenkins',
        specialty: 'Cardiologist',
        qualifications: 'MD, DM (Cardiology)',
        experienceYears: 14,
        rating: 4.9,
        reviewsCount: 128,
        consultationFee: 800.0,
        hospital: 'Apollo Hospitals',
        bio: 'Leading cardiologist',
        avatarUrl: 'https://example.com/doc1.png',
        availableDays: ['Mon', 'Tue', 'Wed'],
        timeSlots: ['09:00 AM', '10:30 AM', '04:30 PM'],
        isAvailableToday: true,
      ),
      const Doctor(
        id: 'doc-2',
        name: 'Dr. Rajesh Rao',
        specialty: 'Neurologist',
        qualifications: 'MD, DM (Neurology)',
        experienceYears: 20,
        rating: 4.8,
        reviewsCount: 95,
        consultationFee: 1200.0,
        hospital: 'Fortis Hospital',
        bio: 'Senior neurologist',
        avatarUrl: 'https://example.com/doc2.png',
        availableDays: ['Tue', 'Thu'],
        timeSlots: ['11:00 AM', '02:00 PM'],
        isAvailableToday: false,
      ),
      const Doctor(
        id: 'doc-3',
        name: 'Dr. Priya Mehta',
        specialty: 'Pediatrician',
        qualifications: 'MBBS, DCH',
        experienceYears: 8,
        rating: 4.7,
        reviewsCount: 64,
        consultationFee: 500.0,
        hospital: 'Manipal Hospital',
        bio: 'Compassionate pediatrician',
        avatarUrl: 'https://example.com/doc3.png',
        availableDays: ['Mon', 'Wed', 'Fri'],
        timeSlots: ['10:00 AM', '03:00 PM'],
        isAvailableToday: true,
      ),
    ];

    test('Filter by fee under ₹600', () {
      final under600 = testDoctors.where((d) => d.consultationFee < 600).toList();
      expect(under600.length, 1);
      expect(under600.first.name, 'Dr. Priya Mehta');
    });

    test('Filter by fee mid-range ₹600 - ₹1000', () {
      final midRange = testDoctors
          .where((d) => d.consultationFee >= 600 && d.consultationFee <= 1000)
          .toList();
      expect(midRange.length, 1);
      expect(midRange.first.name, 'Dr. Sarah Jenkins');
    });

    test('Filter by fee premium > ₹1000', () {
      final premium = testDoctors.where((d) => d.consultationFee > 1000).toList();
      expect(premium.length, 1);
      expect(premium.first.name, 'Dr. Rajesh Rao');
    });

    test('Doctor slot extraction returns top 3 slots', () {
      final doc = testDoctors.first;
      final top3 = doc.timeSlots.take(3).toList();
      expect(top3, ['09:00 AM', '10:30 AM', '04:30 PM']);
    });
  });
}
