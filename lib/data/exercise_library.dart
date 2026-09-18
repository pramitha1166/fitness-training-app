import '../models/enums.dart';
import '../models/exercise.dart';

/// In-house aesthetic/physique-oriented exercise library (NFR-12: manageable
/// without app redeployment in a full backend; seeded locally for now).
class ExerciseLibrary {
  ExerciseLibrary._();

  static final List<Exercise> all = [
    // Chest
    const Exercise(
      id: 'ex_bench_press',
      name: 'Barbell Bench Press',
      muscleGroup: MuscleGroup.chest,
      description: 'Flat barbell press for overall chest mass and width.',
      mediaAsset: 'bench_press',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    const Exercise(
      id: 'ex_incline_db_press',
      name: 'Incline Dumbbell Press',
      muscleGroup: MuscleGroup.chest,
      description: 'Targets the upper chest for a fuller, rounded look.',
      mediaAsset: 'incline_db_press',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_pushup',
      name: 'Push-Up',
      muscleGroup: MuscleGroup.chest,
      description:
          'Bodyweight chest builder, great for definition and endurance.',
      mediaAsset: 'pushup',
      requiresEquipment: [
        EquipmentAccess.fullGym,
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    const Exercise(
      id: 'ex_cable_flye',
      name: 'Cable Chest Flye',
      muscleGroup: MuscleGroup.chest,
      description:
          'Isolation movement for chest symmetry and inner-chest detail.',
      mediaAsset: 'cable_flye',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    // Back
    const Exercise(
      id: 'ex_pullup',
      name: 'Pull-Up',
      muscleGroup: MuscleGroup.back,
      description: 'Builds the V-taper width every aesthetic physique needs.',
      mediaAsset: 'pullup',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_bent_row',
      name: 'Bent-Over Barbell Row',
      muscleGroup: MuscleGroup.back,
      description: 'Thickness builder for the mid-back.',
      mediaAsset: 'bent_row',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    const Exercise(
      id: 'ex_lat_pulldown',
      name: 'Lat Pulldown',
      muscleGroup: MuscleGroup.back,
      description: 'Machine alternative to pull-ups for lat width.',
      mediaAsset: 'lat_pulldown',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    const Exercise(
      id: 'ex_superman_row',
      name: 'Dumbbell Renegade Row',
      muscleGroup: MuscleGroup.back,
      description: 'Back + core builder usable with minimal equipment.',
      mediaAsset: 'renegade_row',
      requiresEquipment: [EquipmentAccess.homeBasic],
    ),
    // Shoulders
    const Exercise(
      id: 'ex_ohp',
      name: 'Overhead Press',
      muscleGroup: MuscleGroup.shoulders,
      description: 'Builds round, capped delts for a wider upper body.',
      mediaAsset: 'ohp',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_lateral_raise',
      name: 'Dumbbell Lateral Raise',
      muscleGroup: MuscleGroup.shoulders,
      description: 'Isolation for shoulder width and the "capped delt" look.',
      mediaAsset: 'lateral_raise',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_pike_pushup',
      name: 'Pike Push-Up',
      muscleGroup: MuscleGroup.shoulders,
      description: 'Bodyweight shoulder builder.',
      mediaAsset: 'pike_pushup',
      requiresEquipment: [EquipmentAccess.bodyweightOnly],
    ),
    // Arms
    const Exercise(
      id: 'ex_bicep_curl',
      name: 'Dumbbell Bicep Curl',
      muscleGroup: MuscleGroup.arms,
      description: 'Classic bicep peak builder.',
      mediaAsset: 'bicep_curl',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_tricep_dip',
      name: 'Tricep Dip',
      muscleGroup: MuscleGroup.arms,
      description: 'Builds tricep horseshoe using bodyweight or a bench.',
      mediaAsset: 'tricep_dip',
      requiresEquipment: [
        EquipmentAccess.fullGym,
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    const Exercise(
      id: 'ex_close_grip_pushup',
      name: 'Close-Grip Push-Up',
      muscleGroup: MuscleGroup.arms,
      description: 'Tricep-focused bodyweight press.',
      mediaAsset: 'close_grip_pushup',
      requiresEquipment: [EquipmentAccess.bodyweightOnly],
    ),
    // Legs
    const Exercise(
      id: 'ex_squat',
      name: 'Barbell Back Squat',
      muscleGroup: MuscleGroup.legs,
      description: 'The foundation for leg size and overall proportion.',
      mediaAsset: 'squat',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    const Exercise(
      id: 'ex_goblet_squat',
      name: 'Goblet Squat',
      muscleGroup: MuscleGroup.legs,
      description: 'Home-friendly squat variation for quads and glutes.',
      mediaAsset: 'goblet_squat',
      requiresEquipment: [EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_bodyweight_squat',
      name: 'Bodyweight Squat',
      muscleGroup: MuscleGroup.legs,
      description:
          'No-equipment leg builder, high reps for tone and definition.',
      mediaAsset: 'bodyweight_squat',
      requiresEquipment: [EquipmentAccess.bodyweightOnly],
    ),
    const Exercise(
      id: 'ex_lunge',
      name: 'Walking Lunge',
      muscleGroup: MuscleGroup.legs,
      description: 'Unilateral leg work that improves symmetry.',
      mediaAsset: 'lunge',
      requiresEquipment: [
        EquipmentAccess.fullGym,
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    // Glutes
    const Exercise(
      id: 'ex_hip_thrust',
      name: 'Barbell Hip Thrust',
      muscleGroup: MuscleGroup.glutes,
      description: 'The most effective glute-builder for a rounded aesthetic.',
      mediaAsset: 'hip_thrust',
      requiresEquipment: [EquipmentAccess.fullGym],
    ),
    const Exercise(
      id: 'ex_glute_bridge',
      name: 'Glute Bridge',
      muscleGroup: MuscleGroup.glutes,
      description: 'Bodyweight/home glute activation and growth.',
      mediaAsset: 'glute_bridge',
      requiresEquipment: [
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    // Core
    const Exercise(
      id: 'ex_plank',
      name: 'Plank',
      muscleGroup: MuscleGroup.core,
      description: 'Core stability and a flatter, tighter midsection.',
      mediaAsset: 'plank',
      requiresEquipment: [
        EquipmentAccess.fullGym,
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    const Exercise(
      id: 'ex_hanging_leg_raise',
      name: 'Hanging Leg Raise',
      muscleGroup: MuscleGroup.core,
      description: 'Lower-ab definition builder.',
      mediaAsset: 'hanging_leg_raise',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_bicycle_crunch',
      name: 'Bicycle Crunch',
      muscleGroup: MuscleGroup.core,
      description: 'Obliques and ab definition, no equipment needed.',
      mediaAsset: 'bicycle_crunch',
      requiresEquipment: [EquipmentAccess.bodyweightOnly],
    ),
    // Full body / conditioning
    const Exercise(
      id: 'ex_burpee',
      name: 'Burpee',
      muscleGroup: MuscleGroup.fullBody,
      description: 'Full-body conditioning to support fat loss and definition.',
      mediaAsset: 'burpee',
      requiresEquipment: [
        EquipmentAccess.fullGym,
        EquipmentAccess.homeBasic,
        EquipmentAccess.bodyweightOnly,
      ],
    ),
    const Exercise(
      id: 'ex_kb_swing',
      name: 'Kettlebell Swing',
      muscleGroup: MuscleGroup.fullBody,
      description: 'Posterior-chain conditioning and calorie burn.',
      mediaAsset: 'kb_swing',
      requiresEquipment: [EquipmentAccess.fullGym, EquipmentAccess.homeBasic],
    ),
    const Exercise(
      id: 'ex_mountain_climber',
      name: 'Mountain Climbers',
      muscleGroup: MuscleGroup.fullBody,
      description: 'Bodyweight cardio/core finisher.',
      mediaAsset: 'mountain_climber',
      requiresEquipment: [EquipmentAccess.bodyweightOnly],
    ),
  ];

  static Exercise byId(String id) =>
      all.firstWhere((e) => e.id == id, orElse: () => all.first);

  static List<Exercise> forMuscleGroup(
    MuscleGroup group,
    EquipmentAccess equipment,
  ) {
    return all
        .where(
          (e) =>
              e.muscleGroup == group && e.requiresEquipment.contains(equipment),
        )
        .toList();
  }
}
