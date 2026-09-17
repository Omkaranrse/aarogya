import '../../../domain/models/lab_report.dart';
import '../mock_data.dart';

/// Domain Repository for managing laboratory diagnostic panels,
/// reference ranges, and verified pathology findings.
class LabDomainRepository {
  List<LabReport> _labReports = [];

  LabDomainRepository() {
    _labReports = List.from(AarogyaMockData.sampleLabReports);
  }

  List<LabReport> get labReports => List.unmodifiable(_labReports);

  Future<List<LabReport>> fetchReports() async {
    return List.unmodifiable(_labReports);
  }

  List<LabReport> getAbnormalReports() {
    return _labReports.where((r) => r.hasAbnormalResults).toList();
  }

  void addReport(LabReport report) {
    _labReports.insert(0, report);
  }

  void updateReportStatus(String reportId, ReportStatus newStatus) {
    final index = _labReports.indexWhere((r) => r.id == reportId);
    if (index != -1) {
      _labReports[index] = _labReports[index].copyWith(
        status: newStatus,
        completedDate: newStatus == ReportStatus.completed ? DateTime.now() : null,
      );
    }
  }
}
