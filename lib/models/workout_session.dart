import 'enums.dart';
import 'exercise.dart';
import 'time_slot.dart';

/// A single scheduled workout (FR-2.2, FR-2.6).
class WorkoutSession {
  final String id;
  final String title;
  final MuscleGroup focus;
  final TimeSlot slot;
  final List<WorkoutExercise> exercises;
  LogStatus status;

  WorkoutSession({
    required this.id,
    required this.title,
    required this.focus,
    required this.slot,
    required this.exercises,
    this.status = LogStatus.pending,
  });

  int get estimatedDurationMinutes {
    final workSeconds = exercises.fold<int>(
      0,
      (sum, e) => sum + (e.sets * (45 + e.restSeconds)),
    );
    return (workSeconds / 60).ceil();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'focus': focus.name,
    'slot': slot.toJson(),
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'status': status.name,
  };

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json,
    Exercise Function(String id) exerciseLookup,
  ) => WorkoutSession(
    id: json['id'] as String,
    title: json['title'] as String,
    focus: MuscleGroup.values.byName(json['focus'] as String),
    slot: TimeSlot.fromJson(json['slot'] as Map<String, dynamic>),
    exercises: (json['exercises'] as List)
        .map(
          (e) => WorkoutExercise.fromJson(
            e as Map<String, dynamic>,
            exerciseLookup(e['exerciseId'] as String),
          ),
        )
        .toList(),
    status: LogStatus.values.byName(json['status'] as String? ?? 'pending'),
  );
}

/// The full weekly plan (FR-2.1).
class WorkoutPlan {
  final String id;
  final DateTime generatedAt;
  final List<WorkoutSession> sessions;

  const WorkoutPlan({
    required this.id,
    required this.generatedAt,
    required this.sessions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'generatedAt': generatedAt.toIso8601String(),
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory WorkoutPlan.fromJson(
    Map<String, dynamic> json,
    Exercise Function(String id) exerciseLookup,
  ) => WorkoutPlan(
    id: json['id'] as String,
    generatedAt: DateTime.parse(json['generatedAt'] as String),
    sessions: (json['sessions'] as List)
        .map(
          (s) => WorkoutSession.fromJson(
            s as Map<String, dynamic>,
            exerciseLookup,
          ),
        )
        .toList(),
  );
}
