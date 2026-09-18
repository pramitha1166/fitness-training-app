import 'enums.dart';

/// A library exercise definition (content-managed, NFR-12).
class Exercise {
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final String description;
  final String mediaAsset; // icon/illustration key used by the UI
  final List<EquipmentAccess> requiresEquipment;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.description,
    required this.mediaAsset,
    required this.requiresEquipment,
  });
}

/// A single exercise as scheduled within a workout session, with the
/// prescribed sets/reps/rest (FR-2.3).
class WorkoutExercise {
  final Exercise exercise;
  final int sets;
  final int reps;
  final int restSeconds;
  bool completed;

  WorkoutExercise({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.restSeconds,
    this.completed = false,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exercise.id,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'completed': completed,
  };

  factory WorkoutExercise.fromJson(
    Map<String, dynamic> json,
    Exercise exercise,
  ) => WorkoutExercise(
    exercise: exercise,
    sets: json['sets'] as int,
    reps: json['reps'] as int,
    restSeconds: json['restSeconds'] as int,
    completed: json['completed'] as bool? ?? false,
  );
}
