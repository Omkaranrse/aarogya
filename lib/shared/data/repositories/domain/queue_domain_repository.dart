import '../../../../core/backend/firebase_clinical_service.dart';
import '../../../../core/clinical/ews_triage_calculator.dart';
import '../../../domain/models/patient.dart';
import '../../../domain/models/queue_entry.dart';
import '../mock_data.dart';

/// Domain Repository for managing clinical patient queues,
/// automated NEWS2 EWS triage prioritization, and status transitions.
class QueueDomainRepository {
  List<QueueEntry> _queue = [];

  QueueDomainRepository() {
    _queue = List.from(AarogyaMockData.liveQueue);
    _sortQueue();
  }

  List<QueueEntry> get queue => List.unmodifiable(_queue);

  Future<List<QueueEntry>> fetchQueue() async {
    return List.unmodifiable(_queue);
  }

  void syncFromCloud(List<QueueEntry> cloudQueue) {
    if (cloudQueue.isNotEmpty) {
      _queue = List.from(cloudQueue);
      _sortQueue();
    }
  }

  void _sortQueue() {
    _queue.sort((a, b) {
      // 1. Active consultation always at top
      if (a.status == QueueStatus.consulting &&
          b.status != QueueStatus.consulting) {
        return -1;
      }
      if (b.status == QueueStatus.consulting &&
          a.status != QueueStatus.consulting) {
        return 1;
      }

      // 2. Waiting patients before completed/skipped
      if (a.status == QueueStatus.waiting && b.status != QueueStatus.waiting) {
        return -1;
      }
      if (b.status == QueueStatus.waiting && a.status != QueueStatus.waiting) {
        return 1;
      }

      // 3. Among waiting patients, Urgent & Emergency are strictly prioritized
      if (a.status == QueueStatus.waiting && b.status == QueueStatus.waiting) {
        const priorityWeights = {
          PatientPriority.emergency: 0,
          PatientPriority.urgent: 1,
          PatientPriority.normal: 2,
        };
        final weightA = priorityWeights[a.priority] ?? 2;
        final weightB = priorityWeights[b.priority] ?? 2;
        if (weightA != weightB) {
          return weightA.compareTo(weightB);
        }
      }

      // 4. Token number
      return a.tokenNumber.compareTo(b.tokenNumber);
    });
  }

  /// Automatically triages and adds a patient to the live clinical queue.
  /// If [vitals] are provided, clinical acuity is calculated via NEWS2.
  QueueEntry addPatient({
    required String patientName,
    required int age,
    required String gender,
    required String chiefComplaint,
    PatientPriority? priority,
    PatientVitals? vitals,
    String? appointmentId,
    String? patientId,
    String? doctorId,
  }) {
    PatientPriority resolvedPriority = priority ?? PatientPriority.normal;
    int? ewsScore;
    String? ewsCategory;

    if (vitals != null) {
      final ews = EwsTriageCalculator.calculate(vitals);
      ewsScore = ews.totalScore;
      ewsCategory = '${ews.riskCategory} (NEWS2: ${ews.totalScore})';
      if (priority == null || priority == PatientPriority.normal) {
        resolvedPriority = ews.priority;
      }
    }

    final nextToken = _queue.isEmpty
        ? 1
        : (_queue.map((q) => q.tokenNumber).reduce((a, b) => a > b ? a : b) + 1);

    final newEntry = QueueEntry(
      id: 'q-${DateTime.now().millisecondsSinceEpoch}',
      tokenNumber: nextToken,
      patientId: patientId ?? 'pat-${DateTime.now().millisecondsSinceEpoch}',
      patientName: patientName,
      age: age,
      gender: gender,
      appointmentId: appointmentId ?? 'apt-${DateTime.now().millisecondsSinceEpoch}',
      doctorId: doctorId ?? 'doc-1',
      status: QueueStatus.waiting,
      priority: resolvedPriority,
      checkInTime: DateTime.now(),
      estimatedWaitMinutes: resolvedPriority == PatientPriority.emergency
          ? 2
          : (_queue.where((q) => q.status == QueueStatus.waiting).length * 12 + 8),
      chiefComplaint: chiefComplaint,
      ewsScore: ewsScore,
      ewsCategory: ewsCategory,
      vitals: vitals,
    );

    if (resolvedPriority == PatientPriority.emergency ||
        resolvedPriority == PatientPriority.urgent) {
      final consultingIdx = _queue.indexWhere(
        (q) => q.status == QueueStatus.consulting,
      );
      if (consultingIdx != -1) {
        _queue.insert(consultingIdx + 1, newEntry);
      } else {
        _queue.insert(0, newEntry);
      }
    } else {
      _queue.add(newEntry);
    }

    _sortQueue();
    FirebaseClinicalService().syncQueueEntry(newEntry);
    return newEntry;
  }

  void updateStatus(String queueId, QueueStatus newStatus) {
    final index = _queue.indexWhere((q) => q.id == queueId);
    if (index != -1) {
      if (newStatus == QueueStatus.consulting) {
        for (int i = 0; i < _queue.length; i++) {
          if (_queue[i].status == QueueStatus.consulting) {
            _queue[i] = _queue[i].copyWith(status: QueueStatus.waiting);
          }
        }
      }
      _queue[index] = _queue[index].copyWith(status: newStatus);
      FirebaseClinicalService().syncQueueEntry(_queue[index]);
      _sortQueue();
    }
  }

  QueueEntry? callNext() {
    int nextWaitingIndex = _queue.indexWhere(
      (q) => q.status == QueueStatus.waiting && q.priority == PatientPriority.emergency,
    );
    if (nextWaitingIndex == -1) {
      nextWaitingIndex = _queue.indexWhere(
        (q) => q.status == QueueStatus.waiting && q.priority == PatientPriority.urgent,
      );
    }
    if (nextWaitingIndex == -1) {
      nextWaitingIndex = _queue.indexWhere((q) => q.status == QueueStatus.waiting);
    }

    if (nextWaitingIndex != -1) {
      for (int i = 0; i < _queue.length; i++) {
        if (_queue[i].status == QueueStatus.consulting) {
          _queue[i] = _queue[i].copyWith(status: QueueStatus.completed);
          FirebaseClinicalService().syncQueueEntry(_queue[i]);
        }
      }
      _queue[nextWaitingIndex] = _queue[nextWaitingIndex].copyWith(
        status: QueueStatus.consulting,
      );
      final called = _queue[nextWaitingIndex];
      FirebaseClinicalService().syncQueueEntry(called);
      _sortQueue();
      return called;
    }
    return null;
  }
}
