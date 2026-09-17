import '../../shared/domain/models/lab_report.dart';

class ReferenceRangeResult {
  final String analyte;
  final double value;
  final String unit;
  final String displayRange;
  final String label;
  final LabResultStatus status;
  final String glyph;
  final double minRange;
  final double maxRange;
  final bool isOverflow;

  const ReferenceRangeResult({
    required this.analyte,
    required this.value,
    required this.unit,
    required this.displayRange,
    required this.label,
    required this.status,
    required this.glyph,
    required this.minRange,
    required this.maxRange,
    this.isOverflow = false,
  });

  /// Spoken semantics label for screen readers:
  /// e.g. "LDL cholesterol, 138 milligrams per decilitre, high, reference range up to 100."
  String get spokenSemantics {
    final rangeText = minRange <= 0
        ? 'up to $maxRange'
        : '$minRange to $maxRange';
    return '$analyte, $value $unit, ${label.toLowerCase()}, reference range $rangeText.';
  }
}

class ReferenceRangeService {
  ReferenceRangeService._();

  static ReferenceRangeResult evaluate({
    required String testName,
    required double value,
    String? unit,
    double? minRange,
    double? maxRange,
    int? patientAge,
    String? patientGender,
  }) {
    final lowerName = testName.toLowerCase();

    // Known clinical standards fallback defaults if not provided
    double min = minRange ?? 0.0;
    double max = maxRange ?? 100.0;
    String effectiveUnit = unit ?? '';

    if (lowerName.contains('total cholesterol')) {
      min = minRange ?? 125.0;
      max = maxRange ?? 200.0;
      effectiveUnit = unit ?? 'mg/dL';
    } else if (lowerName.contains('ldl')) {
      min = minRange ?? 0.0;
      max = maxRange ?? 100.0;
      effectiveUnit = unit ?? 'mg/dL';
    } else if (lowerName.contains('hdl')) {
      min = minRange ?? 40.0;
      max = maxRange ?? 60.0;
      effectiveUnit = unit ?? 'mg/dL';
    } else if (lowerName.contains('triglycerides')) {
      min = minRange ?? 50.0;
      max = maxRange ?? 150.0;
      effectiveUnit = unit ?? 'mg/dL';
    } else if (lowerName.contains('hemoglobin')) {
      final isFemale = patientGender?.toLowerCase().startsWith('f') ?? false;
      min = minRange ?? (isFemale ? 12.0 : 13.5);
      max = maxRange ?? (isFemale ? 15.5 : 17.5);
      effectiveUnit = unit ?? 'g/dL';
    } else if (lowerName.contains('wbc')) {
      min = minRange ?? 4000.0;
      max = maxRange ?? 11000.0;
      effectiveUnit = unit ?? '/cumm';
    } else if (lowerName.contains('platelet')) {
      min = minRange ?? 150000.0;
      max = maxRange ?? 450000.0;
      effectiveUnit = unit ?? '/cumm';
    } else if (lowerName.contains('esr')) {
      min = minRange ?? 0.0;
      max = maxRange ?? 15.0;
      effectiveUnit = unit ?? 'mm/hr';
    }

    LabResultStatus status;
    String label;
    String glyph;

    if (value < min) {
      status = LabResultStatus.low;
      label = 'Low';
      glyph = '↓';
    } else if (value > max) {
      // Critical threshold if >= 1.5x of max
      if (value >= max * 1.5 && max > 0) {
        status = LabResultStatus.critical;
        label = 'Critical High';
        glyph = '↑';
      } else {
        status = LabResultStatus.high;
        label = 'High';
        glyph = '↑';
      }
    } else {
      status = LabResultStatus.normal;
      label = 'Normal';
      glyph = '●';
    }

    final isOverflow = max > 0 && value > (max * 1.35);

    final displayRange = min <= 0
        ? '< ${max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 1)} $effectiveUnit'
        : '${min.toStringAsFixed(min.truncateToDouble() == min ? 0 : 1)} - ${max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 1)} $effectiveUnit';

    return ReferenceRangeResult(
      analyte: testName,
      value: value,
      unit: effectiveUnit,
      displayRange: displayRange,
      label: label,
      status: status,
      glyph: glyph,
      minRange: min,
      maxRange: max,
      isOverflow: isOverflow,
    );
  }
}
