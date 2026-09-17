import '../../shared/domain/models/patient.dart';
import '../../shared/domain/models/queue_entry.dart';

/// Clinical parameter score within the NEWS2 / Early Warning Score system.
class EwsParameterScore {
  final String parameterName;
  final String observedValue;
  final int points;
  final String clinicalInterpretation;

  const EwsParameterScore({
    required this.parameterName,
    required this.observedValue,
    required this.points,
    required this.clinicalInterpretation,
  });
}

/// Comprehensive EWS clinical triage evaluation result.
class EwsTriageResult {
  final int totalScore;
  final PatientPriority priority;
  final String riskCategory;
  final String clinicalSummary;
  final List<EwsParameterScore> parameters;
  final List<String> criticalAlerts;

  const EwsTriageResult({
    required this.totalScore,
    required this.priority,
    required this.riskCategory,
    required this.clinicalSummary,
    required this.parameters,
    required this.criticalAlerts,
  });
}

/// National Early Warning Score (NEWS2) Clinical Acuity Calculator.
/// Automatically determines physiological risk and queue triage priority
/// from vital signs upon patient check-in.
class EwsTriageCalculator {
  static EwsTriageResult calculate(PatientVitals vitals) {
    final List<EwsParameterScore> scores = [];
    final List<String> alerts = [];

    // 1. Respiration Rate (RR)
    final rr = vitals.respiratoryRate ?? 16;
    int rrPoints = 0;
    String rrInterp = 'Normal respiration (12–20 bpm)';
    if (rr <= 8) {
      rrPoints = 3;
      rrInterp = 'Severe bradypnea (<=8 bpm)';
      alerts.add('Severe respiratory depression (RR: $rr bpm)');
    } else if (rr >= 9 && rr <= 11) {
      rrPoints = 1;
      rrInterp = 'Mild bradypnea (9–11 bpm)';
    } else if (rr >= 12 && rr <= 20) {
      rrPoints = 0;
      rrInterp = 'Normal respiratory rate';
    } else if (rr >= 21 && rr <= 24) {
      rrPoints = 2;
      rrInterp = 'Moderate tachypnea (21–24 bpm)';
      alerts.add('Elevated respiratory rate (RR: $rr bpm)');
    } else {
      rrPoints = 3;
      rrInterp = 'Severe tachypnea (>=25 bpm)';
      alerts.add('Critical respiratory distress (RR: $rr bpm)');
    }
    scores.add(EwsParameterScore(
      parameterName: 'Respiration Rate',
      observedValue: '$rr bpm',
      points: rrPoints,
      clinicalInterpretation: rrInterp,
    ));

    // 2. Oxygen Saturation (SpO2)
    final spo2 = vitals.spo2;
    int spo2Points = 0;
    String spo2Interp = 'Adequate oxygenation (>=96%)';
    if (spo2 <= 91.0) {
      spo2Points = 3;
      spo2Interp = 'Severe arterial hypoxia (<=91%)';
      alerts.add('Critical hypoxia detected (SpO2: ${spo2.toStringAsFixed(1)}%)');
    } else if (spo2 >= 92.0 && spo2 <= 93.9) {
      spo2Points = 2;
      spo2Interp = 'Moderate hypoxia (92–93%)';
      alerts.add('Hypoxemia noted (SpO2: ${spo2.toStringAsFixed(1)}%)');
    } else if (spo2 >= 94.0 && spo2 <= 95.9) {
      spo2Points = 1;
      spo2Interp = 'Mild hypoxemia (94–95%)';
    } else {
      spo2Points = 0;
      spo2Interp = 'Normal oxygen saturation (>=96%)';
    }
    scores.add(EwsParameterScore(
      parameterName: 'Oxygen Saturation',
      observedValue: '${spo2.toStringAsFixed(1)}%',
      points: spo2Points,
      clinicalInterpretation: spo2Interp,
    ));

    // 3. Systolic Blood Pressure
    final systolicStr = vitals.bloodPressure.contains('/')
        ? vitals.bloodPressure.split('/').first.trim()
        : vitals.bloodPressure.trim();
    final systolic = int.tryParse(systolicStr) ?? 120;
    int bpPoints = 0;
    String bpInterp = 'Normal systolic pressure (111–219 mmHg)';
    if (systolic <= 90) {
      bpPoints = 3;
      bpInterp = 'Severe hypotension / shock index (<=90 mmHg)';
      alerts.add('Severe hypotension (Systolic BP: $systolic mmHg)');
    } else if (systolic >= 91 && systolic <= 100) {
      bpPoints = 2;
      bpInterp = 'Moderate hypotension (91–100 mmHg)';
      alerts.add('Hypotension detected (Systolic BP: $systolic mmHg)');
    } else if (systolic >= 101 && systolic <= 110) {
      bpPoints = 1;
      bpInterp = 'Borderline low systolic (101–110 mmHg)';
    } else if (systolic >= 111 && systolic <= 219) {
      bpPoints = 0;
      bpInterp = 'Hemodynamically normal';
    } else {
      bpPoints = 3;
      bpInterp = 'Severe hypertensive urgency / crisis (>=220 mmHg)';
      alerts.add('Hypertensive emergency threshold (Systolic BP: $systolic mmHg)');
    }
    scores.add(EwsParameterScore(
      parameterName: 'Systolic BP',
      observedValue: vitals.bloodPressure,
      points: bpPoints,
      clinicalInterpretation: bpInterp,
    ));

    // 4. Heart Rate (Pulse)
    final hr = vitals.heartRate;
    int hrPoints = 0;
    String hrInterp = 'Normal sinus rhythm (51–90 bpm)';
    if (hr <= 40) {
      hrPoints = 3;
      hrInterp = 'Critical bradycardia (<=40 bpm)';
      alerts.add('Severe bradycardia (HR: $hr bpm)');
    } else if (hr >= 41 && hr <= 50) {
      hrPoints = 1;
      hrInterp = 'Borderline bradycardia (41–50 bpm)';
    } else if (hr >= 51 && hr <= 90) {
      hrPoints = 0;
      hrInterp = 'Normal heart rate (51–90 bpm)';
    } else if (hr >= 91 && hr <= 110) {
      hrPoints = 1;
      hrInterp = 'Mild tachycardia (91–110 bpm)';
    } else if (hr >= 111 && hr <= 130) {
      hrPoints = 2;
      hrInterp = 'Moderate tachycardia (111–130 bpm)';
      alerts.add('Marked tachycardia (HR: $hr bpm)');
    } else {
      hrPoints = 3;
      hrInterp = 'Severe tachycardia (>=131 bpm)';
      alerts.add('Critical tachyarrhythmia risk (HR: $hr bpm)');
    }
    scores.add(EwsParameterScore(
      parameterName: 'Heart Rate',
      observedValue: '$hr bpm',
      points: hrPoints,
      clinicalInterpretation: hrInterp,
    ));

    // 5. Body Temperature
    double tempF = vitals.temperature;
    if (tempF <= 50.0) {
      // Input was in Celsius (e.g. 37.2)
      tempF = (tempF * 9.0 / 5.0) + 32.0;
    }
    int tempPoints = 0;
    String tempInterp = 'Normothermic (96.9–100.4°F)';
    if (tempF <= 95.0) {
      tempPoints = 3;
      tempInterp = 'Hypothermia (<=95.0°F / 35.0°C)';
      alerts.add('Severe hypothermia (${tempF.toStringAsFixed(1)}°F)');
    } else if (tempF >= 95.1 && tempF <= 96.8) {
      tempPoints = 1;
      tempInterp = 'Mild hypothermia (95.1–96.8°F)';
    } else if (tempF >= 96.9 && tempF <= 100.4) {
      tempPoints = 0;
      tempInterp = 'Afebrile / Normothermic';
    } else if (tempF >= 100.5 && tempF <= 102.2) {
      tempPoints = 1;
      tempInterp = 'Pyrexia / Low-grade fever (100.5–102.2°F)';
    } else {
      tempPoints = 2;
      tempInterp = 'High pyrexia (>=102.3°F / 39.1°C)';
      alerts.add('High fever observed (${tempF.toStringAsFixed(1)}°F)');
    }
    scores.add(EwsParameterScore(
      parameterName: 'Body Temperature',
      observedValue: '${vitals.temperature.toStringAsFixed(1)}°${vitals.temperature > 50 ? 'F' : 'C'}',
      points: tempPoints,
      clinicalInterpretation: tempInterp,
    ));

    // Total EWS Score
    final total = scores.fold<int>(0, (sum, p) => sum + p.points);

    // Any individual trigger of 3 points indicates an immediate red-flag condition
    final hasRedFlag = scores.any((p) => p.points >= 3);

    PatientPriority priority;
    String riskCategory;
    String clinicalSummary;

    if (total >= 5 || hasRedFlag) {
      priority = PatientPriority.emergency;
      riskCategory = 'High Clinical Risk';
      clinicalSummary = hasRedFlag
          ? 'Single critical red-flag vital trigger detected (EWS: $total). Immediate medical assessment required.'
          : 'Severe multi-system physiological derangement (EWS: $total). Emergency clinical triage.';
    } else if (total >= 3) {
      priority = PatientPriority.urgent;
      riskCategory = 'Medium Clinical Risk';
      clinicalSummary = 'Moderate physiological instability (EWS: $total). Prioritized OPD review recommended.';
    } else {
      priority = PatientPriority.normal;
      riskCategory = 'Low Clinical Risk';
      clinicalSummary = 'Stable physiological parameters (EWS: $total). Routine clinical queue progression.';
    }

    return EwsTriageResult(
      totalScore: total,
      priority: priority,
      riskCategory: riskCategory,
      clinicalSummary: clinicalSummary,
      parameters: scores,
      criticalAlerts: alerts,
    );
  }
}
