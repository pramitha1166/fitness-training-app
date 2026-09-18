import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/progress_log.dart';
import '../services/storage_service.dart';

/// Body metrics, progress photos, and adherence trend tracking
/// (FR-4.1-FR-4.6).
class ProgressProvider extends ChangeNotifier {
  final StorageService _storage;
  static const _uuid = Uuid();

  List<ProgressLog> _logs = [];
  List<ProgressLog> get logs =>
      List.unmodifiable(_logs..sort((a, b) => a.date.compareTo(b.date)));

  ProgressProvider(this._storage) {
    _logs = _storage.loadProgressLogs();
  }

  Future<void> addLog(ProgressLog log) async {
    final withId = log.id.isEmpty ? _withId(log) : log;
    _logs.add(withId);
    await _storage.saveProgressLogs(_logs);
    notifyListeners();
  }

  ProgressLog _withId(ProgressLog log) => ProgressLog(
    id: _uuid.v4(),
    date: log.date,
    weightKg: log.weightKg,
    waistCm: log.waistCm,
    chestCm: log.chestCm,
    hipsCm: log.hipsCm,
    armsCm: log.armsCm,
    photoPath: log.photoPath,
    notes: log.notes,
  );

  Future<void> removeLog(String id) async {
    _logs.removeWhere((l) => l.id == id);
    await _storage.saveProgressLogs(_logs);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _logs = [];
    await _storage.saveProgressLogs(_logs);
    notifyListeners();
  }

  List<ProgressLog> get weightHistory =>
      _logs.where((l) => l.weightKg != null).toList();
  List<ProgressLog> get photoTimeline =>
      _logs.where((l) => l.photoPath != null).toList();

  /// FR-4.6: flag when adherence drops below a configurable threshold.
  bool isAdherenceLow(
    double workoutAdherence,
    double mealAdherence, {
    double threshold = 0.6,
  }) {
    return workoutAdherence < threshold || mealAdherence < threshold;
  }
}
