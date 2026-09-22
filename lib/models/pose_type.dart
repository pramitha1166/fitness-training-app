/// The movement archetype an exercise belongs to, used to pick a distinct
/// looping pose animation for its illustration (see
/// `widgets/exercise_illustration.dart`). Several exercises can share an
/// archetype (e.g. bench press and push-ups are both `press`) while still
/// rendering with their own accent color and label.
enum PoseType {
  press,
  pull,
  curl,
  lateralRaise,
  dip,
  squat,
  lunge,
  hinge,
  core,
  cardio,
}
